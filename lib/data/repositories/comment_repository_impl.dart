import 'package:drift/drift.dart';

import '../../core/config/app_flags.dart';
import '../comments/comment_generation_engine.dart';
import '../comments/comment_job_models.dart';
import '../db/app_database.dart';
import '../llm/llm_client.dart';
import '../llm/llm_prompt.dart';
import '../llm/llm_resolve.dart';
import '../llm/llm_text_sanitize.dart';
import '../models/models.dart';
import 'comment_job_repository.dart';
import 'comment_job_repository_impl.dart';
import 'comment_repository.dart';
import 'llm_provider_repository.dart';
import 'warm_event_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(
    this._db, {
    WarmEventRepository? warmEvents,
    CommentJobRepository? jobs,
    CommentGenerationEngine? engine,
    String leaseOwner = 'ui',
  }) : _warmEvents = warmEvents,
       _jobs = jobs ?? CommentJobRepositoryImpl(_db),
       _leaseOwner = leaseOwner {
    _engine = engine ?? CommentGenerationEngine(db: _db, jobs: _jobs);
  }

  final AppDatabase _db;
  final WarmEventRepository? _warmEvents;
  final CommentJobRepository _jobs;
  late final CommentGenerationEngine _engine;
  final String _leaseOwner;

  CommentJobRepository get jobs => _jobs;

  @override
  Stream<List<Comment>> watchForArticle(String articleId) {
    return (_db.select(_db.comments)
          ..where((t) => t.articleId.equals(articleId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  @override
  Future<void> clearAll() async {
    await _jobs.cancelAllJobs();
    await _db.delete(_db.comments).go();
  }

  @override
  Future<void> clearForArticle(String articleId) async {
    await _jobs.cancelJobsForArticle(articleId);
    await (_db.delete(
      _db.comments,
    )..where((t) => t.articleId.equals(articleId))).go();
  }

  @override
  Future<CommentGenerationResult> ensureGenerated(
    String articleId, {
    required CommentTrigger trigger,
    required List<Netizen> pool,
    required Article article,
    List<LlmProvider> providers = const [],
    List<LlmModel> models = const [],
    LlmProviderRepository? llmRepo,
    LlmClient? llmClient,
    bool forceMock = false,
    void Function(CommentGenerationProgress progress)? onProgress,
  }) async {
    if (trigger == CommentTrigger.off) {
      return const CommentGenerationResult(total: 0, generated: 0);
    }
    if (llmClient == null || llmRepo == null) {
      return const CommentGenerationResult(total: 0, generated: 0);
    }

    // Resume open durable job (partial kill recovery).
    var open = await _jobs.getOpenJobForArticle(articleId);
    if (open != null) {
      return _engine.runJob(
        jobId: open.id,
        owner: _leaseOwner,
        article: article,
        pool: pool,
        providers: providers,
        models: models,
        llmRepo: llmRepo,
        llmClient: llmClient,
        forceMock: forceMock,
        onProgress: onProgress,
      );
    }

    // Legacy / completed: any netizen top-level comment without open job → done.
    final existingTop =
        await (_db.select(_db.comments)..where(
              (t) =>
                  t.articleId.equals(articleId) &
                  t.authorType.equals('netizen') &
                  t.parentId.isNull(),
            ))
            .get();
    if (existingTop.isNotEmpty) {
      return const CommentGenerationResult(
        total: 0,
        generated: 0,
        alreadyPresent: true,
      );
    }

    final picked = _engine.sampleNetizens(pool);
    if (picked.isEmpty) {
      return const CommentGenerationResult(total: 0, generated: 0);
    }

    final job = await _jobs.createJob(
      articleId: articleId,
      trigger: trigger,
      pickedNetizenIds: picked.map((n) => n.id).toList(),
    );

    return _engine.runJob(
      jobId: job.id,
      owner: _leaseOwner,
      article: article,
      pool: pool,
      providers: providers,
      models: models,
      llmRepo: llmRepo,
      llmClient: llmClient,
      forceMock: forceMock,
      onProgress: onProgress,
    );
  }

  /// UI retry: reopen failed job, or create a new one if comments were cleared.
  Future<CommentGenerationResult> retryGeneration(
    String articleId, {
    required CommentTrigger trigger,
    required List<Netizen> pool,
    required Article article,
    required List<LlmProvider> providers,
    required List<LlmModel> models,
    required LlmProviderRepository llmRepo,
    required LlmClient llmClient,
    bool forceMock = false,
    void Function(CommentGenerationProgress progress)? onProgress,
  }) async {
    if (trigger == CommentTrigger.off) {
      return const CommentGenerationResult(total: 0, generated: 0);
    }

    final open = await _jobs.getOpenJobForArticle(articleId);
    if (open != null) {
      return _engine.runJob(
        jobId: open.id,
        owner: _leaseOwner,
        article: article,
        pool: pool,
        providers: providers,
        models: models,
        llmRepo: llmRepo,
        llmClient: llmClient,
        forceMock: forceMock,
        onProgress: onProgress,
      );
    }

    // Latest failed job for article?
    final failedRows =
        await (_db.select(_db.commentJobs)
              ..where(
                (t) =>
                    t.articleId.equals(articleId) &
                    t.status.equals(
                      commentJobStatusToDb(CommentJobStatus.failed),
                    ),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .get();
    if (failedRows.isNotEmpty) {
      final reopened = await _jobs.reopenFailedJob(failedRows.first.id);
      if (reopened != null) {
        return _engine.runJob(
          jobId: reopened.id,
          owner: _leaseOwner,
          article: article,
          pool: pool,
          providers: providers,
          models: models,
          llmRepo: llmRepo,
          llmClient: llmClient,
          forceMock: forceMock,
          onProgress: onProgress,
        );
      }
    }

    // No job / already completed with empty UI → normal ensure path.
    return ensureGenerated(
      articleId,
      trigger: trigger,
      pool: pool,
      article: article,
      providers: providers,
      models: models,
      llmRepo: llmRepo,
      llmClient: llmClient,
      forceMock: forceMock,
      onProgress: onProgress,
    );
  }

  @override
  Future<CommentReplyResult> addUserReply({
    required String articleId,
    required String parentId,
    required String text,
    required List<Netizen> pool,
    required Article article,
    List<LlmProvider> providers = const [],
    List<LlmModel> models = const [],
    LlmProviderRepository? llmRepo,
    LlmClient? llmClient,
    bool forceMock = false,
    void Function(String netizenName, LlmQueuePhase phase)? onProgress,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const CommentReplyResult();

    final parent = await (_db.select(
      _db.comments,
    )..where((t) => t.id.equals(parentId))).getSingleOrNull();
    if (parent == null) return const CommentReplyResult();

    final now = DateTime.now();
    final userId = 'c_u_${now.microsecondsSinceEpoch}';
    await _db
        .into(_db.comments)
        .insert(
          CommentsCompanion.insert(
            id: userId,
            articleId: articleId,
            authorType: 'user',
            parentId: Value(parentId),
            content: trimmed,
            createdAt: now,
          ),
        );

    await _warmEvents?.add(
      MeEvent(
        id: 'e-comment-${now.millisecondsSinceEpoch}',
        type: MeEventType.chat,
        createdAt: now,
        title: '在《${_short(article.title)}》下评论了',
        subtitle: trimmed.length > 40
            ? '${trimmed.substring(0, 40)}…'
            : trimmed,
        articleId: articleId,
      ),
    );

    final replyNetizenId = parent.netizenId;
    if (replyNetizenId == null) return const CommentReplyResult();
    Netizen? netizen;
    for (final n in pool) {
      if (n.id == replyNetizenId) {
        netizen = n;
        break;
      }
    }
    if (netizen == null || !netizen.isEnabled) {
      return const CommentReplyResult();
    }

    final useMock = forceMock || kUseMockComments;
    final reply = await _replyContent(
      netizen: netizen,
      article: article,
      parentComment: parent.content,
      userText: trimmed,
      useMock: useMock,
      providers: providers,
      models: models,
      llmRepo: llmRepo,
      llmClient: llmClient,
      onQueuePhase: (phase) => onProgress?.call(netizen!.name, phase),
    );
    if (reply == null || reply.trim().isEmpty) {
      return CommentReplyResult(netizenName: netizen.name);
    }

    await _db
        .into(_db.comments)
        .insert(
          CommentsCompanion.insert(
            id: 'c_nr_${now.microsecondsSinceEpoch}',
            articleId: articleId,
            authorType: 'netizen',
            netizenId: Value(netizen.id),
            parentId: Value(userId),
            content: reply.trim(),
            createdAt: now.add(const Duration(milliseconds: 350)),
          ),
        );
    return CommentReplyResult(netizenName: netizen.name, replied: true);
  }

  Future<String?> _replyContent({
    required Netizen netizen,
    required Article article,
    required String parentComment,
    required String userText,
    required bool useMock,
    required List<LlmProvider> providers,
    required List<LlmModel> models,
    LlmProviderRepository? llmRepo,
    LlmClient? llmClient,
    void Function(LlmQueuePhase phase)? onQueuePhase,
  }) async {
    if (useMock) {
      return '（mock）${netizen.name}：收到「${_short(userText, 18)}」';
    }
    if (llmClient == null || llmRepo == null) return null;

    final cfg = await resolveLlmConfigForNetizen(
      netizen: netizen,
      llmRepo: llmRepo,
      providers: providers,
      allModels: models,
    );
    if (cfg == null) return null;

    try {
      final text = await llmClient.complete(
        netizenReplyMessages(
          netizen: netizen,
          article: article,
          parentNetizenComment: parentComment,
          userText: userText,
        ),
        cfg.copyWith(onQueuePhase: onQueuePhase),
      );
      final cleaned = sanitizeLlmCommentText(text);
      if (cleaned.isNotEmpty) return cleaned;
      return null;
    } on LlmException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static String _short(String s, [int n = 12]) {
    if (s.length <= n) return s;
    return '${s.substring(0, n)}…';
  }

  Comment _map(CommentRow row) {
    return Comment(
      id: row.id,
      articleId: row.articleId,
      authorType: row.authorType == 'user'
          ? CommentAuthorType.user
          : CommentAuthorType.netizen,
      netizenId: row.netizenId,
      parentId: row.parentId,
      content: row.content,
      createdAt: row.createdAt,
    );
  }
}

import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/config/app_flags.dart';
import '../db/app_database.dart';
import '../llm/llm_client.dart';
import '../llm/llm_prompt.dart';
import '../llm/llm_resolve.dart';
import '../models/models.dart';
import 'comment_repository.dart';
import 'llm_provider_repository.dart';
import 'warm_event_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._db, {WarmEventRepository? warmEvents})
    : _warmEvents = warmEvents;

  final AppDatabase _db;
  final WarmEventRepository? _warmEvents;
  final _rng = Random();

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
    await _db.delete(_db.comments).go();
  }

  @override
  Future<void> clearForArticle(String articleId) async {
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

    final existing = await (_db.select(
      _db.comments,
    )..where((t) => t.articleId.equals(articleId))).get();
    if (existing.isNotEmpty) {
      return const CommentGenerationResult(
        total: 0,
        generated: 0,
        alreadyPresent: true,
      );
    }

    final enabled = pool.where((n) => n.isEnabled).toList();
    if (enabled.isEmpty) {
      return const CommentGenerationResult(total: 0, generated: 0);
    }

    final picked = <Netizen>[];
    for (final n in enabled) {
      if (_rng.nextDouble() < n.weight.clamp(0.0, 1.0)) {
        picked.add(n);
      }
    }
    if (picked.isEmpty) {
      picked.add(_weightedChoice(enabled));
    }

    final useMock = forceMock || kUseMockComments;
    final now = DateTime.now();
    var generated = 0;
    await Future.wait([
      for (final entry in picked.indexed)
        () async {
          final (index, n) = entry;
          var reported = false;
          final content = await _topLevelContent(
            netizen: n,
            article: article,
            useMock: useMock,
            providers: providers,
            models: models,
            llmRepo: llmRepo,
            llmClient: llmClient,
            onQueuePhase: (phase) {
              reported = true;
              onProgress?.call(
                CommentGenerationProgress(
                  netizenName: n.name,
                  phase: phase,
                  total: picked.length,
                ),
              );
            },
          );
          // No Key / unresolved → skip (do not plant mock/error filler).
          if (content == null || content.trim().isEmpty) {
            if (!reported) {
              onProgress?.call(
                CommentGenerationProgress(
                  netizenName: n.name,
                  phase: LlmQueuePhase.failed,
                  total: picked.length,
                ),
              );
            }
            return;
          }

          final id =
              'c_${articleId}_${n.id}_${now.microsecondsSinceEpoch}_$index';
          await _db
              .into(_db.comments)
              .insert(
                CommentsCompanion.insert(
                  id: id,
                  articleId: articleId,
                  authorType: 'netizen',
                  netizenId: Value(n.id),
                  content: content.trim(),
                  // Preserve actual arrival order when concurrency > 1.
                  createdAt: DateTime.now(),
                ),
              );
          generated++;
        }(),
    ]);
    return CommentGenerationResult(total: picked.length, generated: generated);
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

  /// Returns null when generation is skipped (no Key / not configured).
  Future<String?> _topLevelContent({
    required Netizen netizen,
    required Article article,
    required bool useMock,
    required List<LlmProvider> providers,
    required List<LlmModel> models,
    LlmProviderRepository? llmRepo,
    LlmClient? llmClient,
    void Function(LlmQueuePhase phase)? onQueuePhase,
  }) async {
    if (useMock) {
      return _devMockTopLevel(netizen, article);
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
        netizenTopLevelMessages(netizen: netizen, article: article),
        cfg.copyWith(onQueuePhase: onQueuePhase),
      );
      if (text.trim().isNotEmpty) return text.trim();
      return null;
    } on LlmException {
      return null;
    } catch (_) {
      return null;
    }
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
      return _devMockReply(netizen, userText);
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
      if (text.trim().isNotEmpty) return text.trim();
      return null;
    } on LlmException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Netizen _weightedChoice(List<Netizen> list) {
    final positive = list.where((n) => n.weight > 0).toList();
    final pool = positive.isEmpty ? list : positive;
    final total = pool.fold<double>(0, (s, n) => s + n.weight.clamp(0.01, 1.0));
    var r = _rng.nextDouble() * total;
    for (final n in pool) {
      r -= n.weight.clamp(0.01, 1.0);
      if (r <= 0) return n;
    }
    return pool.last;
  }

  /// Only used when [kUseMockComments] / forceMock (tests / offline demo).
  String _devMockTopLevel(Netizen n, Article article) {
    final summary = article.summary.isEmpty ? article.title : article.summary;
    return '「${n.name}」${n.styleLabel ?? ""}：${_short(summary, 64)}';
  }

  String _devMockReply(Netizen n, String userText) {
    return '（mock）${n.name}：收到「${_short(userText, 18)}」';
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

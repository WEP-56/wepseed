import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/comments/comment_generation_engine.dart';
import 'package:wepseed/data/comments/comment_job_models.dart';
import 'package:wepseed/data/db/app_database.dart';
import 'package:wepseed/data/llm/llm_client.dart';
import 'package:wepseed/data/models/models.dart';
import 'package:wepseed/data/repositories/comment_job_repository_impl.dart';
import 'package:wepseed/data/repositories/comment_repository_impl.dart';
import 'package:wepseed/data/repositories/llm_provider_repository.dart';

class _FakeLlm implements LlmClient {
  _FakeLlm(this.replies);

  final Map<String, String> replies;
  final calls = <String>[];

  @override
  Future<String> complete(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async {
    final key = config.modelId;
    calls.add(key);
    config.onQueuePhase?.call(LlmQueuePhase.queued);
    config.onQueuePhase?.call(LlmQueuePhase.running);
    final text = replies[key] ?? 'ok-$key';
    config.onQueuePhase?.call(LlmQueuePhase.completed);
    return text;
  }

  @override
  Stream<String> completeStream(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async* {
    yield await complete(messages, config);
  }
}

class _StubLlmRepo implements LlmProviderRepository {
  _StubLlmRepo(this.providers, this.models, this.keys);

  final List<LlmProvider> providers;
  final List<LlmModel> models;
  final Map<String, String> keys;

  @override
  Stream<List<LlmProvider>> watchProviders() => Stream.value(providers);

  @override
  Future<List<LlmProvider>> getProviders() async => providers;

  @override
  Future<void> upsertProvider(LlmProvider provider, {String? apiKey}) async {}

  @override
  Future<void> deleteProvider(String id) async {}

  @override
  Stream<List<LlmModel>> watchModels(String providerId) =>
      Stream.value(models.where((m) => m.providerId == providerId).toList());

  @override
  Future<List<LlmModel>> getModels(String providerId) async =>
      models.where((m) => m.providerId == providerId).toList();

  @override
  Future<List<LlmModel>> getAllModels() async => models;

  @override
  Future<void> upsertModel(LlmModel model) async {}

  @override
  Future<void> deleteModel(String id) async {}

  @override
  Future<String?> getApiKey(String providerId) async => keys[providerId];

  @override
  Future<void> setApiKey(String providerId, String? key) async {}

  @override
  Future<bool> hasApiKey(String providerId) async =>
      keys[providerId]?.isNotEmpty == true;
}

void main() {
  late AppDatabase db;
  late CommentJobRepositoryImpl jobs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = CommentJobRepositoryImpl(db);
  });

  tearDown(() => db.close());

  final article = Article(
    id: 'a1',
    source: const FeedSource(id: 'f1', name: 'Src', domain: 'ex.com'),
    title: 'Hello',
    summary: 'Summary text for tests',
    body: 'Body',
    publishedAt: DateTime(2026, 7, 1),
  );

  final netizens = [
    Netizen(
      id: 'n1',
      name: '甲',
      systemHint: 'h',
      weight: 1,
      providerId: 'p1',
      modelId: 'm1',
    ),
    Netizen(
      id: 'n2',
      name: '乙',
      systemHint: 'h',
      weight: 1,
      providerId: 'p1',
      modelId: 'm2',
    ),
  ];

  final providers = [
    const LlmProvider(
      id: 'p1',
      name: 'P',
      protocol: LlmProtocol.openaiChatCompletions,
      baseUrl: 'https://example.com/v1',
    ),
  ];

  final models = [
    const LlmModel(
      id: 'm1',
      providerId: 'p1',
      modelId: 'model-a',
      displayName: 'A',
      isDefault: true,
    ),
    const LlmModel(
      id: 'm2',
      providerId: 'p1',
      modelId: 'model-b',
      displayName: 'B',
    ),
  ];

  test('create job + items; claim lease exclusivity', () async {
    final job = await jobs.createJob(
      articleId: 'a1',
      trigger: CommentTrigger.onOpenComments,
      pickedNetizenIds: ['n1', 'n2'],
    );
    expect(job.status, CommentJobStatus.pending);
    final items = await jobs.getItems(job.id);
    expect(items, hasLength(2));
    expect(items.every((i) => i.status == CommentJobItemStatus.pending), isTrue);

    final claimed = await jobs.claimJob(jobId: job.id, owner: 'ui');
    expect(claimed?.status, CommentJobStatus.running);
    expect(claimed?.leaseOwner, 'ui');

    final blocked = await jobs.claimJob(jobId: job.id, owner: 'wm');
    expect(blocked, isNull);
  });

  test('partial resume only generates missing netizens', () async {
    final job = await jobs.createJob(
      articleId: 'a1',
      trigger: CommentTrigger.onOpenComments,
      pickedNetizenIds: ['n1', 'n2'],
    );
    // Pretend n1 already wrote a comment (process died mid-job).
    await db
        .into(db.comments)
        .insert(
          CommentsCompanion.insert(
            id: 'c_existing',
            articleId: 'a1',
            authorType: 'netizen',
            netizenId: const Value('n1'),
            content: 'already here',
            createdAt: DateTime.now(),
          ),
        );

    final llm = _FakeLlm({'model-a': 'from a', 'model-b': 'from b'});
    final engine = CommentGenerationEngine(db: db, jobs: jobs);
    final llmRepo = _StubLlmRepo(providers, models, {'p1': 'sk-test'});

    final result = await engine.runJob(
      jobId: job.id,
      owner: 'ui',
      article: article,
      pool: netizens,
      providers: providers,
      models: models,
      llmRepo: llmRepo,
      llmClient: llm,
    );

    expect(result.generated, 2);
    expect(result.total, 2);
    // Only model-b should have been called (n2); n1 reused existing comment.
    expect(llm.calls, ['model-b']);

    final comments = await (db.select(
      db.comments,
    )..where((t) => t.articleId.equals('a1'))).get();
    expect(comments, hasLength(2));

    final done = await jobs.getJob(job.id);
    expect(done?.status, CommentJobStatus.completed);
  });

  test('legacy comments without job short-circuit ensureGenerated', () async {
    await db
        .into(db.comments)
        .insert(
          CommentsCompanion.insert(
            id: 'c_old',
            articleId: 'a1',
            authorType: 'netizen',
            netizenId: const Value('n1'),
            content: 'legacy',
            createdAt: DateTime.now(),
          ),
        );

    final repo = CommentRepositoryImpl(db, jobs: jobs, leaseOwner: 'ui');
    final llm = _FakeLlm({});
    final result = await repo.ensureGenerated(
      'a1',
      trigger: CommentTrigger.onOpenComments,
      pool: netizens,
      article: article,
      providers: providers,
      models: models,
      llmRepo: _StubLlmRepo(providers, models, {'p1': 'sk'}),
      llmClient: llm,
    );
    expect(result.alreadyPresent, isTrue);
    expect(llm.calls, isEmpty);
  });

  test('releaseExpiredLeases returns job to pending', () async {
    final job = await jobs.createJob(
      articleId: 'a1',
      trigger: CommentTrigger.onBrowse,
      pickedNetizenIds: ['n1'],
    );
    await jobs.claimJob(
      jobId: job.id,
      owner: 'dead',
      lease: const Duration(milliseconds: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final n = await jobs.releaseExpiredLeases(
      now: DateTime.now().add(const Duration(seconds: 1)),
    );
    expect(n, 1);
    final again = await jobs.getJob(job.id);
    expect(again?.status, CommentJobStatus.pending);
    expect(again?.leaseOwner, isNull);
  });

  test('schema exposes comment job tables', () async {
    // Touch tables so migration path is exercised on memory DB.
    expect(db.commentJobs.actualTableName, 'comment_jobs');
    expect(db.commentJobItems.actualTableName, 'comment_job_items');
  });
}

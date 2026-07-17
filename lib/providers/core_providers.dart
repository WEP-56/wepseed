import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_flags.dart';
import '../data/db/app_database.dart';
import '../data/llm/http_llm_client.dart';
import '../data/llm/scheduled_llm_client.dart';
import '../data/llm/llm_client.dart';
import '../data/repositories/article_repository.dart';
import '../data/repositories/comment_job_repository.dart';
import '../data/repositories/comment_job_repository_impl.dart';
import '../data/repositories/comment_repository.dart';
import '../data/repositories/comment_repository_impl.dart';
import '../data/repositories/drift_article_repository.dart';
import '../data/repositories/drift_feed_repository.dart';
import '../data/repositories/drift_warm_event_repository.dart';
import '../data/repositories/feed_repository.dart';
import '../data/repositories/llm_provider_repository.dart';
import '../data/repositories/llm_provider_repository_impl.dart';
import '../data/repositories/media_chat_repository.dart';
import '../data/repositories/media_chat_repository_impl.dart';
import '../data/repositories/mock_article_repository.dart';
import '../data/repositories/mock_feed_repository.dart';
import '../data/repositories/mock_warm_event_repository.dart';
import '../data/repositories/netizen_repository.dart';
import '../data/repositories/netizen_repository_impl.dart';
import '../data/repositories/secure_settings_impl.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/repositories/warm_event_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureSettingsProvider = Provider<SecureSettings>((ref) {
  return SecureSettingsImpl();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider));
});

final llmProviderRepositoryProvider = Provider<LlmProviderRepository>((ref) {
  return LlmProviderRepositoryImpl(
    ref.watch(databaseProvider),
    ref.watch(secureSettingsProvider),
  );
});

final netizenRepositoryProvider = Provider<NetizenRepository>((ref) {
  return NetizenRepositoryImpl(ref.watch(databaseProvider));
});

final warmEventRepositoryProvider = Provider<WarmEventRepository>((ref) {
  if (kUseMockFeed) {
    final repo = MockWarmEventRepository();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return DriftWarmEventRepository(ref.watch(databaseProvider));
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  if (kUseMockFeed) {
    final repo = MockFeedRepository();
    ref.onDispose(repo.dispose);
    return repo;
  }
  final repo = DriftFeedRepository(ref.watch(databaseProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final warm = ref.watch(warmEventRepositoryProvider);
  if (kUseMockFeed) {
    final repo = MockArticleRepository(warmEvents: warm);
    ref.onDispose(repo.dispose);
    return repo;
  }
  final repo = DriftArticleRepository(
    ref.watch(databaseProvider),
    warmEvents: warm,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

final commentJobRepositoryProvider = Provider<CommentJobRepository>((ref) {
  return CommentJobRepositoryImpl(ref.watch(databaseProvider));
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final warm = ref.watch(warmEventRepositoryProvider);
  final jobs = ref.watch(commentJobRepositoryProvider);
  return CommentRepositoryImpl(
    ref.watch(databaseProvider),
    warmEvents: warm,
    jobs: jobs,
  );
});

final mediaChatRepositoryProvider = Provider<MediaChatRepository>((ref) {
  return MediaChatRepositoryImpl(ref.watch(databaseProvider));
});

/// Phase D real LLM HTTP client.
final llmClientProvider = Provider<LlmClient>((ref) {
  final client = ScheduledLlmClient(HttpLlmClient());
  ref.onDispose(client.dispose);
  return client;
});

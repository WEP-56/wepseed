import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/feed_filter.dart';
import '../data/models/models.dart';
import '../data/repositories/article_repository.dart';
import 'core_providers.dart';
import 'settings_provider.dart';

final articlesProvider = StreamProvider<List<Article>>((ref) {
  return ref.watch(articleRepositoryProvider).watchTimeline();
});

final feedFilterProvider = Provider<FeedFilter>((ref) {
  return ref.watch(settingsProvider).value?.feedFilter ?? const FeedFilter();
});

/// New-page timeline with persisted [FeedFilter] applied.
final filteredArticlesProvider = Provider<AsyncValue<List<Article>>>((ref) {
  final articles = ref.watch(articlesProvider);
  final filter = ref.watch(feedFilterProvider);
  final readIds = ref.watch(readIdsProvider).value ?? const <String>{};
  return articles.whenData(
    (list) => applyFeedFilter(list, filter: filter, readIds: readIds),
  );
});

final articlesByFeedProvider = StreamProvider.family<List<Article>, String>((
  ref,
  feedId,
) {
  return ref.watch(articleRepositoryProvider).watchTimeline(feedId: feedId);
});

final articleByIdProvider = FutureProvider.family<Article?, String>((
  ref,
  id,
) async {
  // Re-resolve when timeline updates so detail page stays fresh.
  ref.watch(articlesProvider);
  return ref.watch(articleRepositoryProvider).get(id);
});

final unreadCountsProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(articleRepositoryProvider).watchUnreadCounts();
});

final readIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(articleRepositoryProvider).watchReadIds();
});

final bookmarkedIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(articleRepositoryProvider).watchBookmarkedIds();
});

final bookmarkedArticlesProvider = StreamProvider<List<Article>>((ref) {
  return ref.watch(articleRepositoryProvider).watchBookmarkedArticles();
});

final isReadProvider = Provider.family<bool, String>((ref, id) {
  final ids = ref.watch(readIdsProvider).value;
  if (ids != null) return ids.contains(id);
  return ref.watch(articleRepositoryProvider).isRead(id);
});

final isBookmarkedProvider = Provider.family<bool, String>((ref, id) {
  final ids = ref.watch(bookmarkedIdsProvider).value;
  if (ids != null) return ids.contains(id);
  return ref.watch(articleRepositoryProvider).isBookmarked(id);
});

final articleActionsProvider = Provider<ArticleActions>((ref) {
  return ArticleActions(ref);
});

class ArticleActions {
  ArticleActions(this._ref);

  final Ref _ref;

  ArticleRepository get _repo => _ref.read(articleRepositoryProvider);

  Future<void> markRead(String id) => _repo.markRead(id);

  Future<void> markSourceSeen(String feedId) => _repo.markSourceSeen(feedId);

  Future<void> toggleBookmark(String id) async {
    final bookmarked = _repo.isBookmarked(id);
    await _repo.setBookmarked(id, !bookmarked);
  }

  Future<void> setBookmarked(String id, bool value) =>
      _repo.setBookmarked(id, value);
}

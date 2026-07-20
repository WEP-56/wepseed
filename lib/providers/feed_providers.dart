import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../data/repositories/feed_repository.dart';
import '../data/rss/rss_refresh_config.dart';
import 'core_providers.dart';

final feedsProvider = StreamProvider<List<FeedSource>>((ref) {
  return ref.watch(feedRepositoryProvider).watchFeeds();
});

final feedByIdProvider = Provider.family<FeedSource?, String>((ref, id) {
  final feeds = ref.watch(feedsProvider).value ?? const [];
  for (final f in feeds) {
    if (f.id == id) return f;
  }
  return null;
});

final feedActionsProvider = Provider<FeedActions>((ref) {
  return FeedActions(ref);
});

class FeedActions {
  FeedActions(this._ref);

  final Ref _ref;

  FeedRepository get _repo => _ref.read(feedRepositoryProvider);

  Future<void> addFeed(String url) => _repo.addFeed(url);

  Future<void> removeFeed(String id) => _repo.removeFeed(id);

  Future<void> setPaused(String id, bool paused) => _repo.setPaused(id, paused);

  Future<void> refreshFeed(String id) => _repo.refreshFeed(id);

  Future<void> refreshAll({
    bool wifiOnly = false,
    Iterable<String>? feedIds,
    RssRefreshMode mode = RssRefreshMode.foreground,
  }) =>
      _repo.refreshAll(wifiOnly: wifiOnly, feedIds: feedIds, mode: mode);

  Future<void> importOpml(String xml) => _repo.importOpml(xml);

  Future<String> exportOpml() => _repo.exportOpml();
}

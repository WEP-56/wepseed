import '../models/models.dart';

abstract class FeedRepository {
  Stream<List<FeedSource>> watchFeeds();
  Future<FeedSource?> getFeed(String id);
  Future<void> addFeed(String url);
  Future<void> removeFeed(String id);
  Future<void> setPaused(String id, bool paused);
  Future<void> refreshFeed(String id);

  /// Refresh non-paused feeds. When [feedIds] is non-null and non-empty,
  /// only those ids are refreshed (still skips paused).
  Future<void> refreshAll({bool wifiOnly = false, Iterable<String>? feedIds});
  Future<void> importOpml(String xml);
  Future<String> exportOpml();
}

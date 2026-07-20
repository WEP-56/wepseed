import '../models/models.dart';
import '../rss/rss_refresh_config.dart';

abstract class FeedRepository {
  Stream<List<FeedSource>> watchFeeds();
  Future<FeedSource?> getFeed(String id);
  Future<void> addFeed(String url);
  Future<void> removeFeed(String id);
  Future<void> setPaused(String id, bool paused);
  Future<void> refreshFeed(String id);

  /// Refresh non-paused feeds. When [feedIds] is non-null and non-empty,
  /// only those ids are refreshed (still skips paused).
  ///
  /// [mode] selects concurrency pool + HTTP timeout (foreground vs background).
  Future<void> refreshAll({
    bool wifiOnly = false,
    Iterable<String>? feedIds,
    RssRefreshMode mode = RssRefreshMode.foreground,
  });
  Future<void> importOpml(String xml);
  Future<String> exportOpml();
}

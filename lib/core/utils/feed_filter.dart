import '../../data/models/models.dart';

/// Client-side New-stream filter. Pure; pass [now] in tests.
List<Article> applyFeedFilter(
  List<Article> articles, {
  required FeedFilter filter,
  required Set<String> readIds,
  DateTime? now,
}) {
  if (filter.isDefault) return articles;

  final clock = now ?? DateTime.now();
  final restrictFeeds = filter.feedIds.isNotEmpty;

  return articles
      .where((a) {
        if (restrictFeeds && !filter.feedIds.contains(a.source.id)) {
          return false;
        }
        if (filter.onlyUnread && readIds.contains(a.id)) {
          return false;
        }
        if (filter.onlyToday) {
          final p = a.publishedAt;
          if (p.year != clock.year ||
              p.month != clock.month ||
              p.day != clock.day) {
            return false;
          }
        }
        return true;
      })
      .toList(growable: false);
}

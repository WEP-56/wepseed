import '../models/models.dart';

abstract class ArticleRepository {
  Stream<List<Article>> watchTimeline({String? feedId});
  Future<Article?> get(String id);
  Future<void> markRead(String id);
  Future<void> setBookmarked(String id, bool value);
  Stream<Map<String, int>> watchUnreadCounts();
  Future<void> markSourceSeen(String feedId);
  Stream<Set<String>> watchReadIds();
  Stream<Set<String>> watchBookmarkedIds();

  /// Bookmarked articles, newest bookmark first.
  Stream<List<Article>> watchBookmarkedArticles();

  bool isRead(String id);
  bool isBookmarked(String id);
}

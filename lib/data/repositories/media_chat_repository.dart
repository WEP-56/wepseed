import '../models/models.dart';

abstract class MediaChatRepository {
  Stream<List<MediaChatMessage>> watchForArticle(String articleId);
  Future<List<MediaChatMessage>> getForArticle(String articleId);

  /// Persists the user message and a pending assistant placeholder together.
  Future<MediaChatMessage> enqueue(String articleId, String content);
  Future<void> complete(String id, String content);
  Future<void> fail(String id, String error);
}

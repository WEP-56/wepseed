import '../models/models.dart';

abstract class WarmEventRepository {
  Stream<List<MeEvent>> watch();
  Future<void> add(MeEvent event);

  /// Evaluate local warmth rules after a user explicitly opens an article.
  Future<void> recordRead(Article article, DateTime at);
}

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'media_chat_repository.dart';

class MediaChatRepositoryImpl implements MediaChatRepository {
  MediaChatRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<MediaChatMessage>> watchForArticle(String articleId) {
    return (_db.select(_db.mediaChatMessages)
          ..where((t) => t.articleId.equals(articleId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  @override
  Future<List<MediaChatMessage>> getForArticle(String articleId) async {
    final rows =
        await (_db.select(_db.mediaChatMessages)
              ..where((t) => t.articleId.equals(articleId))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map(_map).toList();
  }

  @override
  Future<MediaChatMessage> enqueue(String articleId, String content) async {
    final now = DateTime.now();
    final base = now.microsecondsSinceEpoch;
    final userId = 'media-user-$base';
    final assistantId = 'media-assistant-${base + 1}';
    await _db.transaction(() async {
      await _db
          .into(_db.mediaChatMessages)
          .insert(
            MediaChatMessagesCompanion.insert(
              id: userId,
              articleId: articleId,
              role: 'user',
              content: Value(content),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db
          .into(_db.mediaChatMessages)
          .insert(
            MediaChatMessagesCompanion.insert(
              id: assistantId,
              articleId: articleId,
              role: 'assistant',
              status: const Value('pending'),
              createdAt: now.add(const Duration(microseconds: 1)),
              updatedAt: now,
            ),
          );
    });
    return MediaChatMessage(
      id: assistantId,
      articleId: articleId,
      role: 'assistant',
      content: '',
      status: MediaChatMessageStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> complete(String id, String content) async {
    final now = DateTime.now();
    await (_db.update(
      _db.mediaChatMessages,
    )..where((t) => t.id.equals(id))).write(
      MediaChatMessagesCompanion(
        content: Value(content),
        status: const Value('completed'),
        error: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> fail(String id, String error) async {
    await (_db.update(
      _db.mediaChatMessages,
    )..where((t) => t.id.equals(id))).write(
      MediaChatMessagesCompanion(
        status: const Value('failed'),
        error: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  MediaChatMessage _map(MediaChatMessageRow row) => MediaChatMessage(
    id: row.id,
    articleId: row.articleId,
    role: row.role,
    content: row.content,
    status: mediaChatMessageStatusFromDb(row.status),
    error: row.error,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

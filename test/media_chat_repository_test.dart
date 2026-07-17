import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/db/app_database.dart';
import 'package:wepseed/data/models/models.dart';
import 'package:wepseed/data/repositories/media_chat_repository_impl.dart';

void main() {
  late AppDatabase db;
  late MediaChatRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MediaChatRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('persists user prompt and pending assistant placeholder', () async {
    final pending = await repository.enqueue('article-audio', '这期的重点？');
    final messages = await repository.getForArticle('article-audio');

    expect(messages, hasLength(2));
    expect(messages.first.role, 'user');
    expect(messages.first.content, '这期的重点？');
    expect(pending.status, MediaChatMessageStatus.pending);
    expect(messages.last.status, MediaChatMessageStatus.pending);
  });

  test(
    'completed and failed replies remain available after reopening',
    () async {
      final completed = await repository.enqueue('article-video', '讲了什么？');
      await repository.complete(completed.id, '主要讨论了三个方面。');
      final failed = await repository.enqueue('article-video', '还有吗？');
      await repository.fail(failed.id, '网络暂时不可用');

      final messages = await repository.getForArticle('article-video');
      expect(messages[1].status, MediaChatMessageStatus.completed);
      expect(messages[1].content, '主要讨论了三个方面。');
      expect(messages[3].status, MediaChatMessageStatus.failed);
      expect(messages[3].error, '网络暂时不可用');
    },
  );
}

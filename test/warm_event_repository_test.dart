import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/db/app_database.dart';
import 'package:wepseed/data/models/models.dart';
import 'package:wepseed/data/repositories/drift_warm_event_repository.dart';

void main() {
  late AppDatabase db;
  late DriftWarmEventRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftWarmEventRepository(db);
  });

  tearDown(() => db.close());

  test('warm events persist and dwell deduplicates per article/day', () async {
    final day = DateTime(2026, 7, 16, 12);
    await repository.add(
      MeEvent(
        id: 'dwell-1',
        type: MeEventType.dwell,
        createdAt: day,
        title: '停了一会儿',
        subtitle: '文章',
        articleId: 'a1',
      ),
    );
    await repository.add(
      MeEvent(
        id: 'dwell-2',
        type: MeEventType.dwell,
        createdAt: day.add(const Duration(hours: 1)),
        title: '又停了一会儿',
        subtitle: '文章',
        articleId: 'a1',
      ),
    );

    final events = await repository.watch().first;
    expect(events, hasLength(1));
    expect(events.single.id, 'dwell-1');
  });

  test('read evaluation creates binge, streak and night events once', () async {
    final at = DateTime(2026, 7, 16, 1, 30);
    await db
        .into(db.feeds)
        .insert(
          FeedsCompanion.insert(
            id: 'f1',
            title: '测试源',
            url: 'https://example.com/feed',
            createdAt: at,
          ),
        );
    for (var i = 0; i < 12; i++) {
      final readAt = i < 10
          ? at.add(Duration(minutes: i))
          : at.subtract(Duration(days: i - 9));
      await db
          .into(db.articles)
          .insert(
            ArticlesCompanion.insert(
              id: 'a$i',
              feedId: 'f1',
              guid: 'g$i',
              title: '文章 $i',
              publishedAt: readAt,
              fetchedAt: readAt,
              isRead: const Value(true),
              readAt: Value(readAt),
            ),
          );
    }
    final article = Article(
      id: 'a0',
      source: const FeedSource(id: 'f1', name: '测试源', domain: 'example.com'),
      title: '文章 0',
      summary: '',
      body: '',
      publishedAt: at,
    );

    await repository.recordRead(article, at);
    await repository.recordRead(article, at.add(const Duration(minutes: 5)));

    final events = await repository.watch().first;
    expect(events.where((e) => e.type == MeEventType.nightOwl), hasLength(1));
    expect(events.where((e) => e.type == MeEventType.binge), hasLength(1));
    expect(events.where((e) => e.type == MeEventType.streak), hasLength(1));
  });
}

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'warm_event_repository.dart';

class DriftWarmEventRepository implements WarmEventRepository {
  DriftWarmEventRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<MeEvent>> watch() {
    return (_db.select(_db.warmEvents)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  @override
  Future<void> add(MeEvent event) async {
    if (_isWarm(event.type) && await _hasSameDayEvent(event)) return;
    await _db
        .into(_db.warmEvents)
        .insertOnConflictUpdate(
          WarmEventsCompanion.insert(
            id: event.id,
            type: _typeToDb(event.type),
            title: event.title,
            subtitle: event.subtitle,
            articleId: Value(event.articleId),
            createdAt: event.createdAt,
          ),
        );
  }

  @override
  Future<void> remove(String id) async {
    await (_db.delete(_db.warmEvents)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> removeByTypes(Set<MeEventType> types) async {
    if (types.isEmpty) return;
    final names = types.map(_typeToDb).toList();
    await (_db.delete(_db.warmEvents)..where((t) => t.type.isIn(names))).go();
  }

  @override
  Future<void> recordRead(Article article, DateTime at) async {
    if (at.hour < 5) {
      await add(
        MeEvent(
          id: 'warm-night-${_dayKey(at)}',
          type: MeEventType.nightOwl,
          createdAt: at,
          title: '夜深了，还在读',
          subtitle: article.title,
          articleId: article.id,
        ),
      );
    }

    final dayStart = DateTime(at.year, at.month, at.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final todayReads =
        await (_db.select(_db.articles)..where(
              (t) =>
                  t.readAt.isBiggerOrEqualValue(dayStart) &
                  t.readAt.isSmallerThanValue(dayEnd),
            ))
            .get();
    if (todayReads.length >= 10) {
      await add(
        MeEvent(
          id: 'warm-binge-${_dayKey(at)}',
          type: MeEventType.binge,
          createdAt: at,
          title: '今天读得有点停不下来',
          subtitle: '已经打开 ${todayReads.length} 篇文章',
          articleId: article.id,
        ),
      );
    }

    final sameFeedReads =
        await (_db.select(_db.articles)..where(
              (t) => t.feedId.equals(article.source.id) & t.readAt.isNotNull(),
            ))
            .get();
    final days = sameFeedReads.where((row) => row.readAt != null).map((row) {
      final value = row.readAt!;
      return DateTime(value.year, value.month, value.day);
    }).toSet();
    var streak = 0;
    var cursor = dayStart;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (streak >= 3) {
      await add(
        MeEvent(
          id: 'warm-streak-${article.source.id}-${_dayKey(at)}',
          type: MeEventType.streak,
          createdAt: at,
          title: '连续 $streak 天读 ${article.source.name}',
          subtitle: article.title,
          articleId: article.id,
        ),
      );
    }
  }

  Future<bool> _hasSameDayEvent(MeEvent event) async {
    final start = DateTime(
      event.createdAt.year,
      event.createdAt.month,
      event.createdAt.day,
    );
    final end = start.add(const Duration(days: 1));
    final rows =
        await (_db.select(_db.warmEvents)..where(
              (t) =>
                  t.type.equals(_typeToDb(event.type)) &
                  t.createdAt.isBiggerOrEqualValue(start) &
                  t.createdAt.isSmallerThanValue(end),
            ))
            .get();
    if (event.type == MeEventType.dwell) {
      return rows.any((row) => row.articleId == event.articleId);
    }
    if (event.type == MeEventType.streak) {
      return rows.any((row) => row.id == event.id);
    }
    return rows.isNotEmpty;
  }

  static bool _isWarm(MeEventType type) => switch (type) {
    MeEventType.dwell ||
    MeEventType.binge ||
    MeEventType.streak ||
    MeEventType.nightOwl => true,
    _ => false,
  };

  static String _typeToDb(MeEventType type) => type.name;

  static MeEventType _typeFromDb(String value) => switch (value) {
    'bookmark' => MeEventType.bookmark,
    'chat' => MeEventType.chat,
    'dwell' => MeEventType.dwell,
    'binge' => MeEventType.binge,
    'streak' => MeEventType.streak,
    'nightOwl' => MeEventType.nightOwl,
    _ => MeEventType.dwell,
  };

  static String _dayKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}';

  static MeEvent _map(WarmEvent row) {
    return MeEvent(
      id: row.id,
      type: _typeFromDb(row.type),
      createdAt: row.createdAt,
      title: row.title,
      subtitle: row.subtitle,
      articleId: row.articleId,
    );
  }
}

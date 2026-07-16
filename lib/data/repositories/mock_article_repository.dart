import 'dart:async';

import '../mock/mock_data.dart';
import '../models/models.dart';
import 'article_repository.dart';
import 'warm_event_repository.dart';

/// In-memory article store backed by [MockData].
/// Read / bookmark / unread state is session-scoped in Phase A.
class MockArticleRepository implements ArticleRepository {
  MockArticleRepository({WarmEventRepository? warmEvents})
      : _warmEvents = warmEvents {
    _articles = MockData.articles();
    _readIds = {'a5', 'a7', 'a11'};
    _bookmarkedIds = {'a2', 'a9'};
    _unreadBySource = {
      for (final s in MockData.sources) s.id: 0,
    };
    _unreadBySource['s1'] = 3;
    _unreadBySource['s3'] = 1;
    _unreadBySource['s4'] = 5;
    _unreadBySource['s6'] = 2;
    _emitAll();
  }

  final WarmEventRepository? _warmEvents;

  late List<Article> _articles;
  late Set<String> _readIds;
  late Set<String> _bookmarkedIds;
  late Map<String, int> _unreadBySource;

  final _timelineController = StreamController<List<Article>>.broadcast();
  final _unreadController = StreamController<Map<String, int>>.broadcast();
  final _readController = StreamController<Set<String>>.broadcast();
  final _bookmarkController = StreamController<Set<String>>.broadcast();

  void _emitAll() {
    if (!_timelineController.isClosed) {
      _timelineController.add(List.unmodifiable(_articles));
    }
    if (!_unreadController.isClosed) {
      _unreadController.add(Map.unmodifiable(_unreadBySource));
    }
    if (!_readController.isClosed) {
      _readController.add(Set.unmodifiable(_readIds));
    }
    if (!_bookmarkController.isClosed) {
      _bookmarkController.add(Set.unmodifiable(_bookmarkedIds));
    }
  }

  @override
  Stream<List<Article>> watchTimeline({String? feedId}) async* {
    List<Article> filter(List<Article> all) {
      if (feedId == null) return List.unmodifiable(all);
      return List.unmodifiable(
        all.where((a) => a.source.id == feedId),
      );
    }

    yield filter(_articles);
    yield* _timelineController.stream.map(filter);
  }

  @override
  Future<Article?> get(String id) async {
    for (final a in _articles) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  bool isRead(String id) => _readIds.contains(id);

  @override
  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  @override
  Stream<Set<String>> watchReadIds() async* {
    yield Set.unmodifiable(_readIds);
    yield* _readController.stream;
  }

  @override
  Stream<Set<String>> watchBookmarkedIds() async* {
    yield Set.unmodifiable(_bookmarkedIds);
    yield* _bookmarkController.stream;
  }

  @override
  Stream<List<Article>> watchBookmarkedArticles() async* {
    List<Article> pick() => List.unmodifiable(
          _articles.where((a) => _bookmarkedIds.contains(a.id)),
        );
    yield pick();
    yield* _timelineController.stream.map((_) => pick());
  }

  @override
  Stream<Map<String, int>> watchUnreadCounts() async* {
    yield Map.unmodifiable(_unreadBySource);
    yield* _unreadController.stream;
  }

  @override
  Future<void> markRead(String id) async {
    final article = await get(id);
    if (article == null) return;
    if (_readIds.contains(id)) return;

    _readIds.add(id);
    final sid = article.source.id;
    final current = _unreadBySource[sid] ?? 0;
    if (current > 0) {
      _unreadBySource[sid] = current - 1;
    }
    _emitAll();
  }

  @override
  Future<void> markSourceSeen(String feedId) async {
    if ((_unreadBySource[feedId] ?? 0) == 0 &&
        _articles
            .where((a) => a.source.id == feedId)
            .every((a) => _readIds.contains(a.id))) {
      return;
    }
    _unreadBySource[feedId] = 0;
    for (final a in _articles) {
      if (a.source.id == feedId) _readIds.add(a.id);
    }
    _emitAll();
  }

  @override
  Future<void> setBookmarked(String id, bool value) async {
    final article = await get(id);
    if (article == null) return;

    if (value) {
      if (_bookmarkedIds.contains(id)) return;
      _bookmarkedIds.add(id);
      await _warmEvents?.add(
        MeEvent(
          id: 'e-${DateTime.now().millisecondsSinceEpoch}',
          type: MeEventType.bookmark,
          createdAt: DateTime.now(),
          title: '收藏了 ${article.source.name}',
          subtitle: article.title,
          articleId: article.id,
        ),
      );
    } else {
      _bookmarkedIds.remove(id);
    }
    _emitAll();
  }

  void dispose() {
    _timelineController.close();
    _unreadController.close();
    _readController.close();
    _bookmarkController.close();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'article_repository.dart';
import 'warm_event_repository.dart';

class DriftArticleRepository implements ArticleRepository {
  DriftArticleRepository(this._db, {WarmEventRepository? warmEvents})
    : _warmEvents = warmEvents {
    // Keep sync caches warm for isRead / isBookmarked / toggle.
    _subs.add(watchReadIds().listen((ids) => _readCache = ids));
    _subs.add(watchBookmarkedIds().listen((ids) => _bookmarkCache = ids));
  }

  final AppDatabase _db;
  final WarmEventRepository? _warmEvents;
  final _subs = <StreamSubscription<dynamic>>[];

  Set<String> _readCache = {};
  Set<String> _bookmarkCache = {};

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
  }

  @override
  Stream<List<Article>> watchTimeline({String? feedId}) {
    final query = _db.select(_db.articles).join([
      innerJoin(_db.feeds, _db.feeds.id.equalsExp(_db.articles.feedId)),
    ]);
    if (feedId != null) {
      query.where(_db.articles.feedId.equals(feedId));
    }
    query.orderBy([OrderingTerm.desc(_db.articles.publishedAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final a = row.readTable(_db.articles);
        final f = row.readTable(_db.feeds);
        return _mapArticle(a, f);
      }).toList();
    });
  }

  @override
  Future<Article?> get(String id) async {
    final query = _db.select(_db.articles).join([
      innerJoin(_db.feeds, _db.feeds.id.equalsExp(_db.articles.feedId)),
    ])..where(_db.articles.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapArticle(row.readTable(_db.articles), row.readTable(_db.feeds));
  }

  @override
  bool isRead(String id) => _readCache.contains(id);

  @override
  bool isBookmarked(String id) => _bookmarkCache.contains(id);

  @override
  Stream<Set<String>> watchReadIds() {
    return (_db.select(_db.articles)..where((t) => t.isRead.equals(true)))
        .watch()
        .map((rows) => rows.map((r) => r.id).toSet());
  }

  @override
  Stream<Set<String>> watchBookmarkedIds() {
    return (_db.select(_db.articles)..where((t) => t.isBookmarked.equals(true)))
        .watch()
        .map((rows) => rows.map((r) => r.id).toSet());
  }

  @override
  Stream<List<Article>> watchBookmarkedArticles() {
    final query =
        _db.select(_db.articles).join([
            innerJoin(_db.feeds, _db.feeds.id.equalsExp(_db.articles.feedId)),
          ])
          ..where(_db.articles.isBookmarked.equals(true))
          ..orderBy([
            OrderingTerm.desc(_db.articles.bookmarkedAt),
            OrderingTerm.desc(_db.articles.publishedAt),
          ]);
    return query.watch().map((rows) {
      return rows.map((row) {
        return _mapArticle(
          row.readTable(_db.articles),
          row.readTable(_db.feeds),
        );
      }).toList();
    });
  }

  @override
  Stream<Map<String, int>> watchUnreadCounts() {
    // Emit whenever articles change; aggregate unread per feedId.
    return _db.select(_db.articles).watch().map((rows) {
      final map = <String, int>{};
      for (final r in rows) {
        if (!r.isRead) {
          map[r.feedId] = (map[r.feedId] ?? 0) + 1;
        }
      }
      return Map.unmodifiable(map);
    });
  }

  @override
  Future<void> markRead(String id) async {
    final article = await get(id);
    final row = await (_db.select(
      _db.articles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null || row.isRead) return;
    final now = DateTime.now();
    await (_db.update(_db.articles)..where((t) => t.id.equals(id))).write(
      ArticlesCompanion(isRead: const Value(true), readAt: Value(now)),
    );
    _readCache = {..._readCache, id};
    if (article != null) {
      await _warmEvents?.recordRead(article, now);
    }
  }

  @override
  Future<void> markSourceSeen(String feedId) async {
    final now = DateTime.now();
    await (_db.update(
      _db.articles,
    )..where((t) => t.feedId.equals(feedId) & t.isRead.equals(false))).write(
      ArticlesCompanion(isRead: const Value(true), readAt: Value(now)),
    );
  }

  @override
  Future<void> setBookmarked(String id, bool value) async {
    final article = await get(id);
    if (article == null) return;

    final now = DateTime.now();
    await (_db.update(_db.articles)..where((t) => t.id.equals(id))).write(
      ArticlesCompanion(
        isBookmarked: Value(value),
        bookmarkedAt: Value(value ? now : null),
      ),
    );

    if (value) {
      _bookmarkCache = {..._bookmarkCache, id};
      await _warmEvents?.add(
        MeEvent(
          id: 'e-${now.millisecondsSinceEpoch}',
          type: MeEventType.bookmark,
          createdAt: now,
          title: '收藏了 ${article.source.name}',
          subtitle: article.title,
          articleId: article.id,
        ),
      );
    } else {
      _bookmarkCache = {..._bookmarkCache}..remove(id);
    }
  }

  Article _mapArticle(ArticleRow a, FeedRow f) {
    final domain = _domainOf(f.siteUrl ?? f.url);
    List<String> tags = const [];
    try {
      final decoded = jsonDecode(a.tagsJson);
      if (decoded is List) {
        tags = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    final body =
        (a.contentText.isNotEmpty
                ? a.contentText
                : (a.summary.isNotEmpty ? a.summary : ''))
            .trim();
    final html = a.contentHtml?.trim();

    return Article(
      id: a.id,
      source: FeedSource(
        id: f.id,
        name: f.title,
        domain: domain,
        url: f.url,
        siteUrl: f.siteUrl,
        isPaused: f.isPaused,
      ),
      title: a.title,
      summary: a.summary,
      body: body,
      publishedAt: a.publishedAt,
      link: a.link,
      contentHtml: (html == null || html.isEmpty) ? null : html,
      imageUrl: a.imageUrl,
      imageAspect: a.imageAspect,
      featured: a.featured,
      tags: tags,
      mediaType: articleMediaTypeFromDb(a.mediaType),
      enclosureUrl: a.enclosureUrl,
      enclosureMime: a.enclosureMime,
      enclosureLength: a.enclosureLength,
      durationSeconds: a.durationSeconds,
    );
  }

  static String _domainOf(String url) {
    final u = Uri.tryParse(url);
    if (u == null || u.host.isEmpty) return url;
    return u.host.replaceFirst(RegExp(r'^www\.'), '');
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import '../rss/opml.dart';
import '../rss/rss_client.dart';
import '../rss/rss_models.dart';
import '../rss/rss_parser.dart';
import 'feed_repository.dart';

/// Real RSS feed store.
///
/// **Delete policy:** hard-delete feed row, then cascade-delete its articles
/// (comments are not FK-bound to articles; orphan comments may remain until C).
class DriftFeedRepository implements FeedRepository {
  DriftFeedRepository(this._db, {RssClient? client, RssParser? parser})
    : _client = client ?? RssClient(),
      _parser = parser ?? RssParser();

  final AppDatabase _db;
  final RssClient _client;
  final RssParser _parser;

  void dispose() {
    _client.close();
  }

  @override
  Stream<List<FeedSource>> watchFeeds() {
    return (_db.select(_db.feeds)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapFeed).toList());
  }

  @override
  Future<FeedSource?> getFeed(String id) async {
    final row = await (_db.select(
      _db.feeds,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapFeed(row);
  }

  @override
  Future<void> addFeed(String url) async {
    final normalized = _normalizeUrl(url);
    final existing = await (_db.select(
      _db.feeds,
    )..where((t) => t.url.equals(normalized))).getSingleOrNull();
    if (existing != null) {
      await refreshFeed(existing.id);
      return;
    }

    final fetch = await _client.fetch(normalized);
    if (fetch.body == null) {
      throw RssException('无法获取源内容');
    }
    final parsed = _parser.parse(fetch.body!, sourceUrl: normalized);
    final now = DateTime.now();
    final id = _feedIdForUrl(normalized);
    final siteUrl = parsed.siteUrl ?? _origin(normalized);

    await _db
        .into(_db.feeds)
        .insert(
          FeedsCompanion.insert(
            id: id,
            title: parsed.title,
            url: normalized,
            siteUrl: Value(siteUrl),
            lastFetchedAt: Value(now),
            etag: Value(fetch.etag),
            lastModified: Value(fetch.lastModified),
            createdAt: now,
          ),
        );

    await _upsertItems(feedId: id, items: parsed.items, fetchedAt: now);
  }

  @override
  Future<void> removeFeed(String id) async {
    // Cascade: articles first (no ON DELETE CASCADE declared on table).
    await (_db.delete(_db.articles)..where((t) => t.feedId.equals(id))).go();
    await (_db.delete(_db.feeds)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> setPaused(String id, bool paused) async {
    await (_db.update(_db.feeds)..where((t) => t.id.equals(id))).write(
      FeedsCompanion(isPaused: Value(paused)),
    );
  }

  @override
  Future<void> refreshFeed(String id) async {
    final row = await (_db.select(
      _db.feeds,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    if (row.isPaused) return;
    await _refreshRow(row);
  }

  @override
  Future<void> refreshAll({
    bool wifiOnly = false,
    Iterable<String>? feedIds,
  }) async {
    // wifiOnly is honored by background worker (Phase E); UI refresh ignores it.
    final scoped = feedIds?.where((id) => id.isNotEmpty).toSet();
    final query = _db.select(_db.feeds)..where((t) => t.isPaused.equals(false));
    if (scoped != null && scoped.isNotEmpty) {
      query.where((t) => t.id.isIn(scoped));
    }
    final rows = await query.get();
    for (final row in rows) {
      try {
        await _refreshRow(row);
      } catch (_) {
        // Continue other feeds; per-feed errors surface on next single refresh.
      }
    }
  }

  @override
  Future<void> importOpml(String xml) async {
    final outlines = Opml.parse(xml);
    if (outlines.isEmpty) {
      throw RssException('OPML 中没有可导入的订阅源');
    }
    final errors = <String>[];
    for (final o in outlines) {
      try {
        await addFeed(o.xmlUrl);
      } catch (e) {
        errors.add('${o.title}: $e');
      }
    }
    if (errors.length == outlines.length) {
      throw RssException('导入全部失败\n${errors.take(3).join('\n')}');
    }
  }

  @override
  Future<String> exportOpml() async {
    final rows = await (_db.select(
      _db.feeds,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return Opml.export(
      rows
          .map((r) => (title: r.title, xmlUrl: r.url, htmlUrl: r.siteUrl))
          .toList(),
    );
  }

  Future<void> _refreshRow(FeedRow row) async {
    final fetch = await _client.fetch(
      row.url,
      etag: row.etag,
      lastModified: row.lastModified,
    );
    final now = DateTime.now();
    if (fetch.notModified) {
      await (_db.update(_db.feeds)..where((t) => t.id.equals(row.id))).write(
        FeedsCompanion(lastFetchedAt: Value(now)),
      );
      return;
    }
    if (fetch.body == null) return;

    final parsed = _parser.parse(fetch.body!, sourceUrl: row.url);
    await (_db.update(_db.feeds)..where((t) => t.id.equals(row.id))).write(
      FeedsCompanion(
        title: Value(parsed.title),
        siteUrl: Value(parsed.siteUrl ?? row.siteUrl),
        lastFetchedAt: Value(now),
        etag: Value(fetch.etag ?? row.etag),
        lastModified: Value(fetch.lastModified ?? row.lastModified),
      ),
    );
    await _upsertItems(feedId: row.id, items: parsed.items, fetchedAt: now);
  }

  /// Upsert by UNIQUE(feedId, guid). Preserves isRead / isBookmarked on update.
  Future<void> _upsertItems({
    required String feedId,
    required List<ParsedItem> items,
    required DateTime fetchedAt,
  }) async {
    for (final item in items) {
      final existing =
          await (_db.select(_db.articles)..where(
                (t) => t.feedId.equals(feedId) & t.guid.equals(item.guid),
              ))
              .getSingleOrNull();

      if (existing != null) {
        await (_db.update(
          _db.articles,
        )..where((t) => t.id.equals(existing.id))).write(
          ArticlesCompanion(
            link: Value(item.link),
            title: Value(item.title),
            author: Value(item.author),
            summary: Value(item.summary),
            contentHtml: Value(item.contentHtml),
            contentText: Value(item.contentText),
            imageUrl: Value(item.imageUrl ?? existing.imageUrl),
            mediaType: Value(articleMediaTypeToDb(item.mediaType)),
            enclosureUrl: Value(item.enclosureUrl),
            enclosureMime: Value(item.enclosureMime),
            enclosureLength: Value(item.enclosureLength),
            durationSeconds: Value(item.durationSeconds),
            publishedAt: Value(item.publishedAt),
            fetchedAt: Value(fetchedAt),
          ),
        );
      } else {
        final id = _articleId(feedId, item.guid);
        await _db
            .into(_db.articles)
            .insert(
              ArticlesCompanion.insert(
                id: id,
                feedId: feedId,
                guid: item.guid,
                link: Value(item.link),
                title: item.title,
                author: Value(item.author),
                summary: Value(item.summary),
                contentHtml: Value(item.contentHtml),
                contentText: Value(item.contentText),
                imageUrl: Value(item.imageUrl),
                mediaType: Value(articleMediaTypeToDb(item.mediaType)),
                enclosureUrl: Value(item.enclosureUrl),
                enclosureMime: Value(item.enclosureMime),
                enclosureLength: Value(item.enclosureLength),
                durationSeconds: Value(item.durationSeconds),
                publishedAt: item.publishedAt,
                fetchedAt: fetchedAt,
              ),
            );
      }
    }
  }

  FeedSource _mapFeed(FeedRow r) {
    final domain = _domainOf(r.siteUrl ?? r.url);
    return FeedSource(
      id: r.id,
      name: r.title,
      domain: domain,
      url: r.url,
      siteUrl: r.siteUrl,
      isPaused: r.isPaused,
    );
  }

  static String _normalizeUrl(String raw) {
    var s = raw.trim();
    if (!s.contains('://')) s = 'https://$s';
    final u = Uri.tryParse(s);
    if (u == null || !(u.isScheme('http') || u.isScheme('https'))) {
      throw RssException('请输入有效的 http(s) 订阅地址');
    }
    return u.toString();
  }

  static String _feedIdForUrl(String url) =>
      'f_${sha1.convert(utf8.encode(url)).toString().substring(0, 16)}';

  static String _articleId(String feedId, String guid) =>
      'a_${sha1.convert(utf8.encode('$feedId|$guid')).toString().substring(0, 20)}';

  static String _domainOf(String url) {
    final u = Uri.tryParse(url);
    if (u == null || u.host.isEmpty) return url;
    return u.host.replaceFirst(RegExp(r'^www\.'), '');
  }

  static String? _origin(String url) {
    final u = Uri.tryParse(url);
    if (u == null || u.host.isEmpty) return null;
    return '${u.scheme}://${u.host}';
  }
}

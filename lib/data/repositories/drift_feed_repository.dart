import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import '../rss/opml.dart';
import '../rss/rss_client.dart';
import '../rss/rss_models.dart';
import '../rss/rss_parser.dart';
import '../rss/rss_refresh_config.dart';
import 'feed_repository.dart';

/// Real RSS feed store.
///
/// **Delete policy:** hard-delete feed row, then cascade-delete its articles
/// (comments are not FK-bound to articles; orphan comments may remain until C).
///
/// **Refresh (§15.10):** network work uses a bounded pool; all SQLite writes go
/// through a single-writer queue; articles are batch-upserted per feed.
class DriftFeedRepository implements FeedRepository {
  DriftFeedRepository(this._db, {RssClient? client, RssParser? parser})
    : _client = client ?? RssClient(),
      _parser = parser ?? RssParser();

  final AppDatabase _db;
  final RssClient _client;
  final RssParser _parser;

  /// Serializes every DB mutation so concurrent fetch workers never write
  /// the same connection out of order (avoids SQLITE_BUSY / stream storms).
  Future<void> _writeTail = Future<void>.value();

  /// Bumps on each [refreshAll]; unhealthy feeds skip on alternate rounds.
  int _refreshRound = 0;

  void dispose() {
    _client.close();
  }

  Future<T> _serializedWrite<T>(Future<T> Function() op) {
    final result = _writeTail.then((_) => op());
    // Keep the chain alive after failures so later writers still run.
    _writeTail = result.then<void>((_) {}, onError: (_) {});
    return result;
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

    final sw = Stopwatch()..start();
    final fetch = await _client.fetch(
      normalized,
      timeout: RssRefreshLimits.addFeedTimeout,
    );
    if (fetch.body == null) {
      throw RssException('无法获取源内容');
    }
    final resolvedUrl = _normalizeUrl(fetch.resolvedUrl ?? normalized);
    if (resolvedUrl != normalized) {
      final resolvedExisting = await (_db.select(
        _db.feeds,
      )..where((t) => t.url.equals(resolvedUrl))).getSingleOrNull();
      if (resolvedExisting != null) {
        await _refreshRow(
          resolvedExisting,
          timeout: RssRefreshLimits.addFeedTimeout,
        );
        return;
      }
    }
    final parsed = _parser.parse(fetch.body!, sourceUrl: resolvedUrl);
    final now = DateTime.now();
    final id = _feedIdForUrl(resolvedUrl);
    final siteUrl = parsed.siteUrl ?? _origin(resolvedUrl);
    final latencyMs = sw.elapsedMilliseconds;

    await _serializedWrite(() async {
      await _db.transaction(() async {
        await _db
            .into(_db.feeds)
            .insert(
              FeedsCompanion.insert(
                id: id,
                title: parsed.title,
                url: resolvedUrl,
                siteUrl: Value(siteUrl),
                lastFetchedAt: Value(now),
                etag: Value(fetch.etag),
                lastModified: Value(fetch.lastModified),
                createdAt: now,
                lastSuccessAt: Value(now),
                consecutiveFailures: const Value(0),
                avgLatencyMs: Value(latencyMs),
              ),
            );
        await _upsertItems(
          feedId: id,
          items: parsed.items,
          fetchedAt: now,
        );
      });
    });
  }

  @override
  Future<void> removeFeed(String id) async {
    await _serializedWrite(() async {
      // Cascade: articles first (no ON DELETE CASCADE declared on table).
      await (_db.delete(_db.articles)..where((t) => t.feedId.equals(id))).go();
      await (_db.delete(_db.feeds)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<void> setPaused(String id, bool paused) async {
    await _serializedWrite(() async {
      await (_db.update(_db.feeds)..where((t) => t.id.equals(id))).write(
        FeedsCompanion(isPaused: Value(paused)),
      );
    });
  }

  @override
  Future<void> refreshFeed(String id) async {
    final row = await (_db.select(
      _db.feeds,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    if (row.isPaused) return;
    // User-initiated: always pull (health skip only applies to refreshAll).
    await _refreshRow(row, timeout: RssRefreshLimits.singleFeedTimeout);
  }

  @override
  Future<void> refreshAll({
    bool wifiOnly = false,
    Iterable<String>? feedIds,
    RssRefreshMode mode = RssRefreshMode.foreground,
  }) async {
    // wifiOnly is honored by background worker (Phase E); UI refresh ignores it.
    final limits = RssRefreshLimits.forMode(mode);
    final scoped = feedIds?.where((id) => id.isNotEmpty).toSet();
    final query = _db.select(_db.feeds)..where((t) => t.isPaused.equals(false));
    if (scoped != null && scoped.isNotEmpty) {
      query.where((t) => t.id.isIn(scoped));
    }
    final rows = await query.get();
    if (rows.isEmpty) return;

    final round = ++_refreshRound;
    final selected = <FeedRow>[];
    for (final row in rows) {
      if (_shouldSkipUnhealthy(row, round)) continue;
      selected.add(row);
    }
    if (selected.isEmpty) return;

    selected.sort(_compareByHealth);

    await _runPool(selected, limits.poolSize, (row) async {
      try {
        await _refreshRow(row, timeout: limits.timeout);
      } catch (_) {
        // Continue other feeds; per-feed errors are recorded as health.
      }
    });
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

  /// Fetch + parse off the write path; apply via [_serializedWrite].
  Future<void> _refreshRow(
    FeedRow row, {
    required Duration timeout,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final fetch = await _client.fetch(
        row.url,
        etag: row.etag,
        lastModified: row.lastModified,
        timeout: timeout,
      );
      final latencyMs = sw.elapsedMilliseconds;
      final now = DateTime.now();

      if (fetch.notModified) {
        await _serializedWrite(() async {
          await (_db.update(_db.feeds)..where((t) => t.id.equals(row.id)))
              .write(
            FeedsCompanion(
              lastFetchedAt: Value(now),
              lastSuccessAt: Value(now),
              consecutiveFailures: const Value(0),
              lastErrorMessage: const Value(null),
              avgLatencyMs: Value(_ewma(row.avgLatencyMs, latencyMs)),
            ),
          );
        });
        return;
      }
      if (fetch.body == null) return;

      final parsed = _parser.parse(fetch.body!, sourceUrl: row.url);
      await _serializedWrite(() async {
        await _db.transaction(() async {
          await (_db.update(_db.feeds)..where((t) => t.id.equals(row.id)))
              .write(
            FeedsCompanion(
              title: Value(parsed.title),
              siteUrl: Value(parsed.siteUrl ?? row.siteUrl),
              lastFetchedAt: Value(now),
              // A successful 200 replaces validators. Keeping a validator which a
              // server no longer sends can make subsequent refreshes incorrectly 304.
              etag: Value(fetch.etag),
              lastModified: Value(fetch.lastModified),
              lastSuccessAt: Value(now),
              consecutiveFailures: const Value(0),
              lastErrorMessage: const Value(null),
              avgLatencyMs: Value(_ewma(row.avgLatencyMs, latencyMs)),
            ),
          );
          await _upsertItems(
            feedId: row.id,
            items: parsed.items,
            fetchedAt: now,
          );
        });
      });
    } catch (e) {
      final latencyMs = sw.elapsedMilliseconds;
      final message = e is RssException ? e.message : e.toString();
      final now = DateTime.now();
      try {
        await _serializedWrite(() async {
          await (_db.update(_db.feeds)..where((t) => t.id.equals(row.id)))
              .write(
            FeedsCompanion(
              lastErrorAt: Value(now),
              lastErrorMessage: Value(
                message.length > 240 ? message.substring(0, 240) : message,
              ),
              consecutiveFailures: Value(row.consecutiveFailures + 1),
              avgLatencyMs: Value(_ewma(row.avgLatencyMs, latencyMs)),
            ),
          );
        });
      } catch (_) {
        // Health write is best-effort; surface original error.
      }
      rethrow;
    }
  }

  /// Upsert by UNIQUE(feedId, guid). Preserves isRead / isBookmarked on update.
  ///
  /// One batch per feed: load existing guids once, then insert/update in bulk.
  Future<void> _upsertItems({
    required String feedId,
    required List<ParsedItem> items,
    required DateTime fetchedAt,
  }) async {
    if (items.isEmpty) return;

    final guids = items.map((i) => i.guid).toList(growable: false);
    final existingRows =
        await (_db.select(_db.articles)..where(
              (t) => t.feedId.equals(feedId) & t.guid.isIn(guids),
            ))
            .get();
    final byGuid = {for (final r in existingRows) r.guid: r};

    await _db.batch((batch) {
      for (final item in items) {
        final existing = byGuid[item.guid];
        if (existing != null) {
          batch.update(
            _db.articles,
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
            where: (t) => t.id.equals(existing.id),
          );
        } else {
          final id = _articleId(feedId, item.guid);
          batch.insert(
            _db.articles,
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
    });
  }

  /// Bounded worker pool (single isolate; index advance is await-atomic).
  static Future<void> _runPool<T>(
    List<T> items,
    int concurrency,
    Future<void> Function(T item) work,
  ) async {
    if (items.isEmpty) return;
    final pool = math.max(1, math.min(concurrency, items.length));
    var next = 0;

    Future<void> worker() async {
      while (true) {
        final i = next;
        next = i + 1;
        if (i >= items.length) return;
        await work(items[i]);
      }
    }

    await Future.wait(List.generate(pool, (_) => worker()));
  }

  /// Skip unhealthy sources on alternate [refreshAll] rounds (not user force).
  static bool _shouldSkipUnhealthy(FeedRow row, int round) {
    if (row.consecutiveFailures < RssRefreshLimits.unhealthyFailureThreshold) {
      return false;
    }
    // Even rounds skip; odd rounds still probe.
    return round.isEven;
  }

  /// Prefer healthier / faster sources first so UI sees good data earlier.
  static int _compareByHealth(FeedRow a, FeedRow b) {
    final byFailures = a.consecutiveFailures.compareTo(b.consecutiveFailures);
    if (byFailures != 0) return byFailures;
    final la = a.avgLatencyMs ?? 1 << 30;
    final lb = b.avgLatencyMs ?? 1 << 30;
    return la.compareTo(lb);
  }

  /// Exponential weighted moving average (≈70% history / 30% sample).
  static int _ewma(int? previous, int sampleMs) {
    if (previous == null || previous <= 0) return sampleMs;
    return ((previous * 7) + (sampleMs * 3)) ~/ 10;
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

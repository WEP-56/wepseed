import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wepseed/data/db/app_database.dart';
import 'package:wepseed/data/repositories/drift_feed_repository.dart';
import 'package:wepseed/data/rss/rss_client.dart';
import 'package:wepseed/data/rss/rss_refresh_config.dart';

String _rss({
  required String title,
  required List<({String guid, String title})> items,
}) {
  final buf = StringBuffer()
    ..writeln('<rss version="2.0"><channel>')
    ..writeln('<title>$title</title>');
  for (final item in items) {
    buf
      ..writeln('<item>')
      ..writeln('<title>${item.title}</title>')
      ..writeln('<guid>${item.guid}</guid>')
      ..writeln('<pubDate>Wed, 01 Jan 2025 00:00:00 GMT</pubDate>')
      ..writeln('</item>');
  }
  buf.writeln('</channel></rss>');
  return buf.toString();
}

void main() {
  group('RSS refresh engine', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('bounded pool is faster than serial wall-clock for slow feeds', () async {
      const delay = Duration(milliseconds: 120);
      final repo = DriftFeedRepository(
        db,
        client: RssClient(
          client: MockClient((request) async {
            await Future<void>.delayed(delay);
            final host = request.url.host;
            return http.Response(
              _rss(
                title: host,
                items: [(guid: '$host-1', title: 'Post $host')],
              ),
              200,
              headers: {'etag': '"$host"'},
            );
          }),
        ),
      );

      final now = DateTime.now();
      for (var i = 0; i < 6; i++) {
        await db.into(db.feeds).insert(
              FeedsCompanion.insert(
                id: 'f$i',
                title: 'Feed $i',
                url: 'https://slow$i.example/feed',
                createdAt: now,
              ),
            );
      }

      final sw = Stopwatch()..start();
      await repo.refreshAll(mode: RssRefreshMode.foreground);
      sw.stop();

      final articles = await db.select(db.articles).get();
      expect(articles, hasLength(6));

      // Serial would be ~6 * 120ms = 720ms+. Pool of 6 ≈ one delay + overhead.
      expect(
        sw.elapsedMilliseconds,
        lessThan(delay.inMilliseconds * 3),
        reason:
            'expected concurrent refresh (~${delay.inMilliseconds}ms), '
            'got ${sw.elapsedMilliseconds}ms',
      );
      expect(
        sw.elapsedMilliseconds,
        greaterThanOrEqualTo(delay.inMilliseconds),
      );
      repo.dispose();
    });

    test('one failed feed does not block siblings; health is recorded', () async {
      final repo = DriftFeedRepository(
        db,
        client: RssClient(
          client: MockClient((request) async {
            if (request.url.host.startsWith('hang')) {
              throw http.ClientException('timed out');
            }
            return http.Response(
              _rss(
                title: 'ok',
                items: [(guid: 'ok-1', title: 'OK')],
              ),
              200,
            );
          }),
        ),
      );

      final now = DateTime.now();
      await db.into(db.feeds).insert(
            FeedsCompanion.insert(
              id: 'hang',
              title: 'Hang',
              url: 'https://hang.example/feed',
              createdAt: now,
            ),
          );
      await db.into(db.feeds).insert(
            FeedsCompanion.insert(
              id: 'ok',
              title: 'OK',
              url: 'https://ok.example/feed',
              createdAt: now,
            ),
          );

      await repo.refreshAll(mode: RssRefreshMode.foreground);

      final articles = await db.select(db.articles).get();
      expect(articles.where((a) => a.feedId == 'ok'), hasLength(1));

      final hang = await (db.select(db.feeds)
            ..where((t) => t.id.equals('hang')))
          .getSingle();
      expect(hang.consecutiveFailures, greaterThan(0));
      expect(hang.lastErrorMessage, isNotNull);

      final ok = await (db.select(db.feeds)..where((t) => t.id.equals('ok')))
          .getSingle();
      expect(ok.consecutiveFailures, 0);
      expect(ok.lastSuccessAt, isNotNull);
      repo.dispose();
    });

    test('batch upsert preserves isRead / isBookmarked', () async {
      final repo = DriftFeedRepository(
        db,
        client: RssClient(
          client: MockClient(
            (_) async => http.Response(
              _rss(
                title: 'Feed',
                items: [
                  (guid: 'g1', title: 'One v2'),
                  (guid: 'g2', title: 'Two'),
                ],
              ),
              200,
            ),
          ),
        ),
      );

      await repo.addFeed('https://preserve.example/feed');
      final feedId = (await db.select(db.feeds).getSingle()).id;
      final first = await (db.select(db.articles)
            ..where((t) => t.guid.equals('g1')))
          .getSingle();

      await (db.update(db.articles)..where((t) => t.id.equals(first.id))).write(
        const ArticlesCompanion(
          isRead: Value(true),
          isBookmarked: Value(true),
        ),
      );

      await repo.refreshFeed(feedId);

      final updated = await (db.select(db.articles)
            ..where((t) => t.guid.equals('g1')))
          .getSingle();
      expect(updated.title, 'One v2');
      expect(updated.isRead, isTrue);
      expect(updated.isBookmarked, isTrue);
      expect(await db.select(db.articles).get(), hasLength(2));
      repo.dispose();
    });

    test('304 only bumps lastFetchedAt and keeps validators', () async {
      var call = 0;
      final repo = DriftFeedRepository(
        db,
        client: RssClient(
          client: MockClient((request) async {
            call++;
            if (call == 1) {
              return http.Response(
                _rss(
                  title: 'Feed',
                  items: [(guid: 'g1', title: 'A')],
                ),
                200,
                headers: {
                  'etag': '"abc"',
                  'last-modified': 'Wed, 01 Jan 2025 00:00:00 GMT',
                },
              );
            }
            expect(request.headers['if-none-match'], '"abc"');
            expect(
              request.headers['if-modified-since'],
              'Wed, 01 Jan 2025 00:00:00 GMT',
            );
            return http.Response(
              '',
              304,
              headers: {
                'etag': '"abc"',
                'last-modified': 'Wed, 01 Jan 2025 00:00:00 GMT',
              },
            );
          }),
        ),
      );

      await repo.addFeed('https://etag.example/feed');
      final before = await db.select(db.feeds).getSingle();
      expect(before.etag, '"abc"');

      // Drift stores DateTime at second resolution; backdate so 304 bump is visible.
      final past = DateTime.now().subtract(const Duration(minutes: 2));
      await (db.update(db.feeds)..where((t) => t.id.equals(before.id))).write(
        FeedsCompanion(lastFetchedAt: Value(past)),
      );

      await repo.refreshFeed(before.id);

      final after = await db.select(db.feeds).getSingle();
      expect(after.etag, '"abc"');
      expect(after.lastModified, 'Wed, 01 Jan 2025 00:00:00 GMT');
      expect(after.lastFetchedAt!.isAfter(past), isTrue);
      expect(after.consecutiveFailures, 0);
      expect(await db.select(db.articles).get(), hasLength(1));
      repo.dispose();
    });

    test('200 without validators clears stale etag/lastModified', () async {
      var call = 0;
      final repo = DriftFeedRepository(
        db,
        client: RssClient(
          client: MockClient((_) async {
            call++;
            return http.Response(
              _rss(
                title: 'Feed',
                items: [(guid: 'g1', title: 'A')],
              ),
              200,
              headers: call == 1
                  ? {
                      'etag': '"old"',
                      'last-modified': 'Wed, 01 Jan 2025 00:00:00 GMT',
                    }
                  : const {},
            );
          }),
        ),
      );

      await repo.addFeed('https://stale.example/feed');
      final id = (await db.select(db.feeds).getSingle()).id;
      await repo.refreshFeed(id);

      final refreshed = await db.select(db.feeds).getSingle();
      expect(refreshed.etag, isNull);
      expect(refreshed.lastModified, isNull);
      repo.dispose();
    });

    test('unhealthy feeds skip alternate refreshAll rounds', () async {
      var hits = 0;
      final repo = DriftFeedRepository(
        db,
        client: RssClient(
          client: MockClient((_) async {
            hits++;
            throw http.ClientException('down');
          }),
        ),
      );

      final now = DateTime.now();
      await db.into(db.feeds).insert(
            FeedsCompanion.insert(
              id: 'bad',
              title: 'Bad',
              url: 'https://bad.example/feed',
              createdAt: now,
              consecutiveFailures: const Value(3),
            ),
          );

      // round 1 → odd → probe
      await repo.refreshAll();
      expect(hits, 1);

      // round 2 → even → skip
      await repo.refreshAll();
      expect(hits, 1);

      // round 3 → odd → probe again
      await repo.refreshAll();
      expect(hits, 2);

      // Manual refresh always forces pull (error still surfaces to caller).
      await expectLater(repo.refreshFeed('bad'), throwsA(isA<Exception>()));
      expect(hits, 3);
      repo.dispose();
    });

    test('background mode still refreshes every selected feed', () async {
      final seen = <String>{};
      final repo = DriftFeedRepository(
        db,
        client: RssClient(
          client: MockClient((request) async {
            seen.add(request.url.host);
            await Future<void>.delayed(const Duration(milliseconds: 40));
            return http.Response(
              _rss(
                title: request.url.host,
                items: [(guid: '${request.url.host}-1', title: 'P')],
              ),
              200,
            );
          }),
        ),
      );

      final now = DateTime.now();
      for (var i = 0; i < 4; i++) {
        await db.into(db.feeds).insert(
              FeedsCompanion.insert(
                id: 'b$i',
                title: 'B$i',
                url: 'https://bg$i.example/feed',
                createdAt: now,
              ),
            );
      }

      await repo.refreshAll(mode: RssRefreshMode.background);
      expect(seen, hasLength(4));
      expect(await db.select(db.articles).get(), hasLength(4));
      repo.dispose();
    });
  });
}

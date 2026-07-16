import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/core/utils/feed_filter.dart';
import 'package:wepseed/data/models/models.dart';

void main() {
  final sourceA = const FeedSource(id: 'a', name: 'A', domain: 'a.test');
  final sourceB = const FeedSource(id: 'b', name: 'B', domain: 'b.test');
  final now = DateTime(2026, 7, 16, 12);

  Article art({
    required String id,
    required FeedSource source,
    required DateTime publishedAt,
  }) {
    return Article(
      id: id,
      source: source,
      title: id,
      summary: '',
      body: '',
      publishedAt: publishedAt,
    );
  }

  final articles = [
    art(id: 't1', source: sourceA, publishedAt: DateTime(2026, 7, 16, 8)),
    art(id: 'y1', source: sourceA, publishedAt: DateTime(2026, 7, 15, 20)),
    art(id: 't2', source: sourceB, publishedAt: DateTime(2026, 7, 16, 9)),
    art(id: 'y2', source: sourceB, publishedAt: DateTime(2026, 7, 14, 1)),
  ];

  test('default filter returns all', () {
    final out = applyFeedFilter(
      articles,
      filter: const FeedFilter(),
      readIds: {'t1'},
      now: now,
    );
    expect(out.map((a) => a.id), ['t1', 'y1', 't2', 'y2']);
  });

  test('onlyToday keeps local calendar day', () {
    final out = applyFeedFilter(
      articles,
      filter: const FeedFilter(onlyToday: true),
      readIds: const {},
      now: now,
    );
    expect(out.map((a) => a.id), ['t1', 't2']);
  });

  test('onlyUnread excludes read ids', () {
    final out = applyFeedFilter(
      articles,
      filter: const FeedFilter(onlyUnread: true),
      readIds: {'t1', 't2'},
      now: now,
    );
    expect(out.map((a) => a.id), ['y1', 'y2']);
  });

  test('feedIds restricts sources', () {
    final out = applyFeedFilter(
      articles,
      filter: FeedFilter(feedIds: {'b'}),
      readIds: const {},
      now: now,
    );
    expect(out.map((a) => a.id), ['t2', 'y2']);
  });

  test('AND combine today + unread + feeds', () {
    final out = applyFeedFilter(
      articles,
      filter: FeedFilter(
        onlyToday: true,
        onlyUnread: true,
        feedIds: {'a', 'b'},
      ),
      readIds: {'t1'},
      now: now,
    );
    expect(out.map((a) => a.id), ['t2']);
  });

  test('deleted feed ids yield empty silently', () {
    final out = applyFeedFilter(
      articles,
      filter: FeedFilter(feedIds: {'gone'}),
      readIds: const {},
      now: now,
    );
    expect(out, isEmpty);
  });

  test('FeedFilter equality ignores set order', () {
    final a = FeedFilter(feedIds: {'x', 'y'}, onlyToday: true);
    final b = FeedFilter(feedIds: {'y', 'x'}, onlyToday: true);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}

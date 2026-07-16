import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/rss/opml.dart';
import 'package:wepseed/data/rss/rss_parser.dart';

void main() {
  final fixtures = Directory('test/fixtures');

  test('parses RSS 2.0 with image extraction', () {
    final xml = File('${fixtures.path}/sample_rss.xml').readAsStringSync();
    final feed = RssParser().parse(xml, sourceUrl: 'https://example.com/feed');
    expect(feed.title, 'Sample RSS');
    expect(feed.siteUrl, 'https://example.com/');
    expect(feed.items, hasLength(2));
    expect(feed.items[0].title, 'First Post');
    expect(feed.items[0].imageUrl, 'https://example.com/img1.jpg');
    expect(feed.items[0].contentText, contains('Hello'));
    expect(feed.items[1].guid, 'unique-guid-2');
    expect(feed.items[1].imageUrl, 'https://example.com/cover.png');
  });

  test('parses Atom entries', () {
    final xml = File('${fixtures.path}/sample_atom.xml').readAsStringSync();
    final feed = RssParser().parse(xml);
    expect(feed.title, 'Sample Atom');
    expect(feed.items, hasLength(2));
    expect(feed.items[0].guid, 'urn:uuid:entry-1');
    expect(feed.items[0].author, 'Ada');
    expect(feed.items[1].link, 'https://atom.example.com/e2');
  });

  test('OPML import flattens nested outlines', () {
    final xml = File('${fixtures.path}/sample.opml').readAsStringSync();
    final outlines = Opml.parse(xml);
    expect(outlines, hasLength(2));
    expect(outlines[0].xmlUrl, 'https://a.example.com/rss');
    expect(outlines[1].htmlUrl, 'https://b.example.com');
  });

  test('OPML export roundtrip keeps xmlUrl', () {
    final out = Opml.export([
      (title: 'X', xmlUrl: 'https://x.test/rss', htmlUrl: 'https://x.test'),
    ]);
    final back = Opml.parse(out);
    expect(back, hasLength(1));
    expect(back.first.xmlUrl, 'https://x.test/rss');
    expect(back.first.title, 'X');
  });

  test('guid falls back to link then hash', () {
    const xml = '''
<rss version="2.0"><channel>
<title>T</title><link>https://t.test</link>
<item><title>No guid</title><link>https://t.test/a</link></item>
<item><title>No link either</title><pubDate>Wed, 03 Jan 2024 00:00:00 GMT</pubDate></item>
</channel></rss>
''';
    final feed = RssParser().parse(xml);
    expect(feed.items[0].guid, 'https://t.test/a');
    expect(feed.items[1].guid, isNotEmpty);
    expect(feed.items[1].guid.length, 40); // sha1 hex
  });
}

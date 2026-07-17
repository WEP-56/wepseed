import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/models/models.dart';
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

  test('parses audio enclosure and podcast duration', () {
    const xml = '''
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
<channel><title>Podcast</title><link>https://pod.test</link>
<item><title>Episode</title><guid>episode-1</guid>
<description><![CDATA[<p>Show notes</p>]]></description>
<enclosure url="https://cdn.test/episode.mp3" type="audio/mpeg" length="12345" />
<itunes:duration>01:02:03</itunes:duration></item>
</channel></rss>
''';
    final item = RssParser().parse(xml).items.single;
    expect(item.mediaType, ArticleMediaType.audio);
    expect(item.enclosureUrl, 'https://cdn.test/episode.mp3');
    expect(item.enclosureMime, 'audio/mpeg');
    expect(item.enclosureLength, 12345);
    expect(item.durationSeconds, 3723);
    expect(item.contentText, 'Show notes');
  });

  test('parses video media:content without treating stream as image', () {
    const xml = '''
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
<channel><title>Video</title><link>https://video.test</link>
<item><title>Clip</title><guid>clip-1</guid>
<media:content url="https://cdn.test/clip.m3u8" type="application/x-mpegURL" medium="video" duration="95" />
<media:thumbnail url="https://cdn.test/poster.jpg" /></item>
</channel></rss>
''';
    final item = RssParser().parse(xml).items.single;
    expect(item.mediaType, ArticleMediaType.video);
    expect(item.enclosureUrl, 'https://cdn.test/clip.m3u8');
    expect(item.imageUrl, 'https://cdn.test/poster.jpg');
    expect(item.durationSeconds, 95);
  });

  test('parses Atom enclosure and infers type from URL extension', () {
    const xml = '''
<feed xmlns="http://www.w3.org/2005/Atom"><title>Atom Audio</title>
<entry><title>Track</title><id>track-1</id><updated>2026-07-17T00:00:00Z</updated>
<link rel="alternate" href="https://atom.test/track" />
<link rel="enclosure" href="https://cdn.test/track.m4a?token=1" length="99" />
</entry></feed>
''';
    final item = RssParser().parse(xml).items.single;
    expect(item.mediaType, ArticleMediaType.audio);
    expect(item.enclosureUrl, contains('track.m4a'));
    expect(item.link, 'https://atom.test/track');
  });

  test('image enclosure remains a blog article', () {
    const xml = '''
<rss version="2.0"><channel><title>Blog</title><link>https://blog.test</link>
<item><title>Post</title><guid>post</guid>
<enclosure url="https://cdn.test/cover.jpg" type="image/jpeg" />
</item></channel></rss>
''';
    final item = RssParser().parse(xml).items.single;
    expect(item.mediaType, ArticleMediaType.blog);
    expect(item.enclosureUrl, isNull);
    expect(item.imageUrl, 'https://cdn.test/cover.jpg');
  });
}

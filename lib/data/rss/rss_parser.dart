import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'dart:convert';

import '../models/models.dart';
import 'rss_models.dart';

/// Lightweight RSS 2.0 + Atom parser.
///
/// Guid fallback when feed omits guid: use link, else sha1(title|published).
class RssParser {
  ParsedFeed parse(String xmlBody, {String? sourceUrl}) {
    late XmlDocument doc;
    try {
      doc = XmlDocument.parse(xmlBody);
    } on XmlException {
      throw RssException('内容不是有效的 XML 订阅源');
    }

    final root = doc.rootElement;
    final name = root.name.local.toLowerCase();

    if (name == 'rss') {
      final channel = root.findElements('channel').firstOrNull;
      if (channel == null) throw RssException('RSS 缺少 channel');
      return _parseRss(channel, sourceUrl: sourceUrl);
    }
    if (name == 'feed') {
      return _parseAtom(root, sourceUrl: sourceUrl);
    }
    // Some servers wrap oddly; try descendants.
    final channel = root.findAllElements('channel').firstOrNull;
    if (channel != null) {
      return _parseRss(channel, sourceUrl: sourceUrl);
    }
    final feed = root.findAllElements('feed').firstOrNull;
    if (feed != null) {
      return _parseAtom(feed, sourceUrl: sourceUrl);
    }
    throw RssException('无法识别的订阅格式（需要 RSS 或 Atom）');
  }

  ParsedFeed _parseRss(XmlElement channel, {String? sourceUrl}) {
    final title = _text(channel, 'title')?.trim();
    final link = _text(channel, 'link')?.trim();
    final siteUrl = _nonEmpty(link) ?? _siteFromUrl(sourceUrl);

    final items = <ParsedItem>[];
    for (final item in channel.findElements('item')) {
      final parsed = _parseRssItem(item);
      if (parsed != null) items.add(parsed);
    }

    return ParsedFeed(
      title: _nonEmpty(title) ?? _hostTitle(siteUrl) ?? '未命名源',
      siteUrl: siteUrl,
      items: items,
    );
  }

  ParsedItem? _parseRssItem(XmlElement item) {
    final title = _text(item, 'title')?.trim() ?? '';
    final link = _text(item, 'link')?.trim();
    final guidRaw = _text(item, 'guid')?.trim();
    final author =
        _text(item, 'author')?.trim() ??
        _text(item, 'dc:creator')?.trim() ??
        _childByLocal(item, 'creator')?.innerText.trim();
    final pubRaw =
        _text(item, 'pubDate')?.trim() ??
        _text(item, 'dc:date')?.trim() ??
        _childByLocal(item, 'date')?.innerText.trim();
    final description = _text(item, 'description');
    final contentEncoded = _childByLocal(item, 'encoded')?.innerText;

    final contentHtml = _nonEmpty(contentEncoded) ?? _nonEmpty(description);
    final contentText = _stripHtml(contentHtml ?? '');
    final summary = _clip(_stripHtml(description ?? contentHtml ?? ''), 280);

    final publishedAt = _parseDate(pubRaw) ?? DateTime.now();
    final guid = _resolveGuid(
      guid: guidRaw,
      link: link,
      title: title,
      publishedAt: publishedAt,
    );
    if (title.isEmpty && (link == null || link.isEmpty)) return null;

    final imageUrl = _extractImage(
      item: item,
      html: contentHtml,
      description: description,
    );
    final media = _rssMedia(item);

    return ParsedItem(
      guid: guid,
      title: title.isEmpty ? (link ?? '无标题') : title,
      link: link,
      author: _nonEmpty(author),
      summary: summary,
      contentHtml: contentHtml,
      contentText: contentText.isEmpty ? summary : contentText,
      imageUrl: imageUrl,
      mediaType: media?.type ?? ArticleMediaType.blog,
      enclosureUrl: media?.url,
      enclosureMime: media?.mime,
      enclosureLength: media?.length,
      durationSeconds: _extractDuration(item, media: media),
      publishedAt: publishedAt,
    );
  }

  ParsedFeed _parseAtom(XmlElement feed, {String? sourceUrl}) {
    final title = _text(feed, 'title')?.trim();
    final siteUrl =
        _atomLink(feed, rel: 'alternate') ??
        _atomLink(feed) ??
        _siteFromUrl(sourceUrl);

    final items = <ParsedItem>[];
    for (final entry in feed.findElements('entry')) {
      final parsed = _parseAtomEntry(entry);
      if (parsed != null) items.add(parsed);
    }

    return ParsedFeed(
      title: _nonEmpty(title) ?? _hostTitle(siteUrl) ?? '未命名源',
      siteUrl: siteUrl,
      items: items,
    );
  }

  ParsedItem? _parseAtomEntry(XmlElement entry) {
    final title = _text(entry, 'title')?.trim() ?? '';
    final link = _atomLink(entry, rel: 'alternate') ?? _atomLink(entry);
    final id = _text(entry, 'id')?.trim();
    final author = entry
        .findElements('author')
        .map((a) => _text(a, 'name')?.trim())
        .whereType<String>()
        .firstOrNull;
    final published =
        _text(entry, 'published')?.trim() ?? _text(entry, 'updated')?.trim();
    final summaryRaw = _text(entry, 'summary');
    final contentEl = entry.findElements('content').firstOrNull;
    final contentHtml = contentEl?.innerText ?? summaryRaw;

    final contentText = _stripHtml(contentHtml ?? '');
    final summary = _clip(_stripHtml(summaryRaw ?? contentHtml ?? ''), 280);
    final publishedAt = _parseDate(published) ?? DateTime.now();
    final guid = _resolveGuid(
      guid: id,
      link: link,
      title: title,
      publishedAt: publishedAt,
    );
    if (title.isEmpty && (link == null || link.isEmpty)) return null;

    final imageUrl = _extractImage(
      item: entry,
      html: contentHtml,
      description: summaryRaw,
    );
    final media = _atomMedia(entry);

    return ParsedItem(
      guid: guid,
      title: title.isEmpty ? (link ?? '无标题') : title,
      link: link,
      author: _nonEmpty(author),
      summary: summary,
      contentHtml: contentHtml,
      contentText: contentText.isEmpty ? summary : contentText,
      imageUrl: imageUrl,
      mediaType: media?.type ?? ArticleMediaType.blog,
      enclosureUrl: media?.url,
      enclosureMime: media?.mime,
      enclosureLength: media?.length,
      durationSeconds: _extractDuration(entry, media: media),
      publishedAt: publishedAt,
    );
  }

  // --- helpers ---

  String _resolveGuid({
    String? guid,
    String? link,
    required String title,
    required DateTime publishedAt,
  }) {
    final g = _nonEmpty(guid);
    if (g != null) return g;
    final l = _nonEmpty(link);
    if (l != null) return l;
    // Fallback: stable hash of title + published instant.
    final raw = '$title|${publishedAt.toUtc().toIso8601String()}';
    return sha1.convert(utf8.encode(raw)).toString();
  }

  String? _extractImage({
    required XmlElement item,
    String? html,
    String? description,
  }) {
    // media:thumbnail / media:content
    for (final el in item.descendantElements) {
      final local = el.name.local.toLowerCase();
      if (local == 'thumbnail' || local == 'content') {
        final url = el.getAttribute('url');
        final medium = (el.getAttribute('medium') ?? '').toLowerCase();
        final type = (el.getAttribute('type') ?? '').toLowerCase();
        if (url != null && url.isNotEmpty) {
          if (local == 'thumbnail' ||
              medium == 'image' ||
              type.startsWith('image/') ||
              _looksLikeImageUrl(url)) {
            return url;
          }
        }
      }
    }
    // enclosure
    for (final enc in item.findElements('enclosure')) {
      final type = enc.getAttribute('type') ?? '';
      final url = enc.getAttribute('url');
      if (url != null && url.isNotEmpty && type.startsWith('image/')) {
        return url;
      }
    }
    // first <img src> in html
    final blob = html ?? description;
    if (blob != null) {
      final m = RegExp(
        r'''<img[^>]+src=["']([^"']+)["']''',
        caseSensitive: false,
      ).firstMatch(blob);
      if (m != null) return m.group(1);
    }
    return null;
  }

  /// Media inference is deliberately article-level. MIME wins, then URL
  /// extension, and an item without a direct stream remains a normal blog.
  _MediaCandidate? _rssMedia(XmlElement item) {
    final candidates = <_MediaCandidate>[];
    for (final enclosure in item.findElements('enclosure')) {
      final candidate = _mediaCandidate(
        enclosure.getAttribute('url'),
        mime: enclosure.getAttribute('type'),
        length: enclosure.getAttribute('length'),
      );
      if (candidate != null) candidates.add(candidate);
    }
    for (final element in item.descendantElements) {
      if (element.name.local.toLowerCase() != 'content') continue;
      final candidate = _mediaCandidate(
        element.getAttribute('url'),
        mime: element.getAttribute('type'),
        length:
            element.getAttribute('fileSize') ?? element.getAttribute('length'),
        medium: element.getAttribute('medium'),
      );
      if (candidate != null) candidates.add(candidate);
    }
    return candidates.firstOrNull;
  }

  _MediaCandidate? _atomMedia(XmlElement entry) {
    for (final link in entry.findElements('link')) {
      if ((link.getAttribute('rel') ?? '').toLowerCase() != 'enclosure') {
        continue;
      }
      final candidate = _mediaCandidate(
        link.getAttribute('href'),
        mime: link.getAttribute('type'),
        length: link.getAttribute('length'),
      );
      if (candidate != null) return candidate;
    }
    return _rssMedia(entry);
  }

  _MediaCandidate? _mediaCandidate(
    String? rawUrl, {
    String? mime,
    String? length,
    String? medium,
  }) {
    final url = _nonEmpty(rawUrl);
    if (url == null) return null;
    final normalizedMime = _nonEmpty(mime)?.toLowerCase();
    final normalizedMedium = _nonEmpty(medium)?.toLowerCase();
    final type = _inferMediaType(
      url,
      mime: normalizedMime,
      medium: normalizedMedium,
    );
    if (type == ArticleMediaType.blog) return null;
    return _MediaCandidate(
      url: url,
      type: type,
      mime: normalizedMime,
      length: int.tryParse(length ?? ''),
    );
  }

  ArticleMediaType _inferMediaType(String url, {String? mime, String? medium}) {
    if (mime?.startsWith('video/') == true || medium == 'video') {
      return ArticleMediaType.video;
    }
    if (mime?.startsWith('audio/') == true || medium == 'audio') {
      return ArticleMediaType.audio;
    }
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    const videos = ['.mp4', '.webm', '.m3u8', '.mkv', '.mov', '.m4v'];
    const audios = ['.mp3', '.m4a', '.aac', '.ogg', '.opus', '.flac', '.wav'];
    if (videos.any(path.endsWith)) return ArticleMediaType.video;
    if (audios.any(path.endsWith)) return ArticleMediaType.audio;
    return ArticleMediaType.blog;
  }

  int? _extractDuration(XmlElement item, {_MediaCandidate? media}) {
    for (final element in item.descendantElements) {
      if (element.name.local.toLowerCase() == 'duration') {
        final parsed = _parseDuration(element.innerText);
        if (parsed != null) return parsed;
      }
      if (element.name.local.toLowerCase() == 'content' &&
          element.getAttribute('url') == media?.url) {
        final parsed = _parseDuration(element.getAttribute('duration'));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  int? _parseDuration(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    final seconds = int.tryParse(value);
    if (!value.contains(':')) return seconds;
    final parts = value.split(':').map(int.tryParse).toList();
    if (parts.any((part) => part == null)) return null;
    if (parts.length == 2) return parts[0]! * 60 + parts[1]!;
    if (parts.length == 3) {
      return parts[0]! * 3600 + parts[1]! * 60 + parts[2]!;
    }
    return null;
  }

  bool _looksLikeImageUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return const [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
      '.avif',
    ].any(path.endsWith);
  }

  String? _atomLink(XmlElement parent, {String? rel}) {
    for (final link in parent.findElements('link')) {
      final href = link.getAttribute('href');
      if (href == null || href.isEmpty) continue;
      final r = link.getAttribute('rel');
      if (rel == null) return href;
      if (r == rel || (rel == 'alternate' && r == null)) return href;
    }
    return null;
  }

  String? _text(XmlElement parent, String name) {
    final parts = name.split(':');
    if (parts.length == 2) {
      final el = _childByLocal(parent, parts[1]);
      return el?.innerText;
    }
    return parent.findElements(name).firstOrNull?.innerText;
  }

  XmlElement? _childByLocal(XmlElement parent, String local) {
    for (final c in parent.childElements) {
      if (c.name.local == local) return c;
    }
    return null;
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final s = raw.trim();
    // ISO-8601
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso.toLocal();
    // RFC 822-ish: "Mon, 02 Jan 2006 15:04:05 GMT"
    try {
      final cleaned = s.replaceAll(RegExp(r'\s+'), ' ');
      // Try without weekday
      final withoutWd = cleaned.contains(',')
          ? cleaned.split(',').skip(1).join(',').trim()
          : cleaned;
      final parts = withoutWd.split(' ');
      if (parts.length >= 5) {
        const months = {
          'jan': 1,
          'feb': 2,
          'mar': 3,
          'apr': 4,
          'may': 5,
          'jun': 6,
          'jul': 7,
          'aug': 8,
          'sep': 9,
          'oct': 10,
          'nov': 11,
          'dec': 12,
        };
        final day = int.tryParse(parts[0]);
        final month = months[parts[1].toLowerCase().substring(0, 3)];
        final year = int.tryParse(parts[2]);
        final time = parts[3].split(':');
        if (day != null && month != null && year != null && time.length >= 2) {
          final h = int.tryParse(time[0]) ?? 0;
          final m = int.tryParse(time[1]) ?? 0;
          final sec = time.length > 2 ? int.tryParse(time[2]) ?? 0 : 0;
          return DateTime.utc(year, month, day, h, m, sec).toLocal();
        }
      }
    } catch (_) {}
    return null;
  }

  String _stripHtml(String html) {
    var s = html
        .replaceAll(
          RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
    return s;
  }

  String _clip(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max).trimRight()}…';
  }

  String? _nonEmpty(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  String? _siteFromUrl(String? url) {
    if (url == null) return null;
    final u = Uri.tryParse(url);
    if (u == null || u.host.isEmpty) return null;
    return '${u.scheme}://${u.host}';
  }

  String? _hostTitle(String? siteUrl) {
    final u = Uri.tryParse(siteUrl ?? '');
    if (u == null || u.host.isEmpty) return null;
    return u.host.replaceFirst(RegExp(r'^www\.'), '');
  }
}

class _MediaCandidate {
  const _MediaCandidate({
    required this.url,
    required this.type,
    this.mime,
    this.length,
  });

  final String url;
  final ArticleMediaType type;
  final String? mime;
  final int? length;
}

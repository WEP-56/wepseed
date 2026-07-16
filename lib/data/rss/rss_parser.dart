import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';
import 'dart:convert';

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
    final author = _text(item, 'author')?.trim() ??
        _text(item, 'dc:creator')?.trim() ??
        _childByLocal(item, 'creator')?.innerText.trim();
    final pubRaw = _text(item, 'pubDate')?.trim() ??
        _text(item, 'dc:date')?.trim() ??
        _childByLocal(item, 'date')?.innerText.trim();
    final description = _text(item, 'description');
    final contentEncoded = _childByLocal(item, 'encoded')?.innerText;

    final contentHtml = _nonEmpty(contentEncoded) ?? _nonEmpty(description);
    final contentText = _stripHtml(contentHtml ?? '');
    final summary = _clip(
      _stripHtml(description ?? contentHtml ?? ''),
      280,
    );

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

    return ParsedItem(
      guid: guid,
      title: title.isEmpty ? (link ?? '无标题') : title,
      link: link,
      author: _nonEmpty(author),
      summary: summary,
      contentHtml: contentHtml,
      contentText: contentText.isEmpty ? summary : contentText,
      imageUrl: imageUrl,
      publishedAt: publishedAt,
    );
  }

  ParsedFeed _parseAtom(XmlElement feed, {String? sourceUrl}) {
    final title = _text(feed, 'title')?.trim();
    final siteUrl = _atomLink(feed, rel: 'alternate') ??
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
    final published = _text(entry, 'published')?.trim() ??
        _text(entry, 'updated')?.trim();
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

    return ParsedItem(
      guid: guid,
      title: title.isEmpty ? (link ?? '无标题') : title,
      link: link,
      author: _nonEmpty(author),
      summary: summary,
      contentHtml: contentHtml,
      contentText: contentText.isEmpty ? summary : contentText,
      imageUrl: imageUrl,
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
        final medium = el.getAttribute('medium') ?? el.getAttribute('type');
        if (url != null && url.isNotEmpty) {
          if (medium == null ||
              medium.contains('image') ||
              local == 'thumbnail') {
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
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false),
            ' ')
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false),
            ' ')
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

import '../models/models.dart';

/// Parsed feed metadata + items (parser output, not yet domain Article).
class ParsedFeed {
  const ParsedFeed({
    required this.title,
    required this.siteUrl,
    required this.items,
  });

  final String title;
  final String? siteUrl;
  final List<ParsedItem> items;
}

class ParsedItem {
  const ParsedItem({
    required this.guid,
    required this.title,
    required this.publishedAt,
    this.link,
    this.author,
    this.summary = '',
    this.contentHtml,
    this.contentText = '',
    this.imageUrl,
    this.mediaType = ArticleMediaType.blog,
    this.enclosureUrl,
    this.enclosureMime,
    this.enclosureLength,
    this.durationSeconds,
  });

  final String guid;
  final String title;
  final String? link;
  final String? author;
  final String summary;
  final String? contentHtml;
  final String contentText;
  final String? imageUrl;
  final ArticleMediaType mediaType;
  final String? enclosureUrl;
  final String? enclosureMime;
  final int? enclosureLength;
  final int? durationSeconds;
  final DateTime publishedAt;
}

class FeedFetchResult {
  const FeedFetchResult({
    required this.body,
    this.etag,
    this.lastModified,
    this.resolvedUrl,
    this.notModified = false,
  });

  final String? body;
  final String? etag;
  final String? lastModified;
  final String? resolvedUrl;
  final bool notModified;
}

class RssException implements Exception {
  RssException(this.message);
  final String message;

  @override
  String toString() => message;
}

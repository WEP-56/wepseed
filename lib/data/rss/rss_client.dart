import 'dart:convert';

import 'package:http/http.dart' as http;

import 'rss_models.dart';

/// HTTP wrapper for feed GETs, conditional requests, and common feed aliases.
class RssClient {
  RssClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Fallback when callers omit [timeout] (prefer mode-specific limits).
  static const defaultTimeout = Duration(seconds: 20);
  static const _userAgent = 'WEPSEED/1.0 (local-first RSS reader)';

  Future<FeedFetchResult> fetch(
    String url, {
    String? etag,
    String? lastModified,
    Duration? timeout,
  }) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      throw RssException('请输入有效的 http(s) 订阅地址');
    }
    final effectiveTimeout = timeout ?? defaultTimeout;

    final youtubeChannelId = _youtubeChannelIdFromUri(uri);
    if (youtubeChannelId != null) {
      return _fetchUri(
        _youtubeFeedUri(youtubeChannelId),
        etag: etag,
        lastModified: lastModified,
        timeout: effectiveTimeout,
      );
    }

    // YouTube's channel pages are HTML, but contain the UC... id required by
    // its official Atom endpoint. Do not send page validators: a 304 page has
    // no body from which to recover the canonical feed URL.
    if (_isYouTubeChannelPage(uri)) {
      final page = await _fetchUri(uri, timeout: effectiveTimeout);
      if (page.notModified || page.body == null) return page;
      final channelId = _youtubeChannelIdFromHtml(page.body!);
      if (channelId != null) {
        return _fetchUri(
          _youtubeFeedUri(channelId),
          timeout: effectiveTimeout,
        );
      }
      return page;
    }

    return _fetchUri(
      uri,
      etag: etag,
      lastModified: lastModified,
      timeout: effectiveTimeout,
    );
  }

  Future<FeedFetchResult> _fetchUri(
    Uri uri, {
    String? etag,
    String? lastModified,
    required Duration timeout,
  }) async {
    final headers = <String, String>{
      'User-Agent': _userAgent,
      'Accept':
          'application/rss+xml, application/atom+xml, application/xml, text/xml, */*',
    };
    if (etag != null && etag.isNotEmpty) headers['If-None-Match'] = etag;
    if (lastModified != null && lastModified.isNotEmpty) {
      headers['If-Modified-Since'] = lastModified;
    }

    late http.Response response;
    try {
      response = await _client.get(uri, headers: headers).timeout(timeout);
    } on Exception catch (e) {
      throw RssException(_networkMessage(e));
    }

    final resolvedUrl = response.request?.url.toString() ?? uri.toString();
    if (response.statusCode == 304) {
      return FeedFetchResult(
        body: null,
        etag: etag,
        lastModified: lastModified,
        resolvedUrl: resolvedUrl,
        notModified: true,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RssException('拉取失败 (HTTP ${response.statusCode})');
    }

    final body = _decodeXmlBody(response);
    if (body.trim().isEmpty) throw RssException('源返回了空内容');

    return FeedFetchResult(
      body: body,
      etag: response.headers['etag'],
      lastModified: response.headers['last-modified'],
      resolvedUrl: resolvedUrl,
    );
  }

  void close() => _client.close();

  String _decodeXmlBody(http.Response response) {
    final bytes = response.bodyBytes;
    if (bytes.length >= 3 &&
        bytes[0] == 0xef &&
        bytes[1] == 0xbb &&
        bytes[2] == 0xbf) {
      return utf8.decode(bytes.sublist(3), allowMalformed: true);
    }

    final declared = _declaredCharset(response);
    final encoding = declared == null ? null : Encoding.getByName(declared);
    if (encoding != null) return encoding.decode(bytes);

    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }

  String? _declaredCharset(http.Response response) {
    final fromHeader = RegExp(
      r'''charset\s*=\s*["']?([^;"'\s]+)''',
      caseSensitive: false,
    ).firstMatch(response.headers['content-type'] ?? '')?.group(1);
    if (fromHeader != null) return fromHeader.toLowerCase();

    // XML declarations are ASCII-compatible, so this can inspect the header
    // before choosing the decoder for the complete response body.
    final prefix = latin1.decode(
      response.bodyBytes.take(512).toList(growable: false),
    );
    return RegExp(
      r'''<\?xml[^>]*encoding\s*=\s*["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(prefix)?.group(1)?.toLowerCase();
  }

  bool _isYouTubeChannelPage(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host != 'youtube.com' && host != 'www.youtube.com') return false;
    return uri.path.startsWith('/@') ||
        uri.path.startsWith('/user/') ||
        uri.path.startsWith('/c/');
  }

  String? _youtubeChannelIdFromUri(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host != 'youtube.com' && host != 'www.youtube.com') return null;
    final segments = uri.pathSegments;
    if (segments.length < 2 || segments.first != 'channel') return null;
    final id = segments[1];
    return RegExp(r'^UC[\w-]{20,}$').hasMatch(id) ? id : null;
  }

  String? _youtubeChannelIdFromHtml(String html) {
    return RegExp(
      r'''["'](?:channelId|externalId)["']\s*:\s*["'](UC[\w-]{20,})["']''',
    ).firstMatch(html)?.group(1);
  }

  Uri _youtubeFeedUri(String channelId) => Uri.https(
    'www.youtube.com',
    '/feeds/videos.xml',
    {'channel_id': channelId},
  );

  String _networkMessage(Object e) {
    final s = e.toString();
    if (s.contains('TimeoutException') || s.contains('timed out')) {
      return '连接超时，请稍后重试';
    }
    if (s.contains('SocketException') || s.contains('Failed host lookup')) {
      return '网络不可用或域名无法解析';
    }
    if (s.contains('HandshakeException') || s.contains('CERTIFICATE')) {
      return '安全连接失败（证书问题）';
    }
    return '网络请求失败';
  }
}

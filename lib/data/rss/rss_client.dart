import 'package:http/http.dart' as http;

import 'rss_models.dart';

/// Thin HTTP wrapper for feed GET with conditional headers.
class RssClient {
  RssClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 25);
  static const _userAgent = 'WEPSEED/1.0 (local-first RSS reader)';

  Future<FeedFetchResult> fetch(
    String url, {
    String? etag,
    String? lastModified,
  }) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      throw RssException('请输入有效的 http(s) 订阅地址');
    }

    final headers = <String, String>{
      'User-Agent': _userAgent,
      'Accept':
          'application/rss+xml, application/atom+xml, application/xml, text/xml, */*',
    };
    if (etag != null && etag.isNotEmpty) {
      headers['If-None-Match'] = etag;
    }
    if (lastModified != null && lastModified.isNotEmpty) {
      headers['If-Modified-Since'] = lastModified;
    }

    late http.Response response;
    try {
      response = await _client.get(uri, headers: headers).timeout(_timeout);
    } on Exception catch (e) {
      throw RssException(_networkMessage(e));
    }

    if (response.statusCode == 304) {
      return FeedFetchResult(
        body: null,
        etag: etag,
        lastModified: lastModified,
        notModified: true,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RssException('拉取失败（HTTP ${response.statusCode}）');
    }

    final body = response.body;
    if (body.trim().isEmpty) {
      throw RssException('源返回了空内容');
    }

    return FeedFetchResult(
      body: body,
      etag: response.headers['etag'],
      lastModified: response.headers['last-modified'],
    );
  }

  void close() => _client.close();

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

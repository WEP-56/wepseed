import 'package:http/http.dart' as http;

import 'radar_models.dart';

class RadarProbeResult {
  const RadarProbeResult({
    required this.ok,
    required this.message,
    this.statusCode,
  });

  final bool ok;
  final String message;
  final int? statusCode;
}

/// Lightweight connectivity / feed-ish probe for radar "测试".
Future<RadarProbeResult> probeRadarUrl(
  String url, {
  http.Client? client,
  Duration timeout = const Duration(seconds: 12),
}) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return const RadarProbeResult(ok: false, message: 'URL 无效');
  }
  if (!radarPathIsComplete(uri.path)) {
    return const RadarProbeResult(ok: false, message: '请先填完必填参数');
  }

  final c = client ?? http.Client();
  final owned = client == null;
  try {
    final response = await c
        .get(
          uri,
          headers: {
            'User-Agent': 'WEPSEED/1.0 (RSSHub radar)',
            'Accept':
                'application/rss+xml, application/atom+xml, application/xml, text/xml, */*',
          },
        )
        .timeout(timeout);

    final code = response.statusCode;
    if (code == 304) {
      return RadarProbeResult(ok: true, message: 'HTTP 304 未修改', statusCode: code);
    }
    if (code < 200 || code >= 300) {
      return RadarProbeResult(
        ok: false,
        message: 'HTTP $code',
        statusCode: code,
      );
    }
    final body = response.body;
    final looksLikeFeed =
        body.contains('<rss') ||
        body.contains('<feed') ||
        body.contains('<channel') ||
        body.contains('<item') ||
        body.contains('<entry');
    if (!looksLikeFeed) {
      return RadarProbeResult(
        ok: false,
        message: 'HTTP $code，但内容不像 RSS/Atom',
        statusCode: code,
      );
    }
    return RadarProbeResult(
      ok: true,
      message: '可用 · HTTP $code · 已识别 feed',
      statusCode: code,
    );
  } on Exception catch (e) {
    final s = e.toString();
    if (s.contains('TimeoutException') || s.contains('timed out')) {
      return const RadarProbeResult(ok: false, message: '连接超时');
    }
    if (s.contains('SocketException') || s.contains('Failed host lookup')) {
      return const RadarProbeResult(ok: false, message: '网络不可用或域名无法解析');
    }
    return RadarProbeResult(ok: false, message: '请求失败');
  } finally {
    if (owned) c.close();
  }
}

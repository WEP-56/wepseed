import 'package:url_launcher/url_launcher.dart';

/// Known custom schemes → friendly app label (fallback when package unknown).
const Map<String, String> kAppSchemeLabels = {
  'bilibili': '哔哩哔哩',
  'bilibiliapp': '哔哩哔哩',
  'bilinovel': '哔哩哔哩漫画',
  'twitter': 'X',
  'x': 'X',
  'youtube': 'YouTube',
  'vnd.youtube': 'YouTube',
  'youtubetv': 'YouTube',
  'tg': 'Telegram',
  'telegram': 'Telegram',
  'weixin': '微信',
  'wechat': '微信',
  'alipays': '支付宝',
  'alipay': '支付宝',
  'taobao': '淘宝',
  'tmall': '天猫',
  'openapp.jdmobile': '京东',
  'snssdk1128': '抖音',
  'snssdk2329': '抖音极速版',
  'snssdk1233': '今日头条',
  'orpheus': '网易云音乐',
  'qqmusic': 'QQ音乐',
  'spotify': 'Spotify',
  'market': '应用商店',
  'itms-apps': 'App Store',
  'fb': 'Facebook',
  'instagram': 'Instagram',
  'whatsapp': 'WhatsApp',
  'line': 'LINE',
  'mailto': '邮件',
  'tel': '电话',
  'sms': '短信',
  'geo': '地图',
  'maps': '地图',
};

/// Android package → friendly name (from intent:// package=).
const Map<String, String> kAppPackageLabels = {
  'tv.danmaku.bili': '哔哩哔哩',
  'com.bilibili.app.in': '哔哩哔哩',
  'com.twitter.android': 'X',
  'com.google.android.youtube': 'YouTube',
  'org.telegram.messenger': 'Telegram',
  'com.tencent.mm': '微信',
  'com.eg.android.AlipayGphone': '支付宝',
  'com.ss.android.ugc.aweme': '抖音',
  'com.jingdong.app.mall': '京东',
  'com.taobao.taobao': '淘宝',
  'com.netease.cloudmusic': '网易云音乐',
  'com.spotify.music': 'Spotify',
  'com.android.vending': 'Google Play',
};

/// Host of the page that requested the app open (for dialog copy).
String requesterHost(String? pageUrl) {
  final uri = Uri.tryParse(pageUrl ?? '');
  final host = uri?.host.trim() ?? '';
  if (host.isEmpty) return '当前网页';
  return host.startsWith('www.') ? host.substring(4) : host;
}

/// Best-effort display name for the target app.
String targetAppLabel(String appUrl) {
  final package = intentPackage(appUrl);
  if (package != null && package.isNotEmpty) {
    final fromPkg = kAppPackageLabels[package];
    if (fromPkg != null) return fromPkg;
    // tv.danmaku.bili → last segment as weak fallback
    final short = package.split('.').last;
    if (short.isNotEmpty) return short;
  }

  final scheme = _schemeOf(appUrl);
  if (scheme != null) {
    final fromScheme = kAppSchemeLabels[scheme];
    if (fromScheme != null) return fromScheme;
    if (scheme.isNotEmpty && scheme != 'intent') {
      return scheme;
    }
  }

  return '外部应用';
}

/// package=… from Android intent:// URLs.
String? intentPackage(String url) {
  if (!url.startsWith('intent:')) return null;
  return RegExp(r';package=([^;]+)').firstMatch(url)?.group(1);
}

/// scheme=… from Android intent:// URLs.
String? intentScheme(String url) {
  if (!url.startsWith('intent:')) return null;
  return RegExp(r';scheme=([^;]+)').firstMatch(url)?.group(1);
}

/// S.browser_fallback_url from Android intent:// URLs.
String? intentFallbackUrl(String url) {
  if (!url.startsWith('intent:')) return null;
  final raw = RegExp(r'S\.browser_fallback_url=([^;]+)')
      .firstMatch(url)
      ?.group(1);
  if (raw == null || raw.isEmpty) return null;
  try {
    return Uri.decodeComponent(raw);
  } catch (_) {
    return raw;
  }
}

String? _schemeOf(String url) {
  if (url.startsWith('intent:')) {
    return intentScheme(url)?.toLowerCase();
  }
  final uri = Uri.tryParse(url);
  final s = uri?.scheme.toLowerCase();
  if (s == null || s.isEmpty) return null;
  return s;
}

/// Launch a non-http deep link / intent:// after user consent.
///
/// Tries the raw URL first, then intent scheme rebuild, then browser fallback.
Future<bool> launchAppLink(String url) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return false;

  // 1) Direct launch (works for bilibili://, twitter://, mailto:, etc.)
  if (await _tryLaunch(trimmed)) return true;

  // 2) intent:// → rebuild as scheme://host/path
  if (trimmed.startsWith('intent:')) {
    final rebuilt = _rebuildIntentAsCustomScheme(trimmed);
    if (rebuilt != null && await _tryLaunch(rebuilt)) return true;

    final fallback = intentFallbackUrl(trimmed);
    if (fallback != null && await _tryLaunch(fallback)) return true;

    final pkg = intentPackage(trimmed);
    if (pkg != null && pkg.isNotEmpty) {
      final market = 'market://details?id=$pkg';
      if (await _tryLaunch(market)) return true;
    }
  }

  return false;
}

String? _rebuildIntentAsCustomScheme(String intentUrl) {
  final scheme = intentScheme(intentUrl);
  if (scheme == null || scheme.isEmpty) return null;

  // intent://host/path?query#Intent;scheme=xxx;end
  // → xxx://host/path?query
  final withoutPrefix = intentUrl.replaceFirst(RegExp(r'^intent:'), '');
  final hash = withoutPrefix.indexOf('#');
  final body = hash >= 0 ? withoutPrefix.substring(0, hash) : withoutPrefix;
  // body often starts with //host/...
  if (body.startsWith('//')) {
    return '$scheme:$body';
  }
  if (body.startsWith('/')) {
    return '$scheme:/$body';
  }
  return '$scheme://$body';
}

Future<bool> _tryLaunch(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

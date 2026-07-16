import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_links.dart';

class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  final String name;
  final String downloadUrl;
  final int size;
}

class GithubReleaseInfo {
  const GithubReleaseInfo({
    required this.tagName,
    required this.version,
    required this.body,
    required this.htmlUrl,
    required this.assets,
  });

  final String tagName;
  final String version;
  final String body;
  final String htmlUrl;
  final List<ReleaseAsset> assets;
}

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.currentVersion,
    required this.latest,
    required this.hasUpdate,
  });

  final String currentVersion;
  final GithubReleaseInfo? latest;
  final bool hasUpdate;
}

/// Compare dotted versions (major.minor.patch…). Returns negative if a < b.
int compareSemver(String a, String b) {
  List<int> parts(String v) {
    final cleaned = v.trim();
    final core = cleaned.startsWith('v') || cleaned.startsWith('V')
        ? cleaned.substring(1)
        : cleaned;
    final main = core.split('+').first.split('-').first;
    return main
        .split('.')
        .map((s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
  }

  final pa = parts(a);
  final pb = parts(b);
  final n = pa.length > pb.length ? pa.length : pb.length;
  for (var i = 0; i < n; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

String normalizeVersionTag(String tag) {
  final t = tag.trim();
  if (t.startsWith('v') || t.startsWith('V')) return t.substring(1);
  return t;
}

class GithubUpdateService {
  GithubUpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<GithubReleaseInfo> fetchLatestRelease() async {
    final res = await _client
        .get(
          Uri.parse(kGithubReleasesLatestApi),
          headers: {
            'Accept': 'application/vnd.github+json',
            'User-Agent': 'wepseed-android',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw StateError('检查更新失败（HTTP ${res.statusCode}）');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final tag = (data['tag_name'] as String?) ?? '';
    final assetsRaw = data['assets'];
    final assets = <ReleaseAsset>[];
    if (assetsRaw is List) {
      for (final item in assetsRaw) {
        if (item is! Map) continue;
        final name = item['name'] as String? ?? '';
        final url = item['browser_download_url'] as String? ?? '';
        final size = (item['size'] as num?)?.toInt() ?? 0;
        if (name.isEmpty || url.isEmpty) continue;
        assets.add(ReleaseAsset(name: name, downloadUrl: url, size: size));
      }
    }
    return GithubReleaseInfo(
      tagName: tag,
      version: normalizeVersionTag(tag),
      body: (data['body'] as String?)?.trim() ?? '',
      htmlUrl: (data['html_url'] as String?) ?? kGithubReleases,
      assets: assets,
    );
  }

  Future<UpdateCheckResult> check(String currentVersion) async {
    final latest = await fetchLatestRelease();
    final hasUpdate = compareSemver(currentVersion, latest.version) < 0;
    return UpdateCheckResult(
      currentVersion: currentVersion,
      latest: latest,
      hasUpdate: hasUpdate,
    );
  }

  /// Prefer arm64, then armeabi-v7a, then x86_64.
  ReleaseAsset? pickApkAsset(GithubReleaseInfo release) {
    const order = ['arm64-v8a', 'armeabi-v7a', 'x86_64'];
    for (final abi in order) {
      for (final a in release.assets) {
        final n = a.name.toLowerCase();
        if (n.endsWith('.apk') && n.contains(abi)) return a;
      }
    }
    for (final a in release.assets) {
      if (a.name.toLowerCase().endsWith('.apk')) return a;
    }
    return null;
  }

  Future<File> downloadApk(
    ReleaseAsset asset, {
    void Function(double progress)? onProgress,
  }) async {
    final req = http.Request('GET', Uri.parse(asset.downloadUrl));
    req.headers['User-Agent'] = 'wepseed-android';
    final streamed = await _client.send(req).timeout(const Duration(minutes: 10));
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw StateError('下载失败（HTTP ${streamed.statusCode}）');
    }
    final total = streamed.contentLength ?? asset.size;
    final dir = await getTemporaryDirectory();
    final updates = Directory(p.join(dir.path, 'updates'));
    if (!await updates.exists()) {
      await updates.create(recursive: true);
    }
    final file = File(p.join(updates.path, asset.name));
    final sink = file.openWrite();
    var received = 0;
    try {
      await for (final chunk in streamed.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0 && onProgress != null) {
          onProgress((received / total).clamp(0.0, 1.0));
        }
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    if (onProgress != null) onProgress(1);
    return file;
  }
}

import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import 'download_service.dart';

/// Measures and clears local image / temp / WebView caches (not user data).
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  /// Total bytes of clearable cache buckets we own.
  Future<int> measureBytes() async {
    var total = 0;
    total += await _dirSize(await _tempDir());
    total += await _dirSize(await _cacheDir());
    return total;
  }

  Future<String> measureLabel() async {
    final bytes = await measureBytes();
    return DownloadService.formatBytes(bytes);
  }

  /// Clear image disk cache, temp files, and WebView HTTP cache.
  /// Does **not** wipe downloads, DB, or secure keys.
  Future<void> clearAll() async {
    try {
      await InAppWebViewController.clearAllCache();
    } catch (_) {}

    try {
      await CookieManager.instance().deleteAllCookies();
    } catch (_) {}

    await _wipeDirContents(await _tempDir());
    // Only wipe flutter-owned cache subdirs that are safe; keep code cache etc.
    final cache = await _cacheDir();
    if (cache != null) {
      for (final name in const [
        'libCachedImageData',
        'libCachedImageDataKey',
        'flutter_cache_manager',
        'DefaultCacheManager',
      ]) {
        final sub = Directory('${cache.path}${Platform.pathSeparator}$name');
        if (await sub.exists()) {
          try {
            await sub.delete(recursive: true);
          } catch (_) {}
        }
      }
    }
  }

  Future<Directory?> _tempDir() async {
    try {
      return await getTemporaryDirectory();
    } catch (_) {
      return null;
    }
  }

  Future<Directory?> _cacheDir() async {
    try {
      return await getApplicationCacheDirectory();
    } catch (_) {
      try {
        return await getTemporaryDirectory();
      } catch (_) {
        return null;
      }
    }
  }

  Future<int> _dirSize(Directory? dir) async {
    if (dir == null || !await dir.exists()) return 0;
    var total = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  Future<void> _wipeDirContents(Directory? dir) async {
    if (dir == null || !await dir.exists()) return;
    try {
      await for (final entity in dir.list(followLinks: false)) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {}
      }
    } catch (_) {}
  }
}

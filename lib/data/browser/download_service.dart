import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'download_models.dart';

/// File downloads for the in-app browser (records under app support).
class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  static const _indexFileName = 'browser_downloads.json';

  final Map<String, http.Client> _clients = {};

  Future<Directory> downloadDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'downloads'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _indexFile() async {
    final base = await getApplicationSupportDirectory();
    return File(p.join(base.path, _indexFileName));
  }

  Future<List<DownloadItem>> loadItems() async {
    final file = await _indexFile();
    if (!await file.exists()) return [];
    try {
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return list
          .map((e) => DownloadItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveItems(List<DownloadItem> items) async {
    final file = await _indexFile();
    await file.writeAsString(
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Resolve a unique path under the downloads directory.
  Future<String> uniqueSavePath(String fileName) async {
    final dir = await downloadDir();
    final sanitized = _sanitizeFileName(fileName);
    var candidate = p.join(dir.path, sanitized);
    if (!await File(candidate).exists()) return candidate;

    final stem = p.basenameWithoutExtension(sanitized);
    final ext = p.extension(sanitized);
    for (var i = 1; i < 1000; i++) {
      candidate = p.join(dir.path, '$stem ($i)$ext');
      if (!await File(candidate).exists()) return candidate;
    }
    return p.join(
      dir.path,
      '$stem-${DateTime.now().millisecondsSinceEpoch}$ext',
    );
  }

  static String resolveFileName(String url, {String? suggested}) {
    final fromSuggest = suggested?.trim();
    if (fromSuggest != null && fromSuggest.isNotEmpty) {
      return _sanitizeFileName(fromSuggest);
    }
    final uri = Uri.tryParse(url);
    final last = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : null;
    if (last != null && last.isNotEmpty && last.contains('.')) {
      return _sanitizeFileName(Uri.decodeComponent(last));
    }
    return 'download-${DateTime.now().millisecondsSinceEpoch}';
  }

  static String _sanitizeFileName(String name) {
    final cleaned = name
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .trim();
    if (cleaned.isEmpty || cleaned == '.' || cleaned == '..') {
      return 'download';
    }
    return cleaned.length > 180 ? cleaned.substring(0, 180) : cleaned;
  }

  /// Stream download to [savePath]. Cancel via returned [Completer] cancel.
  Future<void> download({
    required String url,
    required String savePath,
    required void Function(int received, int total) onProgress,
    required bool Function() isCancelled,
  }) async {
    final client = http.Client();
    _clients[savePath] = client;
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          uri: Uri.tryParse(url),
        );
      }

      final total = response.contentLength ?? -1;
      final file = File(savePath);
      final sink = file.openWrite();
      var received = 0;
      try {
        await for (final chunk in response.stream) {
          if (isCancelled()) {
            await sink.close();
            if (await file.exists()) await file.delete();
            throw const DownloadCancelled();
          }
          sink.add(chunk);
          received += chunk.length;
          onProgress(received, total);
        }
        await sink.flush();
        await sink.close();
      } catch (e) {
        await sink.close();
        rethrow;
      }
    } finally {
      client.close();
      _clients.remove(savePath);
    }
  }

  void cancelByPath(String savePath) {
    _clients.remove(savePath)?.close();
  }

  Future<bool> deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> renameFile(String oldPath, String newFileName) async {
    final file = File(oldPath);
    if (!await file.exists()) return false;
    final dir = p.dirname(oldPath);
    final target = p.join(dir, _sanitizeFileName(newFileName));
    if (target == oldPath) return true;
    if (await File(target).exists()) return false;
    await file.rename(target);
    return true;
  }

  static String formatBytes(int bytes) {
    if (bytes < 0) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class DownloadCancelled implements Exception {
  const DownloadCancelled();
  @override
  String toString() => 'DownloadCancelled';
}

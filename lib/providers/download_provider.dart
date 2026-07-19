import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../data/browser/download_models.dart';
import '../data/browser/download_service.dart';

export '../data/browser/download_models.dart';

final downloadListProvider =
    NotifierProvider<DownloadListNotifier, List<DownloadItem>>(
      DownloadListNotifier.new,
    );

class DownloadListNotifier extends Notifier<List<DownloadItem>> {
  final Set<String> _cancelled = {};

  @override
  List<DownloadItem> build() {
    Future.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final items = await DownloadService.instance.loadItems();
    final fixed = items
        .map(
          (e) => e.status == DownloadStatus.downloading
              ? e.copyWith(status: DownloadStatus.failed, progress: 0)
              : e,
        )
        .toList();
    state = fixed;
    await DownloadService.instance.saveItems(fixed);
  }

  Future<void> _persist() => DownloadService.instance.saveItems(state);

  Future<void> startDownload({
    required String url,
    String? suggestedFilename,
    String? mimeType,
    int? contentLength,
  }) async {
    final fileName = DownloadService.resolveFileName(
      url,
      suggested: suggestedFilename,
    );
    final savePath = await DownloadService.instance.uniqueSavePath(fileName);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = DownloadItem(
      id: id,
      url: url,
      fileName: p.basename(savePath),
      savePath: savePath,
      fileSize: contentLength ?? 0,
      createdAt: DateTime.now(),
      mimeType: mimeType,
    );
    state = [item, ...state];
    await _persist();

    _cancelled.remove(id);
    try {
      await DownloadService.instance.download(
        url: url,
        savePath: savePath,
        isCancelled: () => _cancelled.contains(id),
        onProgress: (received, total) {
          final progress = total > 0 ? received / total : 0.0;
          _patch(
            id,
            (e) => e.copyWith(
              progress: progress,
              fileSize: total > 0 ? total : e.fileSize,
            ),
          );
        },
      );
      if (_cancelled.contains(id)) return;
      var size = 0;
      try {
        size = await File(savePath).length();
      } catch (_) {}
      _patch(
        id,
        (e) => e.copyWith(
          status: DownloadStatus.completed,
          progress: 1,
          fileSize: size > 0 ? size : e.fileSize,
        ),
      );
      await _persist();
    } on DownloadCancelled {
      // Cancelled by user.
    } catch (e, st) {
      debugPrint('[Download] failed: $e\n$st');
      _patch(id, (e) => e.copyWith(status: DownloadStatus.failed));
      await _persist();
    }
  }

  Future<void> cancel(String id) async {
    _cancelled.add(id);
    DownloadItem? item;
    for (final e in state) {
      if (e.id == id) {
        item = e;
        break;
      }
    }
    if (item != null) {
      DownloadService.instance.cancelByPath(item.savePath);
      await DownloadService.instance.deleteFile(item.savePath);
    }
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> remove(String id, {bool deleteFile = true}) async {
    DownloadItem? item;
    for (final e in state) {
      if (e.id == id) {
        item = e;
        break;
      }
    }
    if (item == null) return;
    if (item.status == DownloadStatus.downloading) {
      await cancel(id);
      return;
    }
    if (deleteFile) {
      await DownloadService.instance.deleteFile(item.savePath);
    }
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  /// Rename completed download (file on disk + record).
  Future<bool> rename(String id, String newName) async {
    DownloadItem? item;
    for (final e in state) {
      if (e.id == id) {
        item = e;
        break;
      }
    }
    if (item == null || item.status != DownloadStatus.completed) return false;
    final cleaned = newName.trim();
    if (cleaned.isEmpty) return false;

    final sanitized = DownloadService.resolveFileName(
      item.url,
      suggested: cleaned,
    );
    final newPath = p.join(p.dirname(item.savePath), sanitized);
    if (newPath == item.savePath) return true;

    final file = File(item.savePath);
    if (!await file.exists()) return false;
    if (await File(newPath).exists()) return false;

    await file.rename(newPath);
    _patch(
      id,
      (e) => e.copyWith(fileName: sanitized, savePath: newPath),
    );
    await _persist();
    return true;
  }

  Future<void> clearFinished({bool deleteFiles = true}) async {
    final keep = <DownloadItem>[];
    for (final item in state) {
      if (item.status == DownloadStatus.downloading) {
        keep.add(item);
        continue;
      }
      if (deleteFiles) {
        await DownloadService.instance.deleteFile(item.savePath);
      }
    }
    state = keep;
    await _persist();
  }

  Future<void> retry(DownloadItem item) async {
    await remove(item.id, deleteFile: true);
    await startDownload(
      url: item.url,
      suggestedFilename: item.fileName,
      mimeType: item.mimeType,
    );
  }

  void _patch(String id, DownloadItem Function(DownloadItem) fn) {
    state = [
      for (final e in state)
        if (e.id == id) fn(e) else e,
    ];
  }
}

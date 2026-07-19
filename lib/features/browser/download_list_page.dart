import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../data/browser/download_service.dart';
import '../../providers/download_provider.dart';
import '../../widgets/liquid_glass.dart';

/// Download records from the in-app browser (open / rename / delete).
class DownloadListPage extends ConsumerWidget {
  const DownloadListPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DownloadListPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(downloadListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: top + 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                LiquidGlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '下载管理',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (items.any((e) => e.status != DownloadStatus.downloading))
                  TextButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('清除记录'),
                          content: const Text(
                            '删除所有已完成 / 失败的下载记录，并移除本地文件？',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('清除'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(downloadListProvider.notifier)
                            .clearFinished();
                        if (context.mounted) {
                          showAppToast('已清除', context: context);
                        }
                      }
                    },
                    child: const Text('清除完成'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      '还没有下载记录',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _DownloadTile(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final notifier = ref.read(downloadListProvider.notifier);

    final statusLabel = switch (item.status) {
      DownloadStatus.downloading =>
        '下载中 ${(item.progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
      DownloadStatus.completed => DownloadService.formatBytes(item.fileSize),
      DownloadStatus.failed => '失败',
    };

    return Material(
      color: isDark ? AppColors.inkCard : AppColors.wash,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.status == DownloadStatus.completed
            ? () async {
                final exists = await File(item.savePath).exists();
                if (!context.mounted) return;
                if (!exists) {
                  showAppToast('文件不存在', context: context);
                  return;
                }
                await OpenFilex.open(item.savePath);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              Icon(
                switch (item.status) {
                  DownloadStatus.downloading => Icons.downloading_rounded,
                  DownloadStatus.completed => Icons.insert_drive_file_outlined,
                  DownloadStatus.failed => Icons.error_outline_rounded,
                },
                color: secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: item.status == DownloadStatus.failed
                            ? theme.colorScheme.error
                            : secondary,
                      ),
                    ),
                    if (item.status == DownloadStatus.downloading) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: item.progress > 0 && item.progress < 1
                              ? item.progress
                              : null,
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  switch (v) {
                    case 'open':
                      final exists = await File(item.savePath).exists();
                      if (!context.mounted) return;
                      if (!exists) {
                        showAppToast('文件不存在', context: context);
                        return;
                      }
                      await OpenFilex.open(item.savePath);
                    case 'rename':
                      final name = await _promptRename(
                        context,
                        item.fileName,
                      );
                      if (name == null || !context.mounted) return;
                      final ok = await notifier.rename(item.id, name);
                      if (context.mounted) {
                        showAppToast(
                          ok ? '已重命名' : '重命名失败',
                          context: context,
                        );
                      }
                    case 'retry':
                      await notifier.retry(item);
                    case 'cancel':
                      await notifier.cancel(item.id);
                    case 'delete':
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('删除下载'),
                          content: Text('删除「${item.fileName}」及其本地文件？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await notifier.remove(item.id);
                        if (context.mounted) {
                          showAppToast('已删除', context: context);
                        }
                      }
                  }
                },
                itemBuilder: (_) {
                  final entries = <PopupMenuEntry<String>>[];
                  if (item.status == DownloadStatus.completed) {
                    entries.addAll(const [
                      PopupMenuItem(value: 'open', child: Text('打开')),
                      PopupMenuItem(value: 'rename', child: Text('重命名')),
                    ]);
                  }
                  if (item.status == DownloadStatus.failed) {
                    entries.add(
                      const PopupMenuItem(value: 'retry', child: Text('重试')),
                    );
                  }
                  if (item.status == DownloadStatus.downloading) {
                    entries.add(
                      const PopupMenuItem(value: 'cancel', child: Text('取消')),
                    );
                  } else {
                    entries.add(
                      const PopupMenuItem(value: 'delete', child: Text('删除')),
                    );
                  }
                  return entries;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _promptRename(BuildContext context, String current) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _RenameDialog(initialName: current),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('重命名'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: '文件名',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

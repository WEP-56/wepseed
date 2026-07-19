import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../core/utils/open_url.dart';
import '../../providers/browser_library_provider.dart';
import '../../widgets/liquid_glass.dart';

/// Bookmarks list (open / rename / delete).
class WebBookmarksPage extends ConsumerWidget {
  const WebBookmarksPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WebBookmarksPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(webBookmarkProvider);
    return _LibraryScaffold(
      title: '网页收藏',
      emptyLabel: '还没有收藏的网页',
      trailing: items.isEmpty
          ? null
          : TextButton(
              onPressed: () async {
                final ok = await _confirm(
                  context,
                  title: '清空收藏',
                  body: '确定清空全部网页收藏？',
                );
                if (ok == true) {
                  await ref.read(webBookmarkProvider.notifier).clearAll();
                  if (context.mounted) {
                    showAppToast('已清空收藏', context: context);
                  }
                }
              },
              child: const Text('清空'),
            ),
      child: items.isEmpty
          ? null
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = items[i];
                return _LibraryTile(
                  title: item.title.isNotEmpty ? item.title : item.url,
                  subtitle: item.url,
                  onOpen: () => openUrl(
                    item.url,
                    context: context,
                    title: item.title,
                  ),
                  menu: [
                    const PopupMenuItem(value: 'open', child: Text('打开')),
                    const PopupMenuItem(value: 'rename', child: Text('改标题')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                  onMenu: (v) async {
                    switch (v) {
                      case 'open':
                        await openUrl(
                          item.url,
                          context: context,
                          title: item.title,
                        );
                      case 'rename':
                        final name = await _promptText(
                          context,
                          title: '改标题',
                          initial: item.title,
                          label: '标题',
                        );
                        if (name != null && name.trim().isNotEmpty) {
                          await ref
                              .read(webBookmarkProvider.notifier)
                              .rename(item.url, name);
                        }
                      case 'delete':
                        await ref
                            .read(webBookmarkProvider.notifier)
                            .removeByUrl(item.url);
                        if (context.mounted) {
                          showAppToast('已删除', context: context);
                        }
                    }
                  },
                );
              },
            ),
    );
  }
}

/// Browsing history (open / delete / clear).
class WebHistoryPage extends ConsumerWidget {
  const WebHistoryPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WebHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(webHistoryProvider);
    return _LibraryScaffold(
      title: '浏览历史',
      emptyLabel: '还没有浏览记录',
      trailing: items.isEmpty
          ? null
          : TextButton(
              onPressed: () async {
                final ok = await _confirm(
                  context,
                  title: '清空历史',
                  body: '确定清空全部浏览历史？',
                );
                if (ok == true) {
                  await ref.read(webHistoryProvider.notifier).clearAll();
                  if (context.mounted) {
                    showAppToast('历史已清空', context: context);
                  }
                }
              },
              child: const Text('清空'),
            ),
      child: items.isEmpty
          ? null
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = items[i];
                return _LibraryTile(
                  title: item.title.isNotEmpty ? item.title : item.url,
                  subtitle: item.url,
                  meta: _relative(item.visitedAt),
                  onOpen: () => openUrl(
                    item.url,
                    context: context,
                    title: item.title,
                  ),
                  menu: const [
                    PopupMenuItem(value: 'open', child: Text('打开')),
                    PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                  onMenu: (v) async {
                    switch (v) {
                      case 'open':
                        await openUrl(
                          item.url,
                          context: context,
                          title: item.title,
                        );
                      case 'delete':
                        await ref
                            .read(webHistoryProvider.notifier)
                            .removeByUrl(item.url);
                    }
                  },
                );
              },
            ),
    );
  }

  static String _relative(DateTime t) {
    final now = DateTime.now();
    final d = now.difference(t);
    if (d.inMinutes < 1) return '刚刚';
    if (d.inHours < 1) return '${d.inMinutes} 分钟前';
    if (d.inDays < 1) return '${d.inHours} 小时前';
    if (d.inDays < 7) return '${d.inDays} 天前';
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }
}

class _LibraryScaffold extends StatelessWidget {
  const _LibraryScaffold({
    required this.title,
    required this.emptyLabel,
    this.trailing,
    this.child,
  });

  final String title;
  final String emptyLabel;
  final Widget? trailing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
            child: Row(
              children: [
                LiquidGlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Expanded(
            child: child ??
                Center(
                  child: Text(
                    emptyLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondary,
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.title,
    required this.subtitle,
    required this.onOpen,
    required this.menu,
    required this.onMenu,
    this.meta,
  });

  final String title;
  final String subtitle;
  final String? meta;
  final VoidCallback onOpen;
  final List<PopupMenuEntry<String>> menu;
  final ValueChanged<String> onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Material(
      color: isDark ? AppColors.inkCard : AppColors.wash,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              Icon(Icons.public_rounded, color: secondary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: secondary,
                      ),
                    ),
                    if (meta != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: onMenu,
                itemBuilder: (_) => menu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> _confirm(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String initial,
  required String label,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _TextPromptDialog(
      title: title,
      initial: initial,
      label: label,
    ),
  );
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.initial,
    required this.label,
  });

  final String title;
  final String initial;
  final String label;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../core/utils/time_labels.dart';
import '../../data/models/models.dart';
import '../../providers/article_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/me_providers.dart';
import '../../widgets/pressable.dart';

/// Which ME stat chip opened this list.
enum MeListKind { bookmarks, chats, traces }

extension MeListKindX on MeListKind {
  String get title => switch (this) {
    MeListKind.bookmarks => '收藏',
    MeListKind.chats => '对话',
    MeListKind.traces => '痕迹',
  };

  String get emptyHint => switch (this) {
    MeListKind.bookmarks => '还没有收藏，读文章时点 Save 即可',
    MeListKind.chats => '还没有对话，在评论区回复网友会出现在这里',
    MeListKind.traces => '还没有温度痕迹，多读一会儿就会留下驻留等记录',
  };

  Set<MeEventType>? get eventTypes => switch (this) {
    MeListKind.bookmarks => null,
    MeListKind.chats => {MeEventType.chat},
    MeListKind.traces => {
      MeEventType.dwell,
      MeEventType.binge,
      MeEventType.streak,
      MeEventType.nightOwl,
    },
  };
}

class MeListPage extends ConsumerWidget {
  const MeListPage({super.key, required this.kind});

  final MeListKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8, top + 4, 12, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    kind.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _confirmClearAll(context, ref),
                  child: Text(
                    '清空',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(context, ref, isDark)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, bool isDark) {
    if (kind == MeListKind.bookmarks) {
      final async = ref.watch(bookmarkedArticlesProvider);
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (articles) {
          if (articles.isEmpty) return _Empty(kind: kind, isDark: isDark);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            itemCount: articles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = articles[i];
              return _SwipeDelete(
                dismissKey: ValueKey('bm-${a.id}'),
                onDelete: () async {
                  await ref
                      .read(articleActionsProvider)
                      .setBookmarked(a.id, false);
                  if (context.mounted) {
                    showAppToast('已取消收藏', context: context);
                  }
                },
                child: _ArticleRow(
                  title: a.title,
                  subtitle: a.source.name,
                  onTap: () => context.push(
                    '/article/${Uri.encodeComponent(a.id)}',
                  ),
                ),
              );
            },
          );
        },
      );
    }

    final types = kind.eventTypes!;
    final async = ref.watch(meEventsByTypesProvider(types));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (events) {
        if (events.isEmpty) return _Empty(kind: kind, isDark: isDark);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          itemCount: events.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final e = events[i];
            return _SwipeDelete(
              dismissKey: ValueKey('ev-${e.id}'),
              onDelete: () async {
                await ref.read(warmEventRepositoryProvider).remove(e.id);
                if (context.mounted) {
                  showAppToast('已删除', context: context);
                }
              },
              child: _EventRow(
                event: e,
                onTap: e.articleId == null
                    ? null
                    : () => context.push(
                        '/article/${Uri.encodeComponent(e.articleId!)}',
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('清空${kind.title}？'),
        content: Text(
          kind == MeListKind.bookmarks
              ? '将取消全部收藏，文章本身不会删除。'
              : '将删除本类时间轴记录，不可恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    if (kind == MeListKind.bookmarks) {
      final articles =
          ref.read(bookmarkedArticlesProvider).value ?? const <Article>[];
      final actions = ref.read(articleActionsProvider);
      for (final a in articles) {
        await actions.setBookmarked(a.id, false);
      }
    } else {
      await ref
          .read(warmEventRepositoryProvider)
          .removeByTypes(kind.eventTypes!);
    }
    if (context.mounted) {
      showAppToast('已清空${kind.title}', context: context);
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.kind, required this.isDark});

  final MeListKind kind;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          kind.emptyHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _SwipeDelete extends StatelessWidget {
  const _SwipeDelete({
    required this.dismissKey,
    required this.onDelete,
    required this.child,
  });

  final Key dismissKey;
  final Future<void> Function() onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissKey,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
      ),
      confirmDismiss: (_) async {
        await onDelete();
        return true;
      },
      child: child,
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inkCard : AppColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, this.onTap});

  final MeEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inkCard : AppColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  clockLabel(event.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              event.subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
            if (event.type != MeEventType.chat &&
                event.type != MeEventType.bookmark) ...[
              const SizedBox(height: 6),
              Text(
                _traceLabel(event.type),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _traceLabel(MeEventType type) => switch (type) {
    MeEventType.dwell => '驻留',
    MeEventType.binge => '连读',
    MeEventType.streak => '连续',
    MeEventType.nightOwl => '夜读',
    _ => '',
  };
}

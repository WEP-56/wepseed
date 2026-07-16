import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../core/utils/monogram.dart';
import '../../data/models/models.dart';
import '../../providers/article_providers.dart';
import '../../providers/feed_providers.dart';
import '../../providers/settings_provider.dart';
import '../../providers/shell_providers.dart';
import '../../widgets/app_network_image.dart';
import 'feed_card.dart';

/// New feed — masonry stream without left-edge timeline scrubber.
class NewPage extends ConsumerWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final articlesAsync = ref.watch(filteredArticlesProvider);
    final feedsAsync = ref.watch(feedsProvider);
    final filter = ref.watch(feedFilterProvider);
    final articles = articlesAsync.value ?? const <Article>[];
    final feeds = feedsAsync.value ?? const [];
    final loading = articlesAsync.isLoading && !articlesAsync.hasValue;

    Future<void> onRefresh() async {
      try {
        final ids = filter.feedIds;
        await ref.read(feedActionsProvider).refreshAll(
          feedIds: ids.isEmpty ? null : ids,
        );
      } catch (e) {
        if (context.mounted) showAppToast('$e', context: context);
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: top + 8,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 10, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'New',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const Spacer(),
                      _FilterButton(
                        active: !filter.isDefault,
                        isDark: isDark,
                        onTap: () => _openFilterSheet(context, ref),
                      ),
                    ],
                  ),
                  Text(
                    'Subscriptions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (feeds.isEmpty)
                    _EmptySourcesHint(
                      isDark: isDark,
                      onAdd: () =>
                          ref.read(tabIndexProvider.notifier).setTab(2),
                    )
                  else
                    const _SourceStrip(),
                ],
              ),
            ),
          ),
          if (articles.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: _FeaturedCard(
                  title: articles.first.title,
                  source: articles.first.source.name,
                  imageUrl: articles.first.imageUrl,
                  isRead: ref.watch(isReadProvider(articles.first.id)),
                  onTap: () => context.push('/article/${articles.first.id}'),
                ),
              ),
            )
          else if (!loading && feeds.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyFeedState(
                isDark: isDark,
                onGoSet: () => ref.read(tabIndexProvider.notifier).setTab(2),
              ),
            )
          else if (!loading && feeds.isNotEmpty && articles.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
                child: Column(
                  children: [
                    Text(
                      filter.isDefault ? '还没有文章' : '当前筛选下没有内容',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      filter.isDefault
                          ? '下拉刷新，或检查源是否暂停'
                          : '点右上角改筛选，或下拉刷新所选源',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: onRefresh,
                      child: const Text('立即刷新'),
                    ),
                  ],
                ),
              ),
            )
          else if (loading)
            const _LoadingSliver(),
          if (articles.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return FeedCard(
                    article: article,
                    tintIndex: index,
                    isRead: ref.watch(isReadProvider(article.id)),
                    onTap: () => context.push('/article/${article.id}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (isDark ? AppColors.accentOnDark : AppColors.accent)
        : (isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight);
    return IconButton(
      onPressed: onTap,
      tooltip: '筛选',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.tune_rounded, size: 20, color: color),
          if (active)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.ink : AppColors.canvas,
                    width: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _openFilterSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Consumer(
        builder: (ctx, ref, _) {
          final settings =
              ref.watch(settingsProvider).value ?? const AppSettings();
          final filter = settings.feedFilter;
          final feeds = ref.watch(feedsProvider).value ?? const <FeedSource>[];
          final theme = Theme.of(ctx);
          final isDark = theme.brightness == Brightness.dark;
          final controller = ref.read(settingsControllerProvider);
          final restrictSources = filter.feedIds.isNotEmpty;

          Future<void> save(FeedFilter next) async {
            final current =
                ref.read(settingsProvider).value ?? const AppSettings();
            await controller.updateSettings(
              current.copyWith(feedFilter: next),
            );
          }

          return _FilterSheetScaffold(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.72,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text('筛选', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    '本地保存；选源后下拉与后台只刷这些源',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterTile(
                    title: '全都要看',
                    subtitle: '取消今日 / 未看 / 源限制',
                    selected: filter.isDefault,
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await save(const FeedFilter());
                    },
                  ),
                  _FilterCheckTile(
                    title: '只看今日',
                    value: filter.onlyToday,
                    onChanged: (v) async {
                      HapticFeedback.selectionClick();
                      await save(filter.copyWith(onlyToday: v));
                    },
                  ),
                  _FilterCheckTile(
                    title: '只看未看',
                    value: filter.onlyUnread,
                    onChanged: (v) async {
                      HapticFeedback.selectionClick();
                      await save(filter.copyWith(onlyUnread: v));
                    },
                  ),
                  _FilterCheckTile(
                    title: '只看这些源',
                    value: restrictSources,
                    onChanged: (v) async {
                      HapticFeedback.selectionClick();
                      if (!v) {
                        await save(filter.copyWith(feedIds: const {}));
                        return;
                      }
                      if (feeds.isEmpty) {
                        showAppToast('还没有订阅源', context: ctx);
                        return;
                      }
                      // Enable with all current feeds selected as a starting point.
                      await save(
                        filter.copyWith(
                          feedIds: feeds.map((f) => f.id).toSet(),
                        ),
                      );
                    },
                  ),
                  if (restrictSources) ...[
                    const SizedBox(height: 4),
                    if (feeds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '没有可勾选的源',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...feeds.map((f) {
                        final checked = filter.feedIds.contains(f.id);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: MonogramAvatar(
                            label: f.name,
                            size: 32,
                            seed: f.id,
                          ),
                          title: Text(
                            f.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            f.isPaused ? '${f.domain} · 已暂停' : f.domain,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: checked,
                          onChanged: (v) async {
                            HapticFeedback.selectionClick();
                            final next = Set<String>.from(filter.feedIds);
                            if (v == true) {
                              next.add(f.id);
                            } else {
                              next.remove(f.id);
                            }
                            await save(filter.copyWith(feedIds: next));
                          },
                        );
                      }),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _FilterSheetScaffold extends StatelessWidget {
  const _FilterSheetScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inkElevated : AppColors.canvas,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: selected
          ? const Icon(Icons.check_rounded, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

class _FilterCheckTile extends StatelessWidget {
  const _FilterCheckTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      value: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(
          child: Text(
            '加载中…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySourcesHint extends StatelessWidget {
  const _EmptySourcesHint({required this.isDark, required this.onAdd});

  final bool isDark;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        height: 72,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
          color: isDark ? AppColors.inkCard : AppColors.wash,
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_rounded,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '添加订阅源，开始你的信息流',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState({required this.isDark, required this.onGoSet});

  final bool isDark;
  final VoidCallback onGoSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rss_feed_rounded,
            size: 36,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(height: 14),
          Text(
            '还没有订阅',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去 Set 添加 RSS 地址，或导入 OPML',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onGoSet,
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.white : AppColors.black,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('去添加订阅'),
          ),
        ],
      ),
    );
  }
}

class _SourceStrip extends ConsumerWidget {
  const _SourceStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(feedsProvider).value ?? const [];
    final unreadMap = ref.watch(unreadCountsProvider).value ?? const {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sources.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final s = sources[index];
          final unread = unreadMap[s.id] ?? 0;
          return GestureDetector(
            onTap: () => context.push('/source/${s.id}'),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: unread > 0
                                ? (isDark ? AppColors.white : AppColors.black)
                                : (isDark
                                    ? AppColors.borderDark
                                    : const Color(0xFFDBDBDB)),
                            width: unread > 0 ? 1.6 : 1.2,
                          ),
                        ),
                        child:
                            MonogramAvatar(label: s.name, size: 48, seed: s.id),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -2,
                          right: -4,
                          child: _UnreadBadge(count: unread),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight:
                              unread > 0 ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.28),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.title,
    required this.source,
    required this.onTap,
    this.imageUrl,
    this.isRead = false,
  });

  final String title;
  final String source;
  final String? imageUrl;
  final VoidCallback onTap;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: isRead ? 0.65 : 1,
          child: Ink(
            height: 168,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? AppColors.inkCard : AppColors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    Opacity(
                      opacity: 0.55,
                      child: AppNetworkImage(
                        url: imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              source.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.72),
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                            if (isRead) ...[
                              const Spacer(),
                              Icon(
                                Icons.done_all_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

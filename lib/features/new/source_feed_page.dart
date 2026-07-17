import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../core/utils/monogram.dart';
import '../../providers/article_providers.dart';
import '../../providers/feed_providers.dart';
import '../../widgets/liquid_glass.dart';
import 'feed_card.dart';

class SourceFeedPage extends ConsumerStatefulWidget {
  const SourceFeedPage({super.key, required this.sourceId});

  final String sourceId;

  @override
  ConsumerState<SourceFeedPage> createState() => _SourceFeedPageState();
}

class _SourceFeedPageState extends ConsumerState<SourceFeedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(articleActionsProvider).markSourceSeen(widget.sourceId);
    });
  }

  Future<void> _refresh() async {
    try {
      await ref.read(feedActionsProvider).refreshFeed(widget.sourceId);
    } catch (e) {
      if (!mounted) return;
      showAppToast('$e', context: context);
    }
  }

  Future<void> _showManageSheet() async {
    final source = ref.read(feedByIdProvider(widget.sourceId));
    if (source == null) return;
    final actions = ref.read(feedActionsProvider);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.inkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('刷新此源'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _refresh();
                },
              ),
              ListTile(
                leading: Icon(
                  source.isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
                title: Text(source.isPaused ? '恢复更新' : '暂停更新'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await actions.setPaused(source.id, !source.isPaused);
                },
              ),
              if (source.url != null)
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('复制 feed URL'),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: source.url!));
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) showAppToast('已复制', context: context);
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade400,
                ),
                title: Text(
                  '取消订阅',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('取消订阅？'),
                      content: Text('将删除「${source.name}」及其全部文章。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await actions.removeFeed(source.id);
                    if (mounted) context.pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = ref.watch(feedByIdProvider(widget.sourceId));
    final articles =
        ref.watch(articlesByFeedProvider(widget.sourceId)).value ?? const [];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;

    if (source == null) {
      return Scaffold(
        body: Center(child: Text('源不存在', style: theme.textTheme.titleMedium)),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        edgeOffset: top + 8,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, top + 8, 14, 0),
                child: Row(
                  children: [
                    LiquidGlassIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    const Spacer(),
                    LiquidGlassIconButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: _showManageSheet,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Column(
                  children: [
                    MonogramAvatar(
                      label: source.name,
                      size: 72,
                      seed: source.id,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      source.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      source.domain,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MetaPill(label: '${articles.length} 篇'),
                        const SizedBox(width: 8),
                        _MetaPill(label: source.isPaused ? '已暂停' : '已订阅'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '此源的专属信息流',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (articles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('暂无文章', style: theme.textTheme.bodyMedium),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 40),
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
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inkCard : AppColors.wash,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

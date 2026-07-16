import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/monogram.dart';
import '../../core/utils/open_url.dart';
import '../../core/utils/time_labels.dart';
import '../../data/models/models.dart';
import '../../providers/article_providers.dart';
import '../../providers/comment_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/liquid_glass.dart';
import 'article_body.dart';
import 'article_toc.dart';
import 'comment_sheet.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  const ArticleDetailPage({
    super.key,
    required this.articleId,
    this.openComments = false,
  });

  final String articleId;
  final bool openComments;

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  static const _dwellThreshold = Duration(seconds: 180);

  Timer? _dwellTimer;
  bool _dwellLogged = false;
  bool _commentSheetOpen = false;
  String? _tocArticleId;
  List<ScrubEntry> _tocEntries = const [];

  void _syncToc(Article article) {
    if (_tocArticleId == article.id) return;
    _tocArticleId = article.id;
    _tocEntries = scrubEntriesFromHeadings(
      extractHeadingMeta(article.contentHtml),
    );
  }

  @override
  void initState() {
    super.initState();
    _dwellTimer = Timer(_dwellThreshold, _tryLogDwell);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(articleActionsProvider).markRead(widget.articleId);
      ref
          .read(commentControllerProvider)
          .ensureGenerated(widget.articleId, when: CommentTrigger.onBrowse);
      if (widget.openComments) {
        _openComments(widget.articleId);
      }
    });
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  Future<void> _tryLogDwell() async {
    if (_dwellLogged || !mounted) return;
    _dwellLogged = true;

    final article = await ref
        .read(articleRepositoryProvider)
        .get(widget.articleId);
    if (article == null || !mounted) return;

    final warm = ref.read(warmEventRepositoryProvider);
    final existing = await warm.watch().first;
    if (!mounted) return;
    final today = DateTime.now();
    final already = existing.any(
      (e) =>
          e.type == MeEventType.dwell &&
          e.articleId == article.id &&
          e.createdAt.year == today.year &&
          e.createdAt.month == today.month &&
          e.createdAt.day == today.day,
    );
    if (already) return;

    await warm.add(
      MeEvent(
        id: 'dwell-${article.id}-${today.millisecondsSinceEpoch}',
        type: MeEventType.dwell,
        createdAt: DateTime.now(),
        title: '在 ${article.source.name} 停了一会儿',
        subtitle: article.title,
        articleId: article.id,
      ),
    );
  }

  Future<void> _openOriginal(Article article) async {
    final url = article.link?.trim().isNotEmpty == true
        ? article.link
        : article.source.siteUrl;
    final ok = await openExternalUrl(url);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有可打开的原文链接'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copyLink(Article article) async {
    final url = article.link?.trim();
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('没有可复制的链接'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('链接已复制'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _share(Article article) async {
    final link = article.link?.trim();
    final text = link != null && link.isNotEmpty
        ? '${article.title}\n$link'
        : article.title;
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _exportMarkdown(Article article) async {
    final buf = StringBuffer();
    buf.writeln('# ${article.title}');
    buf.writeln();
    buf.writeln(
      '> ${article.source.name} · ${article.publishedAt.toIso8601String()}',
    );
    if (article.link != null && article.link!.isNotEmpty) {
      buf.writeln();
      buf.writeln('[原文](${article.link})');
    }
    buf.writeln();
    buf.writeln(article.body);
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Markdown 已复制到剪贴板'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openComments(String articleId) async {
    if (_commentSheetOpen) return;
    _commentSheetOpen = true;
    try {
      await showCommentSheet(
        context,
        articleId: articleId,
        activity: ref.read(commentActivityProvider.notifier),
      );
    } finally {
      _commentSheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleByIdProvider(widget.articleId));
    final article = articleAsync.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    if (article == null) {
      return Scaffold(
        body: Center(
          child: Text(
            articleAsync.isLoading ? '加载中…' : '内容不存在',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }

    final bookmarked = ref.watch(isBookmarkedProvider(article.id));
    final commentActivity =
        ref.watch(commentActivityProvider)[article.id] ??
        const CommentActivity();
    _syncToc(article);
    final secondaryText = isDark
        ? const Color(0xFFC4C4C4)
        : AppColors.textSecondaryLight;
    final tertiaryText = isDark
        ? const Color(0xFF9A9A9A)
        : AppColors.textTertiaryLight;
    final hasToc = _tocEntries.length >= 2;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (article.hasImage)
                _CoverSliver(article: article, isDark: isDark)
              else
                SliverToBoxAdapter(child: SizedBox(height: top + 52)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hasToc ? 28 : 22, 8, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MonogramAvatar(
                            label: article.source.name,
                            size: 28,
                            seed: article.source.id,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              article.source.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            relativeTime(article.publishedAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tertiaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        article.title,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 26,
                          height: 1.22,
                          letterSpacing: -0.7,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFF5F5F5)
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      if (article.showSummaryAsLead) ...[
                        const SizedBox(height: 14),
                        Text(
                          article.summary,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: secondaryText,
                            height: 1.55,
                            fontSize: 15.5,
                          ),
                        ),
                      ],
                      if (article.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: article.tags
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.inkCard
                                        : AppColors.wash,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    t,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: secondaryText,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Divider(
                        height: 0.5,
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                      const SizedBox(height: 22),
                      ArticleBody(article: article, tocEntries: _tocEntries),
                      if (article.link != null &&
                          article.link!.trim().isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _OpenOriginalButton(
                          isDark: isDark,
                          onTap: () => _openOriginal(article),
                        ),
                      ],
                      SizedBox(height: 140 + bottom),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (hasToc) EdgeScrubber(entries: _tocEntries),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, top + 6, 12, 0),
              child: Row(
                children: [
                  LiquidGlassIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  LiquidGlassIconButton(
                    icon: Icons.open_in_browser_rounded,
                    onTap: () => _openOriginal(article),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 32 + bottom,
            child: Column(
              children: [
                LiquidGlassCircleAction(
                  icon: bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: bookmarked ? 'Saved' : 'Save',
                  active: bookmarked,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(articleActionsProvider).toggleBookmark(article.id);
                  },
                ),
                const SizedBox(height: 12),
                LiquidGlassCircleAction(
                  icon: Icons.mode_comment_outlined,
                  label: commentActivity.isBusy ? '评论中' : '评论',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _openComments(article.id);
                  },
                ),
                const SizedBox(height: 12),
                LiquidGlassCircleAction(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showMoreSheet(context, article);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMoreSheet(BuildContext context, Article article) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final items = <(IconData, String, VoidCallback)>[
          (
            Icons.open_in_browser_rounded,
            '浏览器打开原文',
            () => _openOriginal(article),
          ),
          (Icons.ios_share_rounded, '分享', () => _share(article)),
          (Icons.copy_rounded, '复制链接', () => _copyLink(article)),
          (
            Icons.download_rounded,
            '导出 Markdown',
            () => _exportMarkdown(article),
          ),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: LiquidGlass(
            borderRadius: 16,
            blur: 22,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 4),
                for (final item in items)
                  ListTile(
                    leading: Icon(
                      item.$1,
                      size: 20,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    title: Text(
                      item.$2,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      item.$3();
                    },
                  ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CoverSliver extends StatelessWidget {
  const _CoverSliver({required this.article, required this.isDark});

  final Article article;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Hero(
            tag: 'cover-${article.id}',
            child: AspectRatio(
              aspectRatio: article.imageAspect.clamp(0.7, 1.6),
              child: AppNetworkImage(
                url: article.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    (isDark ? AppColors.ink : AppColors.canvas).withValues(
                      alpha: 0.98,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenOriginalButton extends StatelessWidget {
  const _OpenOriginalButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
            color: isDark ? AppColors.inkCard : AppColors.wash,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                '在浏览器打开原文',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

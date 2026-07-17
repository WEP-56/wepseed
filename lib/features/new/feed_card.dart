import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/time_labels.dart';
import '../../data/models/models.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/pressable.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.article,
    required this.tintIndex,
    required this.onTap,
    this.isRead = false,
  });

  final Article article;
  final int tintIndex;
  final VoidCallback onTap;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final child = article.hasImage
        ? _ImageCard(article: article, isRead: isRead)
        : _TextCard(article: article, tintIndex: tintIndex, isRead: isRead);

    return Pressable(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: isRead ? 0.55 : 1,
        child: child,
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.article, required this.isRead});

  final Article article;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? AppColors.inkCard : AppColors.paper,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: article.imageAspect,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'cover-${article.id}',
                  child: AppNetworkImage(
                    url: article.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isRead)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _ReadBadge(isDark: isDark),
                  ),
                if (article.mediaType == ArticleMediaType.video)
                  const Center(child: _VideoPlayBadge()),
                if (article.isMedia)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: _MediaBadge(type: article.mediaType, dark: true),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 11, 11, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${article.source.name} · ${relativeTime(article.publishedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({
    required this.article,
    required this.tintIndex,
    required this.isRead,
  });

  final Article article;
  final int tintIndex;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tints = isDark ? AppColors.cardTintsDark : AppColors.cardTints;
    final bg = tints[tintIndex % tints.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: bg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (article.isMedia) ...[
                _MediaBadge(type: article.mediaType),
                const SizedBox(width: 7),
              ],
              Expanded(
                child: Text(
                  article.source.name.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    fontSize: 10,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ),
              if (isRead)
                Icon(
                  Icons.done_all_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            article.title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.32,
              letterSpacing: -0.25,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            article.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.45,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            relativeTime(article.publishedAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaBadge extends StatelessWidget {
  const _MediaBadge({required this.type, this.dark = false});

  final ArticleMediaType type;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark
        ? Colors.white
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.58)
            : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == ArticleMediaType.audio
                ? Icons.graphic_eq_rounded
                : Icons.play_arrow_rounded,
            size: 11,
            color: foreground,
          ),
          const SizedBox(width: 3),
          Text(
            type == ArticleMediaType.audio ? '音频' : '视频',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayBadge extends StatelessWidget {
  const _VideoPlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.48),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _ReadBadge extends StatelessWidget {
  const _ReadBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.done_all_rounded,
            size: 11,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 3),
          Text(
            '已读',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

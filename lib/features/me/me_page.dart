import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/monogram.dart';
import '../../core/utils/time_labels.dart';
import '../../data/models/models.dart';
import '../../providers/article_providers.dart';
import '../../providers/me_providers.dart';
import '../../providers/netizen_providers.dart';
import '../../providers/settings_provider.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final events = ref.watch(meTimelineProvider).value ?? const [];
    final user = ref.watch(userProfileProvider).value ??
        const UserProfile(displayName: '旅人');
    final netizenCount =
        (ref.watch(netizensProvider).value ?? const []).where((n) => n.isEnabled).length;
    final bookmarks =
        ref.watch(bookmarkedIdsProvider).value?.length ?? 0;
    final grouped = _groupByDay(events);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, top + 10, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ME',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reading trail',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileHeader(user: user, netizenCount: netizenCount),
                const SizedBox(height: 14),
                _StatsRow(
                  bookmarks: bookmarks,
                  chats: events.where((e) => e.type == MeEventType.chat).length,
                  moments: events
                      .where(
                        (e) =>
                            e.type == MeEventType.dwell ||
                            e.type == MeEventType.binge ||
                            e.type == MeEventType.streak ||
                            e.type == MeEventType.nightOwl,
                      )
                      .length,
                  onBookmarks: () => context.push('/me/bookmarks'),
                  onChats: () => context.push('/me/chats'),
                  onTraces: () => context.push('/me/traces'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList.builder(
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final group = grouped[index];
              return _DaySection(
                label: group.$1,
                events: group.$2,
                isDark: isDark,
                onOpenArticle: (id) => context.push('/article/$id'),
              );
            },
          ),
        ),
      ],
    );
  }

  List<(String, List<MeEvent>)> _groupByDay(List<MeEvent> events) {
    final map = <String, List<MeEvent>>{};
    final order = <String>[];
    for (final e in events) {
      final key = timelineDayLabel(e.createdAt);
      map.putIfAbsent(key, () {
        order.add(key);
        return [];
      });
      map[key]!.add(e);
    }
    return [for (final k in order) (k, map[k]!)];
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.netizenCount});

  final UserProfile user;
  final int netizenCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.inkCard : AppColors.paper,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          MonogramAvatar(label: user.displayName, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Local · 网友 $netizenCount 位',
                  style: theme.textTheme.bodySmall?.copyWith(
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.bookmarks,
    required this.chats,
    required this.moments,
    required this.onBookmarks,
    required this.onChats,
    required this.onTraces,
  });

  final int bookmarks;
  final int chats;
  final int moments;
  final VoidCallback onBookmarks;
  final VoidCallback onChats;
  final VoidCallback onTraces;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: '收藏',
            value: '$bookmarks',
            onTap: onBookmarks,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: '对话',
            value: '$chats',
            onTap: onChats,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            label: '痕迹',
            value: '$moments',
            onTap: onTraces,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.inkCard : AppColors.paper,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
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
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.label,
    required this.events,
    required this.isDark,
    required this.onOpenArticle,
  });

  final String label;
  final List<MeEvent> events;
  final bool isDark;
  final ValueChanged<String> onOpenArticle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ...List.generate(events.length, (i) {
            final e = events[i];
            final isLast = i == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 22,
                    child: Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.white : AppColors.black,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                      child: _EventCard(
                        event: e,
                        onTap: e.articleId == null
                            ? null
                            : () => onOpenArticle(e.articleId!),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.onTap});

  final MeEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final warm =
        event.type != MeEventType.bookmark && event.type != MeEventType.chat;

    return Material(
      color: isDark ? AppColors.inkCard : AppColors.paper,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
          decoration: BoxDecoration(
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
              const SizedBox(height: 5),
              Text(
                event.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              if (warm) ...[
                const SizedBox(height: 8),
                Text(
                  _typeLabel(event.type),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(MeEventType type) => switch (type) {
        MeEventType.dwell => '驻留',
        MeEventType.binge => '连读',
        MeEventType.streak => '连续',
        MeEventType.nightOwl => '夜读',
        _ => '',
      };
}

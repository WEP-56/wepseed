import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/monogram.dart';
import '../data/models/models.dart';
import '../providers/settings_provider.dart';
import '../providers/shell_providers.dart';
import 'liquid_glass.dart';

class GlassBottomNav extends ConsumerWidget {
  const GlassBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    this.showExplore = true,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final bool showExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(userProfileProvider).value ??
        const UserProfile(displayName: '旅人');
    final bottom = MediaQuery.paddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = visibleAppTabs(showExplore);

    // Horizontal inset shrinks slightly when 4 tabs are visible.
    final hInset = tabs.length >= 4 ? 48.0 : 72.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hInset, 0, hInset, bottom > 0 ? bottom + 4 : 10),
      child: LiquidGlass(
        borderRadius: 28,
        blur: 30,
        opacity: isDark ? 0.1 : 0.58,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < tabs.length; i++)
                _itemForTab(
                  tab: tabs[i],
                  selected: index == i,
                  user: user,
                  onTap: () => _tap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemForTab({
    required AppTab tab,
    required bool selected,
    required UserProfile user,
    required VoidCallback onTap,
  }) {
    return switch (tab) {
      AppTab.news => _NavIcon(
        selected: selected,
        icon: Icons.search_rounded,
        onTap: onTap,
      ),
      AppTab.explore => _NavIcon(
        selected: selected,
        icon: Icons.public_outlined,
        activeIcon: Icons.public_rounded,
        onTap: onTap,
      ),
      AppTab.me => _NavIcon(
        selected: selected,
        child: MonogramAvatar(
          label: user.displayName,
          size: 22,
          filled: selected,
        ),
        onTap: onTap,
      ),
      AppTab.set => _NavIcon(
        selected: selected,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        onTap: onTap,
      ),
    };
  }

  void _tap(int i) {
    HapticFeedback.selectionClick();
    onChanged(i);
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.selected,
    required this.onTap,
    this.icon,
    this.activeIcon,
    this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? activeIcon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 46,
        child: Center(
          child:
              child ??
              Icon(
                selected ? (activeIcon ?? icon) : icon,
                size: 22,
                color: color,
              ),
        ),
      ),
    );
  }
}

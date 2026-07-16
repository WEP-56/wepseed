import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/monogram.dart';
import '../data/models/models.dart';
import '../providers/settings_provider.dart';
import 'liquid_glass.dart';

class GlassBottomNav extends ConsumerWidget {
  const GlassBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(userProfileProvider).value ??
        const UserProfile(displayName: '旅人');
    final bottom = MediaQuery.paddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(72, 0, 72, bottom > 0 ? bottom + 4 : 10),
      child: LiquidGlass(
        borderRadius: 28,
        blur: 30,
        opacity: isDark ? 0.1 : 0.58,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                selected: index == 0,
                icon: Icons.search_rounded,
                onTap: () => _tap(0),
              ),
              _NavIcon(
                selected: index == 1,
                child: MonogramAvatar(
                  label: user.displayName,
                  size: 22,
                  filled: index == 1,
                ),
                onTap: () => _tap(1),
              ),
              _NavIcon(
                selected: index == 2,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                onTap: () => _tap(2),
              ),
            ],
          ),
        ),
      ),
    );
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
    final active =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final idle =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05))
                  : Colors.transparent,
            ),
            child: child ??
                Icon(
                  selected ? (activeIcon ?? icon) : icon,
                  size: 20,
                  color: selected ? active : idle,
                ),
          ),
        ),
      ),
    );
  }
}

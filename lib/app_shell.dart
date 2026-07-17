import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/ui/app_toast.dart';
import 'features/me/me_page.dart';
import 'features/media/media_player_widgets.dart';
import 'features/new/new_page.dart';
import 'features/set/set_page.dart';
import 'providers/shell_providers.dart';
import 'widgets/glass_bottom_nav.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  static const _pages = <Widget>[NewPage(), MePage(), SetPage()];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  DateTime? _lastBackAt;

  void _onPopInvoked(bool didPop, dynamic result) {
    if (didPop) return;
    final tab = ref.read(tabIndexProvider);
    if (tab != 0) {
      ref.read(tabIndexProvider.notifier).setTab(0);
      return;
    }
    final now = DateTime.now();
    final last = _lastBackAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackAt = now;
    showAppToast('再按一次退出', context: context);
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(tabIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final fade = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    );
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.018),
                      end: Offset.zero,
                    ).animate(fade);
                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(tabIndex),
                    child: AppShell._pages[tabIndex],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassBottomNav(
                  index: tabIndex,
                  onChanged: (i) =>
                      ref.read(tabIndexProvider.notifier).setTab(i),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 66 + bottom,
                child: const MiniMediaPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

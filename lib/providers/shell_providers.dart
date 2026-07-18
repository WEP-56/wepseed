import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'radar_providers.dart';

/// Root shell tabs. Explore can be hidden via settings.
enum AppTab { news, explore, me, set }

List<AppTab> visibleAppTabs(bool showExplore) => showExplore
    ? const [AppTab.news, AppTab.explore, AppTab.me, AppTab.set]
    : const [AppTab.news, AppTab.me, AppTab.set];

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(
  TabIndexNotifier.new,
);

class TabIndexNotifier extends Notifier<int> {
  @override
  int build() {
    ref.listen<bool>(showExploreTabProvider, (prev, next) {
      final tabs = visibleAppTabs(next);
      if (state >= tabs.length) {
        state = 0;
      }
    });
    return 0;
  }

  void setTab(int index) {
    final showExplore = ref.read(showExploreTabProvider);
    final tabs = visibleAppTabs(showExplore);
    if (index < 0 || index >= tabs.length) return;
    if (state == index) return;
    state = index;
  }

  void setTabById(AppTab tab) {
    final showExplore = ref.read(showExploreTabProvider);
    final tabs = visibleAppTabs(showExplore);
    final i = tabs.indexOf(tab);
    if (i < 0) {
      state = 0;
      return;
    }
    state = i;
  }

  AppTab currentTab() {
    final showExplore = ref.read(showExploreTabProvider);
    final tabs = visibleAppTabs(showExplore);
    if (state < 0 || state >= tabs.length) return AppTab.news;
    return tabs[state];
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(
  TabIndexNotifier.new,
);

class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    if (state == index) return;
    state = index;
  }
}

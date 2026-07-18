import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rsshub/radar_catalog_loader.dart';
import '../data/rsshub/radar_models.dart';
import '../data/rsshub/radar_prefs.dart';

final radarPrefsProvider = Provider<RadarPrefs>((ref) => RadarPrefs());

final showExploreTabProvider =
    NotifierProvider<ShowExploreTabNotifier, bool>(ShowExploreTabNotifier.new);

class ShowExploreTabNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future.microtask(_load);
    return true;
  }

  Future<void> _load() async {
    final v = await ref.read(radarPrefsProvider).loadShowExploreTab();
    state = v;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    await ref.read(radarPrefsProvider).saveShowExploreTab(value);
  }
}

final radarCatalogProvider = FutureProvider<RadarCatalog>((ref) {
  return loadRadarCatalog();
});

final radarDraftProvider =
    NotifierProvider<RadarDraftNotifier, RadarDraft>(RadarDraftNotifier.new);

class RadarDraftNotifier extends Notifier<RadarDraft> {
  Timer? _debounce;

  @override
  RadarDraft build() {
    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(_load);
    return RadarDraft.empty;
  }

  Future<void> _load() async {
    final draft = await ref.read(radarPrefsProvider).loadDraft();
    state = draft;
  }

  void update(RadarDraft Function(RadarDraft current) fn) {
    state = fn(state);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await ref.read(radarPrefsProvider).saveDraft(state);
    });
  }

  Future<void> persistNow() async {
    _debounce?.cancel();
    await ref.read(radarPrefsProvider).saveDraft(state);
  }

  Future<void> clear() async {
    _debounce?.cancel();
    state = RadarDraft.empty;
    await ref.read(radarPrefsProvider).clearDraft();
  }
}

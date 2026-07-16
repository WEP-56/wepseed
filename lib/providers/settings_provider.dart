import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../data/repositories/settings_repository.dart';
import 'core_providers.dart';

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final userProfileProvider = StreamProvider<UserProfile>((ref) {
  return ref.watch(settingsRepositoryProvider).watchUser();
});

final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(ref);
});

class SettingsController {
  SettingsController(this._ref);

  final Ref _ref;

  SettingsRepository get _repo => _ref.read(settingsRepositoryProvider);

  Future<void> updateSettings(AppSettings settings) => _repo.save(settings);

  Future<void> updateUser(UserProfile user) => _repo.saveUser(user);
}

import '../models/models.dart';

abstract class SettingsRepository {
  Stream<AppSettings> watch();
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);

  Stream<UserProfile> watchUser();
  Future<UserProfile> getUser();
  Future<void> saveUser(UserProfile user);
}

/// Per-provider API keys: `llm.provider.{id}.apiKey`
abstract class SecureSettings {
  Future<String?> getProviderApiKey(String providerId);
  Future<void> setProviderApiKey(String providerId, String? key);
  Future<bool> hasProviderApiKey(String providerId);

  /// Legacy global key migration helper.
  Future<String?> getLegacyApiKey();
  Future<void> clearLegacyApiKey();
}

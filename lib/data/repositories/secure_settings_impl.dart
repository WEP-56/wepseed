import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'settings_repository.dart';

class SecureSettingsImpl implements SecureSettings {
  SecureSettingsImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _legacyKey = 'wepseed.llm.api_key';

  final FlutterSecureStorage _storage;

  String _providerKey(String providerId) => 'llm.provider.$providerId.apiKey';

  @override
  Future<String?> getProviderApiKey(String providerId) =>
      _storage.read(key: _providerKey(providerId));

  @override
  Future<void> setProviderApiKey(String providerId, String? key) async {
    final storageKey = _providerKey(providerId);
    final trimmed = key?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _storage.delete(key: storageKey);
      return;
    }
    await _storage.write(key: storageKey, value: trimmed);
  }

  @override
  Future<bool> hasProviderApiKey(String providerId) async {
    final value = await getProviderApiKey(providerId);
    return value != null && value.isNotEmpty;
  }

  @override
  Future<String?> getLegacyApiKey() => _storage.read(key: _legacyKey);

  @override
  Future<void> clearLegacyApiKey() => _storage.delete(key: _legacyKey);
}

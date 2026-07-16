import '../models/models.dart';

abstract class LlmProviderRepository {
  Stream<List<LlmProvider>> watchProviders();
  Future<List<LlmProvider>> getProviders();
  Future<void> upsertProvider(LlmProvider provider, {String? apiKey});
  Future<void> deleteProvider(String id);

  Stream<List<LlmModel>> watchModels(String providerId);
  Future<List<LlmModel>> getModels(String providerId);
  Future<List<LlmModel>> getAllModels();
  Future<void> upsertModel(LlmModel model);
  Future<void> deleteModel(String id);

  Future<String?> getApiKey(String providerId);
  Future<void> setApiKey(String providerId, String? key);
  Future<bool> hasApiKey(String providerId);
}

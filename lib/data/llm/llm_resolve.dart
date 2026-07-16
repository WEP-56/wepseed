import '../models/models.dart';
import '../repositories/llm_provider_repository.dart';
import 'llm_client.dart';

/// Resolve provider + model + apiKey for a netizen (or first default).
Future<LlmRequestConfig?> resolveLlmConfigForNetizen({
  required Netizen netizen,
  required LlmProviderRepository llmRepo,
  required List<LlmProvider> providers,
  required List<LlmModel> allModels,
}) async {
  LlmProvider? provider;
  LlmModel? model;

  if (netizen.providerId != null) {
    for (final p in providers) {
      if (p.id == netizen.providerId && p.isEnabled) {
        provider = p;
        break;
      }
    }
    // An explicit binding must never silently spend another provider's quota.
    if (provider == null) return null;
  } else {
    for (final p in providers) {
      if (p.isEnabled) {
        provider = p;
        break;
      }
    }
  }
  if (provider == null) return null;

  final providerModels = allModels
      .where((m) => m.providerId == provider!.id)
      .toList();
  if (netizen.modelId != null) {
    for (final m in providerModels) {
      if (m.id == netizen.modelId || m.modelId == netizen.modelId) {
        model = m;
        break;
      }
    }
    if (model == null) return null;
  } else {
    for (final m in providerModels) {
      if (m.isDefault) {
        model = m;
        break;
      }
    }
  }
  model ??= providerModels.isEmpty ? null : providerModels.first;
  if (model == null) return null;

  final key = await llmRepo.getApiKey(provider.id);
  if (key == null || key.trim().isEmpty) return null;

  return LlmRequestConfig(
    providerId: provider.id,
    protocol: provider.protocol,
    baseUrl: provider.baseUrl,
    modelId: model.modelId,
    apiKey: key.trim(),
    maxConcurrent: provider.maxConcurrent,
    requestsPerMinute: provider.requestsPerMinute,
  );
}

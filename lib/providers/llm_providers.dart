import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

final llmProvidersListProvider = StreamProvider<List<LlmProvider>>((ref) {
  return ref.watch(llmProviderRepositoryProvider).watchProviders();
});

final llmModelsForProviderProvider =
    StreamProvider.family<List<LlmModel>, String>((ref, providerId) {
      return ref.watch(llmProviderRepositoryProvider).watchModels(providerId);
    });

final allLlmModelsProvider = FutureProvider<List<LlmModel>>((ref) {
  return ref.watch(llmProviderRepositoryProvider).getAllModels();
});

final providerHasKeyProvider = FutureProvider.family<bool, String>((
  ref,
  providerId,
) {
  return ref.watch(llmProviderRepositoryProvider).hasApiKey(providerId);
});

final llmConfigControllerProvider = Provider<LlmConfigController>((ref) {
  return LlmConfigController(ref);
});

class LlmConfigController {
  LlmConfigController(this._ref);

  final Ref _ref;

  Future<void> upsertProvider(LlmProvider p, {String? apiKey}) async {
    await _ref
        .read(llmProviderRepositoryProvider)
        .upsertProvider(p, apiKey: apiKey);
    _ref.invalidate(providerHasKeyProvider(p.id));
  }

  Future<void> deleteProvider(String id) async {
    await _ref.read(llmProviderRepositoryProvider).deleteProvider(id);
  }

  Future<void> upsertModel(LlmModel m) async {
    await _ref.read(llmProviderRepositoryProvider).upsertModel(m);
    // Refresh family stream for this provider's model list.
    _ref.invalidate(llmModelsForProviderProvider(m.providerId));
    _ref.invalidate(allLlmModelsProvider);
  }

  Future<void> deleteModel(String id) async {
    // Look up providerId before delete so we can invalidate the right family.
    final all = await _ref.read(llmProviderRepositoryProvider).getAllModels();
    String? providerId;
    for (final m in all) {
      if (m.id == id) {
        providerId = m.providerId;
        break;
      }
    }
    await _ref.read(llmProviderRepositoryProvider).deleteModel(id);
    if (providerId != null) {
      _ref.invalidate(llmModelsForProviderProvider(providerId));
    }
    _ref.invalidate(allLlmModelsProvider);
  }

  Future<void> setApiKey(String providerId, String? key) async {
    await _ref.read(llmProviderRepositoryProvider).setApiKey(providerId, key);
    _ref.invalidate(providerHasKeyProvider(providerId));
  }
}

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'llm_provider_repository.dart';
import 'settings_repository.dart';

class LlmProviderRepositoryImpl implements LlmProviderRepository {
  LlmProviderRepositoryImpl(this._db, this._secure);

  final AppDatabase _db;
  final SecureSettings _secure;

  @override
  Stream<List<LlmProvider>> watchProviders() {
    return (_db.select(_db.llmProviders)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapProvider).toList());
  }

  @override
  Future<List<LlmProvider>> getProviders() async {
    final rows = await (_db.select(
      _db.llmProviders,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    return rows.map(_mapProvider).toList();
  }

  @override
  Future<void> upsertProvider(LlmProvider provider, {String? apiKey}) async {
    final now = DateTime.now();
    await _db
        .into(_db.llmProviders)
        .insertOnConflictUpdate(
          LlmProvidersCompanion(
            id: Value(provider.id),
            name: Value(provider.name),
            protocol: Value(llmProtocolToDb(provider.protocol)),
            baseUrl: Value(provider.baseUrl),
            isEnabled: Value(provider.isEnabled),
            maxConcurrent: Value(provider.maxConcurrent.clamp(1, 8)),
            requestsPerMinute: Value(provider.requestsPerMinute.clamp(1, 1000)),
            sortOrder: Value(provider.sortOrder),
            createdAt: Value(provider.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    if (apiKey != null) {
      await _secure.setProviderApiKey(provider.id, apiKey);
    }
  }

  @override
  Future<void> deleteProvider(String id) async {
    await (_db.delete(
      _db.llmModels,
    )..where((t) => t.providerId.equals(id))).go();
    await (_db.delete(_db.llmProviders)..where((t) => t.id.equals(id))).go();
    await _secure.setProviderApiKey(id, null);
  }

  @override
  Stream<List<LlmModel>> watchModels(String providerId) {
    return (_db.select(_db.llmModels)
          ..where((t) => t.providerId.equals(providerId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapModel).toList());
  }

  @override
  Future<List<LlmModel>> getModels(String providerId) async {
    final rows =
        await (_db.select(_db.llmModels)
              ..where((t) => t.providerId.equals(providerId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_mapModel).toList();
  }

  @override
  Future<List<LlmModel>> getAllModels() async {
    final rows = await (_db.select(
      _db.llmModels,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    return rows.map(_mapModel).toList();
  }

  @override
  Future<void> upsertModel(LlmModel model) async {
    await _db.transaction(() async {
      if (model.isDefault) {
        await (_db.update(_db.llmModels)
              ..where((t) => t.providerId.equals(model.providerId)))
            .write(const LlmModelsCompanion(isDefault: Value(false)));
      }
      // insertOrReplace avoids silent no-op on partial companions.
      await _db
          .into(_db.llmModels)
          .insert(
            LlmModelsCompanion.insert(
              id: model.id,
              providerId: model.providerId,
              modelId: model.modelId,
              displayName: model.displayName,
              isDefault: Value(model.isDefault),
              sortOrder: Value(model.sortOrder),
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  @override
  Future<void> deleteModel(String id) async {
    await (_db.delete(_db.llmModels)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<String?> getApiKey(String providerId) =>
      _secure.getProviderApiKey(providerId);

  @override
  Future<void> setApiKey(String providerId, String? key) =>
      _secure.setProviderApiKey(providerId, key);

  @override
  Future<bool> hasApiKey(String providerId) =>
      _secure.hasProviderApiKey(providerId);

  LlmProvider _mapProvider(LlmProviderRow row) {
    return LlmProvider(
      id: row.id,
      name: row.name,
      protocol: llmProtocolFromDb(row.protocol),
      baseUrl: row.baseUrl,
      isEnabled: row.isEnabled,
      maxConcurrent: row.maxConcurrent,
      requestsPerMinute: row.requestsPerMinute,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  LlmModel _mapModel(LlmModelRow row) {
    return LlmModel(
      id: row.id,
      providerId: row.providerId,
      modelId: row.modelId,
      displayName: row.displayName,
      isDefault: row.isDefault,
      sortOrder: row.sortOrder,
    );
  }
}

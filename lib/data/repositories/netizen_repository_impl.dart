import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'netizen_repository.dart';

class NetizenRepositoryImpl implements NetizenRepository {
  NetizenRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Netizen>> watchAll() {
    return (_db.select(_db.netizens)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  @override
  Future<List<Netizen>> getAll() async {
    final rows = await (_db.select(
      _db.netizens,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    return rows.map(_map).toList();
  }

  @override
  Future<Netizen?> getById(String id) async {
    final row = await (_db.select(
      _db.netizens,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Future<void> upsert(Netizen netizen) async {
    final now = DateTime.now();
    await _db
        .into(_db.netizens)
        .insertOnConflictUpdate(
          NetizensCompanion(
            id: Value(netizen.id),
            name: Value(netizen.name),
            styleLabel: Value(netizen.styleLabel),
            systemHint: Value(netizen.systemHint),
            avatarPath: Value(netizen.avatarPath),
            weight: Value(netizen.weight.clamp(0.0, 1.0)),
            providerId: Value(netizen.providerId),
            modelId: Value(netizen.modelId),
            isEnabled: Value(netizen.isEnabled),
            sortOrder: Value(netizen.sortOrder),
            createdAt: Value(netizen.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.netizens)..where((t) => t.id.equals(id))).go();
  }

  Netizen _map(NetizenRow row) {
    return Netizen(
      id: row.id,
      name: row.name,
      styleLabel: row.styleLabel,
      systemHint: row.systemHint,
      avatarPath: row.avatarPath,
      weight: row.weight,
      providerId: row.providerId,
      modelId: row.modelId,
      isEnabled: row.isEnabled,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

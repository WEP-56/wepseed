import '../models/models.dart';

abstract class NetizenRepository {
  Stream<List<Netizen>> watchAll();
  Future<List<Netizen>> getAll();
  Future<Netizen?> getById(String id);
  Future<void> upsert(Netizen netizen);
  Future<void> delete(String id);
}

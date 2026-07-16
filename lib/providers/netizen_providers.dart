import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

final netizensProvider = StreamProvider<List<Netizen>>((ref) {
  return ref.watch(netizenRepositoryProvider).watchAll();
});

final netizenControllerProvider = Provider<NetizenController>((ref) {
  return NetizenController(ref);
});

class NetizenController {
  NetizenController(this._ref);

  final Ref _ref;

  Future<void> upsert(Netizen n) =>
      _ref.read(netizenRepositoryProvider).upsert(n);

  Future<void> delete(String id) =>
      _ref.read(netizenRepositoryProvider).delete(id);
}

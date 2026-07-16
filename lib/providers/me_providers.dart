import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

final meTimelineProvider = StreamProvider<List<MeEvent>>((ref) {
  return ref.watch(warmEventRepositoryProvider).watch();
});

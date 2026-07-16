import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

final meTimelineProvider = StreamProvider<List<MeEvent>>((ref) {
  return ref.watch(warmEventRepositoryProvider).watch();
});

/// ME list pages: filter warm/chat events by type set.
final meEventsByTypesProvider =
    Provider.family<AsyncValue<List<MeEvent>>, Set<MeEventType>>((ref, types) {
      final all = ref.watch(meTimelineProvider);
      return all.whenData(
        (list) => list.where((e) => types.contains(e.type)).toList(),
      );
    });

import 'dart:async';

import '../mock/mock_data.dart';
import '../models/models.dart';
import 'warm_event_repository.dart';

class MockWarmEventRepository implements WarmEventRepository {
  MockWarmEventRepository() {
    _events = MockData.meEvents(MockData.articles());
  }

  late List<MeEvent> _events;
  final _controller = StreamController<List<MeEvent>>.broadcast();

  @override
  Stream<List<MeEvent>> watch() async* {
    yield List.unmodifiable(_events);
    yield* _controller.stream;
  }

  @override
  Future<void> add(MeEvent event) async {
    _events = [event, ..._events];
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_events));
    }
  }

  @override
  Future<void> recordRead(Article article, DateTime at) async {}

  void dispose() {
    _controller.close();
  }
}

import 'dart:async';

import '../mock/mock_data.dart';
import '../models/models.dart';
import 'feed_repository.dart';

class MockFeedRepository implements FeedRepository {
  MockFeedRepository() {
    _controller.add(List.unmodifiable(MockData.sources));
  }

  final _controller = StreamController<List<FeedSource>>.broadcast();

  @override
  Stream<List<FeedSource>> watchFeeds() async* {
    yield List.unmodifiable(MockData.sources);
    yield* _controller.stream;
  }

  @override
  Future<FeedSource?> getFeed(String id) async {
    for (final s in MockData.sources) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<void> addFeed(String url) {
    throw UnimplementedError('真实添加源将在 Phase B 接入');
  }

  @override
  Future<void> removeFeed(String id) {
    throw UnimplementedError('真实删除源将在 Phase B 接入');
  }

  @override
  Future<void> setPaused(String id, bool paused) {
    throw UnimplementedError('暂停源将在 Phase B 接入');
  }

  @override
  Future<void> refreshFeed(String id) async {
    // no-op in mock
  }

  @override
  Future<void> refreshAll({bool wifiOnly = false}) async {
    // no-op in mock
  }

  @override
  Future<void> importOpml(String xml) {
    throw UnimplementedError('OPML 导入将在 Phase B 接入');
  }

  @override
  Future<String> exportOpml() {
    throw UnimplementedError('OPML 导出将在 Phase B 接入');
  }

  void dispose() {
    _controller.close();
  }
}

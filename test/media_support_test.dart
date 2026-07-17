import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/models/models.dart';
import 'package:wepseed/data/repositories/article_repository.dart';
import 'package:wepseed/providers/comment_providers.dart';
import 'package:wepseed/providers/core_providers.dart';

void main() {
  test('media type database values roundtrip', () {
    for (final type in ArticleMediaType.values) {
      expect(articleMediaTypeFromDb(articleMediaTypeToDb(type)), type);
    }
    expect(articleMediaTypeFromDb('unknown'), ArticleMediaType.blog);
  });

  test('media articles never create netizen comment jobs', () async {
    final article = Article(
      id: 'audio-1',
      source: const FeedSource(id: 'f', name: 'Podcast', domain: 'pod.test'),
      title: 'Episode',
      summary: 'notes',
      body: 'notes',
      publishedAt: DateTime(2026, 7, 17),
      mediaType: ArticleMediaType.audio,
      enclosureUrl: 'https://cdn.test/e.mp3',
    );
    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(_OneArticleRepo(article)),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(commentControllerProvider)
        .ensureGenerated(article.id, when: CommentTrigger.onBrowse);

    expect(container.read(commentActivityProvider), isEmpty);
  });
}

class _OneArticleRepo implements ArticleRepository {
  _OneArticleRepo(this.article);

  final Article article;

  @override
  Future<Article?> get(String id) async => id == article.id ? article : null;

  @override
  bool isBookmarked(String id) => false;

  @override
  bool isRead(String id) => false;

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> markSourceSeen(String feedId) async {}

  @override
  Future<void> setBookmarked(String id, bool value) async {}

  @override
  Stream<List<Article>> watchBookmarkedArticles() => Stream.value(const []);

  @override
  Stream<Set<String>> watchBookmarkedIds() => Stream.value(const {});

  @override
  Stream<Set<String>> watchReadIds() => Stream.value(const {});

  @override
  Stream<List<Article>> watchTimeline({String? feedId}) =>
      Stream.value([article]);

  @override
  Stream<Map<String, int>> watchUnreadCounts() => Stream.value(const {});
}

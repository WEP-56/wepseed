import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/app.dart';
import 'package:wepseed/data/models/models.dart';
import 'package:wepseed/features/new/comment_sheet.dart';
import 'package:wepseed/providers/comment_providers.dart';
import 'package:wepseed/providers/netizen_providers.dart';
import 'package:wepseed/providers/settings_provider.dart';

void main() {
  testWidgets('App boots into New tab', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WepseedApp()));
    // Allow first async settings/articles frames.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('New'), findsWidgets);
  });

  testWidgets(
    'CommentSheet opens and disposes without provider lifecycle writes',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commentsForArticleProvider.overrideWith(
              (ref, articleId) => Stream.value(const <Comment>[]),
            ),
            netizensProvider.overrideWith(
              (ref) => Stream.value(const <Netizen>[]),
            ),
            settingsProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            userProfileProvider.overrideWith(
              (ref) => Stream.value(const UserProfile(displayName: '旅人')),
            ),
            commentControllerProvider.overrideWithValue(
              _FakeCommentController(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CommentSheet(articleId: 'missing')),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}

class _FakeCommentController implements CommentController {
  @override
  Future<void> ensureGenerated(
    String articleId, {
    required CommentTrigger when,
  }) async {}

  @override
  Future<void> reply({
    required String articleId,
    required String parentId,
    required String text,
  }) async {}

  @override
  Future<void> retryGeneration(String articleId) async {}

  @override
  Future<void> clearAllComments() async {}

  @override
  Future<void> clearCommentsForArticle(String articleId) async {}
}

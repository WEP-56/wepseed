import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_shell.dart';
import '../features/new/article_detail_page.dart';
import '../features/new/source_feed_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AppShell()),
      ),
      GoRoute(
        path: '/article/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _fadePage(
            state: state,
            child: ArticleDetailPage(
              articleId: id,
              openComments: state.uri.queryParameters['comments'] == '1',
            ),
          );
        },
      ),
      GoRoute(
        path: '/source/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _fadePage(
            state: state,
            child: SourceFeedPage(sourceId: id),
          );
        },
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(opacity: fade, child: child);
    },
  );
}

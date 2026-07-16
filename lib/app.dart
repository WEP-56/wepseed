import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/background/background_refresh_service.dart';
import 'core/background/notification_service.dart';
import 'core/ui/app_toast.dart';
import 'data/models/models.dart';
import 'providers/comment_providers.dart';
import 'providers/settings_provider.dart';
import 'router/app_router.dart';

class WepseedApp extends ConsumerWidget {
  const WepseedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.value ?? const AppSettings();
    final router = ref.watch(goRouterProvider);

    ref.listen(settingsProvider, (previous, next) {
      final settings = next.value;
      if (settings != null && settings != previous?.value) {
        unawaited(BackgroundRefreshService.configure(settings));
      }
    });
    ref.listen(notificationRouteProvider, (previous, next) {
      final route = next.value;
      if (route != null && route != previous?.value) router.go(route);
    });

    ref.listen(commentActivityProvider, (previous, next) {
      for (final entry in next.entries) {
        final activity = entry.value;
        final event = activity.lastEvent;
        final previousEvent = previous?[entry.key]?.lastEvent;
        if (event == null ||
            event.id == previousEvent?.id ||
            activity.isViewing) {
          continue;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAppToast(
            event.message,
            messenger: appMessengerKey.currentState,
            action: event.type == CommentActivityEventType.failed
                ? null
                : SnackBarAction(
                    label: '查看',
                    onPressed: () => router.go(
                      '/article/${Uri.encodeComponent(entry.key)}?comments=1',
                    ),
                  ),
          );
        });
      }
    });

    return MaterialApp.router(
      title: 'wepseed',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appMessengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

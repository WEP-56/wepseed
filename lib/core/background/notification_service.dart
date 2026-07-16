import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRouteProvider = StreamProvider<String>((ref) {
  return NotificationService.instance.routes;
});

/// Shared channel id — must match [AndroidNotificationDetails.channelId].
const kRssNotificationChannelId = 'rss_updates';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _routes = StreamController<String>.broadcast();
  String? _pendingRoute;
  bool _initialized = false;
  bool _permissionRequested = false;

  Stream<String> get routes async* {
    final pending = _pendingRoute;
    if (pending != null) {
      _pendingRoute = null;
      yield pending;
    }
    yield* _routes.stream;
  }

  Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) return;
    _initialized = true;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('/article/')) {
          _routes.add(payload);
        }
      },
    );

    // Create channel before any background isolate posts (Android 8+).
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        kRssNotificationChannelId,
        '订阅更新',
        description: '新文章与订阅源更新',
        importance: Importance.defaultImportance,
      ),
    );

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final payload = launch?.notificationResponse?.payload;
      if (payload != null && payload.startsWith('/article/')) {
        _pendingRoute = payload;
      }
    }
  }

  Future<void> requestPermission() async {
    if (!Platform.isAndroid || _permissionRequested) return;
    _permissionRequested = true;
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showArticle({
    required String articleId,
    required String sourceName,
    required String title,
  }) async {
    if (!Platform.isAndroid) return;
    await initialize();
    await _plugin.show(
      id: articleId.hashCode & 0x7fffffff,
      title: sourceName,
      body: title,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          kRssNotificationChannelId,
          '订阅更新',
          channelDescription: '新文章与订阅源更新',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.social,
        ),
      ),
      payload: '/article/${Uri.encodeComponent(articleId)}',
    );
  }
}

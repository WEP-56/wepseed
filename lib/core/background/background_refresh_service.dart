import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/db/app_database.dart';
import '../../data/models/models.dart';
import '../../data/repositories/drift_feed_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import 'notification_service.dart';

const _refreshUniqueName = 'wepseed.periodic-rss-refresh';
const _refreshTaskName = 'wepseed.refresh-feeds';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != _refreshTaskName) return true;
    WidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase();
    final feeds = DriftFeedRepository(db);
    try {
      final settings = await SettingsRepositoryImpl(db).get();
      final beforeRows = await db.select(db.articles).get();
      final beforeIds = beforeRows.map((row) => row.id).toSet();

      await feeds.refreshAll(wifiOnly: settings.wifiOnly);

      if (settings.notificationsEnabled) {
        final query = db.select(db.articles).join([
          innerJoin(db.feeds, db.feeds.id.equalsExp(db.articles.feedId)),
        ])..orderBy([OrderingTerm.desc(db.articles.publishedAt)]);
        final rows = await query.get();
        final fresh = rows
            .where((row) => !beforeIds.contains(row.readTable(db.articles).id))
            .take(3);
        for (final row in fresh) {
          final article = row.readTable(db.articles);
          final feed = row.readTable(db.feeds);
          await NotificationService.instance.showArticle(
            articleId: article.id,
            sourceName: feed.title,
            title: article.title,
          );
        }
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      feeds.dispose();
      await db.close();
    }
  });
}

class BackgroundRefreshService {
  BackgroundRefreshService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) return;
    _initialized = true;
    await Workmanager().initialize(backgroundCallbackDispatcher);
  }

  static Future<void> configure(AppSettings settings) async {
    if (!Platform.isAndroid) return;
    await initialize();
    if (settings.notificationsEnabled) {
      await NotificationService.instance.requestPermission();
    }
    final minutes = settings.refreshMinutes.clamp(15, 24 * 60);
    await Workmanager().registerPeriodicTask(
      _refreshUniqueName,
      _refreshTaskName,
      frequency: Duration(minutes: minutes),
      constraints: Constraints(
        networkType: settings.wifiOnly
            ? NetworkType.unmetered
            : NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}

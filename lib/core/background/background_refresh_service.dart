import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/db/app_database.dart';
import '../../data/models/models.dart';
import '../../data/repositories/drift_feed_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/rss/rss_refresh_config.dart';
import 'comment_job_worker.dart';
import 'notification_service.dart';

/// Unique name for [Workmanager.registerPeriodicTask] (enqueue identity).
const kRssRefreshUniqueName = 'wepseed.periodic-rss-refresh';

/// Value delivered as `taskName` inside [backgroundCallbackDispatcher].
const kRssRefreshTaskName = 'wepseed.refresh-feeds';

const _rssTag = 'wepseed.rss';

/// Top-level entry for Android WorkManager isolate.
///
/// Survives app swipe-away / process death **when the OS still runs WM**
/// (force-stop and some OEM killers still require user to reopen once).
@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Unknown tasks must not fail the worker.
    if (taskName != kRssRefreshTaskName && taskName != kCommentJobTaskName) {
      return true;
    }

    // executeTask already ensures binding; still register plugins so
    // path_provider / sqlite / notifications / secure_storage work here.
    DartPluginRegistrant.ensureInitialized();

    try {
      if (taskName == kCommentJobTaskName) {
        return await runCommentJobsDrain();
      }
      await NotificationService.instance.initialize();
      return await runRssRefreshJob();
    } catch (e, st) {
      debugPrint('wepseed background task ($taskName) failed: $e\n$st');
      return false;
    }
  });
}

/// RSS pull + optional local notifications. Used by the WM isolate and tests.
///
/// Opens its own [AppDatabase] so the background engine never shares the UI
/// isolate connection.
Future<bool> runRssRefreshJob() async {
  final db = AppDatabase();
  final feeds = DriftFeedRepository(db);
  try {
    final settings = await SettingsRepositoryImpl(db).get();
    final beforeRows = await db.select(db.articles).get();
    final beforeIds = beforeRows.map((row) => row.id).toSet();

    final filterIds = settings.feedFilter.feedIds;
    await feeds.refreshAll(
      wifiOnly: settings.wifiOnly,
      feedIds: filterIds.isEmpty ? null : filterIds,
      mode: RssRefreshMode.background,
    );

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
  } catch (e, st) {
    debugPrint('wepseed runRssRefreshJob error: $e\n$st');
    return false;
  } finally {
    feeds.dispose();
    await db.close();
  }
}

class BackgroundRefreshService {
  BackgroundRefreshService._();

  static bool _initialized = false;

  /// Register the Dart callback handle with the platform plugin.
  static Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) return;
    _initialized = true;
    await Workmanager().initialize(backgroundCallbackDispatcher);
  }

  /// Cold-start: load settings from disk and (re)enqueue periodic work.
  ///
  /// Call after [initialize] so force-stop / first-launch still get a schedule
  /// even if the settings stream has not emitted yet.
  static Future<void> scheduleFromDatabase() async {
    if (!Platform.isAndroid) return;
    await initialize();
    final db = AppDatabase();
    try {
      final settings = await SettingsRepositoryImpl(db).get();
      await configure(settings);
    } catch (e, st) {
      debugPrint('wepseed scheduleFromDatabase failed: $e\n$st');
    } finally {
      await db.close();
    }
  }

  /// Apply settings to WorkManager constraints + notification permission.
  ///
  /// Always re-registers with [ExistingPeriodicWorkPolicy.update] so frequency
  /// / Wi‑Fi constraints stay in sync. Work keeps running when the process is
  /// dead; [notificationsEnabled] only gates posting, not the pull itself.
  static Future<void> configure(AppSettings settings) async {
    if (!Platform.isAndroid) return;
    await initialize();
    if (settings.notificationsEnabled) {
      await NotificationService.instance.requestPermission();
    }

    final minutes = settings.refreshMinutes.clamp(15, 24 * 60);
    await Workmanager().registerPeriodicTask(
      kRssRefreshUniqueName,
      kRssRefreshTaskName,
      frequency: Duration(minutes: minutes),
      // Do not set requiresBatteryNotLow — OEM power savers already throttle;
      // adding this constraint often skips refresh when the user most needs it.
      constraints: Constraints(
        networkType: settings.wifiOnly
            ? NetworkType.unmetered
            : NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      tag: _rssTag,
    );
  }

  /// Dev / support: whether the periodic job is still enqueued.
  static Future<bool> isRssRefreshScheduled() async {
    if (!Platform.isAndroid) return false;
    await initialize();
    return Workmanager().isScheduledByUniqueName(kRssRefreshUniqueName);
  }
}

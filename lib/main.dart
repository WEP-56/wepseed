import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'core/background/background_refresh_service.dart';
import 'core/background/comment_job_worker.dart';
import 'core/background/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.wepseed.wepseed.media_playback',
    androidNotificationChannelName: '媒体播放',
    androidNotificationOngoing: true,
  );
  await NotificationService.instance.initialize();
  // Register WM callback + enqueue periodic RSS pull from disk settings so
  // kill-background still gets a schedule after cold start / force-stop reopen.
  await BackgroundRefreshService.scheduleFromDatabase();
  // D-task: release stale comment-job leases and enqueue one-off drain if needed.
  await recoverCommentJobsOnColdStart();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const ProviderScope(child: WepseedApp()));
}

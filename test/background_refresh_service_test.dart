import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/core/background/background_refresh_service.dart';
import 'package:wepseed/core/background/comment_job_worker.dart';
import 'package:wepseed/core/background/notification_service.dart';

void main() {
  test('RSS task name constants stay stable for WorkManager identity', () {
    expect(kRssRefreshUniqueName, 'wepseed.periodic-rss-refresh');
    expect(kRssRefreshTaskName, 'wepseed.refresh-feeds');
    expect(kRssNotificationChannelId, 'rss_updates');
  });

  test('comment job WM names are distinct from RSS', () {
    expect(kCommentJobUniqueName, 'wepseed.oneoff-comment-jobs');
    expect(kCommentJobTaskName, 'wepseed.drain-comment-jobs');
    expect(kCommentJobTaskName, isNot(equals(kRssRefreshTaskName)));
    expect(kCommentJobUniqueName, isNot(equals(kRssRefreshUniqueName)));
  });
}

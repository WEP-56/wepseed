import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/rsshub/radar_models.dart';

void main() {
  group('buildRadarFeedPath', () {
    test('fills required and drops empty optional segments', () {
      final path = buildRadarFeedPath(
        '/bilibili/user/video/:uid/:embed?',
        {'uid': '2267573', 'embed': ''},
      );
      expect(path, '/bilibili/user/video/2267573');
    });

    test('keeps incomplete required markers', () {
      final path = buildRadarFeedPath(
        '/telegram/channel/:username/:routeParams?',
        {'username': '', 'routeParams': ''},
      );
      expect(path, '/telegram/channel/:username');
      expect(radarPathIsComplete(path), isFalse);
    });

    test('preserves @ in youtube handles', () {
      final path = buildRadarFeedPath(
        '/youtube/user/:username/:routeParams?',
        {'username': '@JFlaMusic'},
      );
      expect(path, '/youtube/user/@JFlaMusic');
    });
  });

  group('buildRadarFeedUrl', () {
    test('joins instance origin and path', () {
      final url = buildRadarFeedUrl(
        instanceOrigin: 'https://rsshub.rssforever.com',
        pathTemplate: '/telegram/channel/:username',
        params: {'username': 'awesomeRSSHub'},
      );
      expect(
        url,
        'https://rsshub.rssforever.com/telegram/channel/awesomeRSSHub',
      );
    });
  });
}

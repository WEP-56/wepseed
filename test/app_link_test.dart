import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/core/utils/app_link.dart';

void main() {
  group('requesterHost', () {
    test('strips www and falls back', () {
      expect(requesterHost('https://www.bilibili.com/video/1'), 'bilibili.com');
      expect(requesterHost('https://x.com/i/status/1'), 'x.com');
      expect(requesterHost(null), '当前网页');
      expect(requesterHost(''), '当前网页');
    });
  });

  group('targetAppLabel', () {
    test('maps schemes and packages', () {
      expect(targetAppLabel('bilibili://video/123'), '哔哩哔哩');
      expect(targetAppLabel('twitter://user?screen_name=x'), 'X');
      expect(
        targetAppLabel(
          'intent://video/123#Intent;scheme=bilibili;package=tv.danmaku.bili;end',
        ),
        '哔哩哔哩',
      );
      expect(targetAppLabel('mailto:a@b.com'), '邮件');
    });
  });

  group('intent helpers', () {
    const intent =
        'intent://www.bilibili.com/video/BV1#Intent;scheme=bilibili;'
        'package=tv.danmaku.bili;'
        'S.browser_fallback_url=https%3A%2F%2Fwww.bilibili.com%2Fvideo%2FBV1;end';

    test('parses package scheme fallback', () {
      expect(intentPackage(intent), 'tv.danmaku.bili');
      expect(intentScheme(intent), 'bilibili');
      expect(
        intentFallbackUrl(intent),
        'https://www.bilibili.com/video/BV1',
      );
    });
  });
}

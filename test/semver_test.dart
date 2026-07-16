import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/update/github_update_service.dart';

void main() {
  test('compareSemver orders dotted versions', () {
    expect(compareSemver('0.0.1', '0.0.2'), lessThan(0));
    expect(compareSemver('1.0.0', '0.9.9'), greaterThan(0));
    expect(compareSemver('1.2.3', '1.2.3'), 0);
    expect(compareSemver('v1.2.0', '1.2.0'), 0);
    expect(compareSemver('0.0.1+5', '0.0.1'), 0);
  });

  test('normalizeVersionTag strips v prefix', () {
    expect(normalizeVersionTag('v0.0.1'), '0.0.1');
    expect(normalizeVersionTag('0.0.1'), '0.0.1');
  });

  test('pickApkAsset prefers arm64', () {
    final release = GithubReleaseInfo(
      tagName: 'v1.0.0',
      version: '1.0.0',
      body: '',
      htmlUrl: 'https://example.com',
      assets: const [
        ReleaseAsset(
          name: 'wepseed-1.0.0-x86_64.apk',
          downloadUrl: 'https://example.com/x',
          size: 1,
        ),
        ReleaseAsset(
          name: 'wepseed-1.0.0-arm64-v8a.apk',
          downloadUrl: 'https://example.com/a',
          size: 2,
        ),
        ReleaseAsset(
          name: 'wepseed-1.0.0-armeabi-v7a.apk',
          downloadUrl: 'https://example.com/b',
          size: 3,
        ),
      ],
    );
    final asset = GithubUpdateService().pickApkAsset(release);
    expect(asset?.name, contains('arm64-v8a'));
  });
}

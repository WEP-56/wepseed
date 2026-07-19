import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/core/utils/open_url.dart';

void main() {
  group('normalizeHttpUrl', () {
    test('accepts http and https', () {
      expect(
        normalizeHttpUrl('https://example.com/path'),
        'https://example.com/path',
      );
      expect(
        normalizeHttpUrl('http://example.com'),
        'http://example.com',
      );
    });

    test('adds https when scheme missing', () {
      expect(normalizeHttpUrl('example.com/a'), 'https://example.com/a');
    });

    test('rejects empty and non-http schemes', () {
      expect(normalizeHttpUrl(null), isNull);
      expect(normalizeHttpUrl(''), isNull);
      expect(normalizeHttpUrl('   '), isNull);
      expect(normalizeHttpUrl('ftp://example.com'), isNull);
      expect(normalizeHttpUrl('javascript:alert(1)'), isNull);
      expect(normalizeHttpUrl('mailto:a@b.com'), isNull);
    });

    test('rejects hostless urls', () {
      expect(normalizeHttpUrl('https://'), isNull);
      expect(normalizeHttpUrl('http:///path'), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/features/new/article_toc.dart';

void main() {
  test('extractHeadingMeta pulls h1-h3 in order', () {
    const html = '''
<p>intro</p>
<h2>概览</h2>
<p>x</p>
<h3>要闻</h3>
<h2>模型发布</h2>
<h4>skip</h4>
''';
    final meta = extractHeadingMeta(html);
    expect(meta.map((e) => e.title).toList(), ['概览', '要闻', '模型发布']);
    expect(meta.map((e) => e.level).toList(), [2, 3, 2]);
  });

  test('injectTocMarkers adds data-toc indices', () {
    const html = '<h2>A</h2><p>x</p><h3 class="t">B</h3>';
    final out = injectTocMarkers(html, 2);
    expect(out, contains('data-toc="0"'));
    expect(out, contains('data-toc="1"'));
    expect(out, contains('class="t"'));
  });
}

import '../../widgets/edge_scrubber.dart';

export '../../widgets/edge_scrubber.dart';

/// Pull h1–h3 titles from HTML for the detail scrubber (order preserved).
List<({String title, int level})> extractHeadingMeta(String? html) {
  if (html == null || html.trim().isEmpty) return const [];
  final re = RegExp(r'<h([1-3])\b[^>]*>([\s\S]*?)</h\1>', caseSensitive: false);
  final out = <({String title, int level})>[];
  for (final m in re.allMatches(html)) {
    final level = int.tryParse(m.group(1) ?? '2') ?? 2;
    final title = _stripTags(m.group(2) ?? '').trim();
    if (title.isEmpty) continue;
    out.add((title: title, level: level));
  }
  return out;
}

/// Inject `data-toc="i"` on successive h1–h3 so render can attach [GlobalKey]s.
String injectTocMarkers(String html, int count) {
  if (count <= 0) return html;
  var i = 0;
  return html.replaceAllMapped(
    RegExp(r'<h([1-3])(\b[^>]*)>', caseSensitive: false),
    (m) {
      if (i >= count) return m.group(0)!;
      final tag = m.group(1)!;
      final attrs = m.group(2) ?? '';
      final cleaned = attrs.replaceAll(
        RegExp(r'''\sdata-toc\s*=\s*["'][^"']*["']''', caseSensitive: false),
        '',
      );
      final out = '<h$tag$cleaned data-toc="$i">';
      i++;
      return out;
    },
  );
}

List<ScrubEntry> scrubEntriesFromHeadings(
  List<({String title, int level})> meta,
) {
  return [for (final m in meta) ScrubEntry(label: m.title, level: m.level)];
}

String _stripTags(String s) {
  return s
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'&nbsp;'), ' ')
      .replaceAll(RegExp(r'&amp;'), '&')
      .replaceAll(RegExp(r'&lt;'), '<')
      .replaceAll(RegExp(r'&gt;'), '>')
      .replaceAll(RegExp(r'&quot;'), '"')
      .replaceAll(RegExp(r'&#39;'), "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

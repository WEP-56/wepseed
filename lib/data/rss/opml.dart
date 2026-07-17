import 'package:xml/xml.dart';

/// Minimal OPML 2.0 import/export for feed outlines.
class OpmlOutline {
  const OpmlOutline({required this.title, required this.xmlUrl, this.htmlUrl});

  final String title;
  final String xmlUrl;
  final String? htmlUrl;
}

class Opml {
  /// Collect all outlines that have `xmlUrl` (nested groups flattened).
  static List<OpmlOutline> parse(String xml) {
    late XmlDocument doc;
    try {
      doc = XmlDocument.parse(xml);
    } on XmlException {
      throw FormatException('OPML 不是有效 XML');
    }

    final body = doc.findAllElements('body').firstOrNull;
    if (body == null) return const [];

    final result = <OpmlOutline>[];
    void walk(XmlElement el) {
      for (final outline in el.findElements('outline')) {
        final xmlUrl =
            outline.getAttribute('xmlUrl') ?? outline.getAttribute('xmlurl');
        if (xmlUrl != null && xmlUrl.trim().isNotEmpty) {
          final title =
              outline.getAttribute('title') ??
              outline.getAttribute('text') ??
              xmlUrl;
          final htmlUrl =
              outline.getAttribute('htmlUrl') ??
              outline.getAttribute('htmlurl');
          result.add(
            OpmlOutline(
              title: title.trim(),
              xmlUrl: xmlUrl.trim(),
              htmlUrl: htmlUrl?.trim(),
            ),
          );
        }
        walk(outline);
      }
    }

    walk(body);
    return result;
  }

  static String export(
    List<({String title, String xmlUrl, String? htmlUrl})> feeds, {
    String title = 'WEPSEED Subscriptions',
  }) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'opml',
      nest: () {
        builder.attribute('version', '2.0');
        builder.element(
          'head',
          nest: () {
            builder.element('title', nest: title);
            builder.element(
              'dateCreated',
              nest: DateTime.now().toUtc().toIso8601String(),
            );
          },
        );
        builder.element(
          'body',
          nest: () {
            for (final f in feeds) {
              builder.element(
                'outline',
                nest: () {
                  builder.attribute('type', 'rss');
                  builder.attribute('text', f.title);
                  builder.attribute('title', f.title);
                  builder.attribute('xmlUrl', f.xmlUrl);
                  if (f.htmlUrl != null && f.htmlUrl!.isNotEmpty) {
                    builder.attribute('htmlUrl', f.htmlUrl!);
                  }
                },
              );
            }
          },
        );
      },
    );
    return builder.buildDocument().toXmlString(pretty: true);
  }
}

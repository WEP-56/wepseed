import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/open_url.dart';
import '../../data/models/models.dart';
import 'article_toc.dart';

/// Renders article body: HTML when available, else plain text.
///
/// When [tocEntries] is non-empty, headings h1–h3 are keyed for [EdgeScrubber].
class ArticleBody extends StatelessWidget {
  const ArticleBody({
    super.key,
    required this.article,
    this.tocEntries = const [],
  });

  final Article article;
  final List<ScrubEntry> tocEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Dark mode: keep body near-white; avoid mid-grey that vanishes on #0A0A0A.
    final textColor = isDark
        ? const Color(0xFFF0F0F0)
        : AppColors.textPrimaryLight;
    final secondary = isDark
        ? const Color(0xFFC4C4C4)
        : AppColors.textSecondaryLight;
    final muted = isDark
        ? const Color(0xFF9A9A9A)
        : AppColors.textTertiaryLight;
    final linkColor = isDark
        ? const Color(0xFF7CB8F0)
        : const Color(0xFF2563EB);

    if (article.hasHtmlBody) {
      var html = sanitizeArticleHtml(article.contentHtml!);
      if (tocEntries.isNotEmpty) {
        html = injectTocMarkers(html, tocEntries.length);
      }

      return Html(
        data: html,
        onLinkTap: (url, _, _) {
          openExternalUrl(url);
        },
        extensions: [
          TagExtension(
            tagsToExtend: const {'img'},
            builder: (ctx) {
              final src = ctx.attributes['src'];
              if (src == null || src.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: src,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (_, _) => Container(
                      height: 160,
                      color: isDark ? AppColors.inkSoft : AppColors.wash,
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 80,
                      alignment: Alignment.center,
                      color: isDark ? AppColors.inkSoft : AppColors.wash,
                      child: Icon(Icons.broken_image_outlined, color: muted),
                    ),
                  ),
                ),
              );
            },
          ),
          if (tocEntries.isNotEmpty)
            TagExtension(
              tagsToExtend: const {'h1', 'h2', 'h3'},
              builder: (ctx) {
                final idx = int.tryParse(ctx.attributes['data-toc'] ?? '');
                final tag = ctx.elementName.toLowerCase();
                final level = switch (tag) {
                  'h1' => 1,
                  'h3' => 3,
                  _ => 2,
                };
                final style = switch (level) {
                  1 => theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: textColor,
                  ),
                  3 => theme.textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: textColor,
                  ),
                  _ => theme.textTheme.titleLarge?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.32,
                    color: textColor,
                  ),
                };
                final title = idx != null && idx >= 0 && idx < tocEntries.length
                    ? tocEntries[idx].label
                    : _plain(ctx.innerHtml);
                final key = idx != null && idx >= 0 && idx < tocEntries.length
                    ? tocEntries[idx].key
                    : null;

                return Padding(
                  key: key,
                  padding: EdgeInsets.only(
                    top: level == 1 ? 10 : 8,
                    bottom: level == 3 ? 6 : 8,
                  ),
                  child: Text(title, style: style),
                );
              },
            ),
        ],
        style: {
          // Wildcard forces contrast even when feed injects grey inline styles
          // (sanitize strips many; this is the safety net).
          '*': Style(color: textColor),
          'body': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16.5),
            lineHeight: const LineHeight(1.72),
            letterSpacing: 0.05,
            color: textColor,
            fontFamily: theme.textTheme.bodyLarge?.fontFamily,
          ),
          'p': Style(margin: Margins.only(bottom: 14), color: textColor),
          'div': Style(color: textColor),
          'span': Style(color: textColor),
          'h1': Style(
            fontSize: FontSize(22),
            fontWeight: FontWeight.w700,
            margin: Margins.only(top: 10, bottom: 10),
            color: textColor,
          ),
          'h2': Style(
            fontSize: FontSize(19),
            fontWeight: FontWeight.w700,
            margin: Margins.only(top: 8, bottom: 8),
            color: textColor,
          ),
          'h3': Style(
            fontSize: FontSize(17),
            fontWeight: FontWeight.w600,
            margin: Margins.only(top: 6, bottom: 6),
            color: textColor,
          ),
          'h4': Style(
            fontSize: FontSize(16),
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          'a': Style(
            color: linkColor,
            textDecoration: TextDecoration.underline,
            textDecorationColor: linkColor.withValues(alpha: 0.45),
          ),
          'blockquote': Style(
            margin: Margins.symmetric(vertical: 10),
            padding: HtmlPaddings.only(left: 12),
            border: Border(
              left: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 3,
              ),
            ),
            color: secondary,
            fontStyle: FontStyle.italic,
          ),
          'pre': Style(
            backgroundColor: isDark ? AppColors.inkCard : AppColors.wash,
            padding: HtmlPaddings.all(12),
            margin: Margins.symmetric(vertical: 10),
            fontSize: FontSize(13.5),
            whiteSpace: WhiteSpace.pre,
            color: textColor,
          ),
          'code': Style(
            backgroundColor: isDark ? AppColors.inkCard : AppColors.wash,
            fontSize: FontSize(14),
            fontFamily: 'monospace',
            color: textColor,
          ),
          'ul': Style(
            margin: Margins.only(bottom: 12, left: 4),
            color: textColor,
          ),
          'ol': Style(
            margin: Margins.only(bottom: 12, left: 4),
            color: textColor,
          ),
          'li': Style(
            margin: Margins.only(bottom: 8),
            color: textColor,
            listStylePosition: ListStylePosition.outside,
          ),
          'strong': Style(color: textColor, fontWeight: FontWeight.w700),
          'b': Style(color: textColor, fontWeight: FontWeight.w700),
          'em': Style(color: textColor),
          'i': Style(color: textColor),
          'img': Style(
            width: Width(100, Unit.percent),
            margin: Margins.symmetric(vertical: 8),
          ),
          'figure': Style(margin: Margins.symmetric(vertical: 12)),
          'figcaption': Style(
            fontSize: FontSize(12.5),
            color: muted,
            textAlign: TextAlign.center,
            margin: Margins.only(top: 6),
          ),
          'hr': Style(
            margin: Margins.symmetric(vertical: 16),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
          ),
          'table': Style(color: textColor),
          'td': Style(color: textColor, padding: HtmlPaddings.all(4)),
          'th': Style(
            color: textColor,
            fontWeight: FontWeight.w600,
            padding: HtmlPaddings.all(4),
          ),
        },
      );
    }

    final plain = article.body.trim().isEmpty
        ? article.summary.trim()
        : article.body.trim();
    if (plain.isEmpty) {
      return Text(
        '暂无正文。可打开原文阅读。',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: secondary,
          height: 1.55,
        ),
      );
    }

    return SelectableText(
      plain,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.72,
        fontSize: 16.5,
        letterSpacing: 0.05,
        color: textColor,
      ),
    );
  }

  static String _plain(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

/// Strip feed-provided greys / opacity that kill dark-mode contrast.
String sanitizeArticleHtml(String raw) {
  var s = raw.trim();
  // color: … in style attributes
  s = s.replaceAll(
    RegExp(r'''color\s*:\s*[^;"']+;?''', caseSensitive: false),
    '',
  );
  // opacity that fades body
  s = s.replaceAll(
    RegExp(r'''opacity\s*:\s*[^;"']+;?''', caseSensitive: false),
    '',
  );
  // legacy <font color="…">
  s = s.replaceAll(
    RegExp(r'''\scolor\s*=\s*["'][^"']*["']''', caseSensitive: false),
    '',
  );
  // empty style=""
  s = s.replaceAll(
    RegExp(r'''\sstyle\s*=\s*["']\s*["']''', caseSensitive: false),
    '',
  );
  return s;
}

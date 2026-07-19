import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/browser/in_app_browser_page.dart';

/// Where to open an http(s) URL.
enum UrlOpenMode {
  /// Application-internal WebView ([InAppBrowserPage]).
  inApp,

  /// System browser / external application.
  system,
}

/// Normalize user or feed input into an absolute http(s) URL, or null if invalid.
String? normalizeHttpUrl(String? url) {
  final raw = url?.trim();
  if (raw == null || raw.isEmpty) return null;

  // Only auto-prefix bare hosts (example.com). Keep real schemes (mailto:,
  // javascript:, intent:, …) so non-http is rejected below — not turned into
  // https://mailto:…
  final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(raw);
  final candidate = hasScheme ? raw : 'https://$raw';

  final uri = Uri.tryParse(candidate);
  if (uri == null) return null;
  if (!(uri.isScheme('http') || uri.isScheme('https'))) return null;
  if (uri.host.isEmpty) return null;
  return uri.toString();
}

/// Open [url] in the in-app browser (default) or system browser.
///
/// - [UrlOpenMode.inApp] requires a [context] that can push a route.
/// - Falls back to system browser if context is missing or push fails.
/// - Non-http(s) URLs return false.
///
/// Prefer this helper for all article / feed / settings links so behaviour
/// stays centralized (see docs IMPLEMENTATION §15.6).
Future<bool> openUrl(
  String? url, {
  BuildContext? context,
  String? title,
  UrlOpenMode mode = UrlOpenMode.inApp,
}) async {
  final normalized = normalizeHttpUrl(url);
  if (normalized == null) return false;

  if (mode == UrlOpenMode.inApp && context != null && context.mounted) {
    await InAppBrowserPage.open(context, normalized, title: title);
    return true;
  }

  return openInSystemBrowser(normalized);
}

/// Always open in the **system** browser.
Future<bool> openInSystemBrowser(String? url) async {
  final normalized = normalizeHttpUrl(url);
  if (normalized == null) return false;
  final uri = Uri.parse(normalized);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Alias of [openUrl] (kept for existing call sites).
Future<bool> openExternalUrl(
  String? url, {
  BuildContext? context,
  String? title,
  UrlOpenMode mode = UrlOpenMode.inApp,
}) {
  return openUrl(url, context: context, title: title, mode: mode);
}

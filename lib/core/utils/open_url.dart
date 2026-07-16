import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the **system browser** (external application).
///
/// In-app WebView (cookies / downloads) is deferred — see docs IMPLEMENTATION
/// Phase F / §15 backlog. Prefer this helper so we can swap later in one place.
Future<bool> openExternalUrl(String? url) async {
  final raw = url?.trim();
  if (raw == null || raw.isEmpty) return false;
  final uri = Uri.tryParse(raw);
  if (uri == null) return false;
  if (!(uri.isScheme('http') || uri.isScheme('https'))) return false;

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

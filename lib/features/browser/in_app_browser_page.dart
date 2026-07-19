import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../core/utils/app_link.dart';
import '../../core/utils/open_url.dart';
import '../../providers/browser_library_provider.dart';
import '../../providers/download_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/liquid_glass.dart';
import 'download_list_page.dart';
import 'web_library_pages.dart';

/// Lightweight in-app browser.
///
/// Back: WebView history first, then pop the page.
/// Menu: copy URL · open in system browser · downloads.
class InAppBrowserPage extends ConsumerStatefulWidget {
  const InAppBrowserPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  /// Push a browser page. Returns when the user closes it.
  static Future<T?> open<T extends Object?>(
    BuildContext context,
    String url, {
    String? title,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => InAppBrowserPage(url: url, title: title),
      ),
    );
  }

  @override
  ConsumerState<InAppBrowserPage> createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends ConsumerState<InAppBrowserPage> {
  static const _allowedSchemes = {'http', 'https', 'about', 'data', 'blob'};

  InAppWebViewController? _controller;
  late String _currentUrl;
  late String _currentTitle;
  double _progress = 0;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _appLinkPromptOpen = false;
  bool _incognito = false;
  bool _privacyPrimed = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _currentTitle = widget.title?.trim() ?? '';
  }

  @override
  void dispose() {
    if (_incognito) {
      // Best-effort: wipe session cookies when leaving private mode.
      CookieManager.instance().deleteAllCookies();
      InAppWebViewController.clearAllCache();
    }
    _controller = null;
    super.dispose();
  }

  Future<void> _primeIncognitoIfNeeded() async {
    if (_privacyPrimed) return;
    _privacyPrimed = true;
    final settings = ref.read(settingsProvider).value;
    _incognito = settings?.browserIncognito ?? false;
    if (_incognito) {
      try {
        await CookieManager.instance().deleteAllCookies();
        await InAppWebViewController.clearAllCache();
      } catch (_) {}
    }
  }

  Future<void> _handleBackNavigation() async {
    final controller = _controller;
    if (controller != null) {
      final canGoBack = await controller.canGoBack();
      if (canGoBack) {
        await controller.goBack();
        return;
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _copyUrl() async {
    if (_currentUrl.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _currentUrl));
    if (mounted) showAppToast('链接已复制', context: context);
  }

  Future<void> _openInSystemBrowser() async {
    if (_currentUrl.isEmpty) return;
    final ok = await openInSystemBrowser(_currentUrl);
    if (!ok && mounted) {
      showAppToast('无法打开系统浏览器', context: context);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_currentUrl.isEmpty) return;
    final added = await ref
        .read(webBookmarkProvider.notifier)
        .toggle(_currentUrl, _currentTitle);
    if (mounted) {
      showAppToast(added ? '已收藏' : '已取消收藏', context: context);
    }
  }

  Future<void> _showUrlDialog() async {
    final submitted = await showDialog<String>(
      context: context,
      builder: (ctx) => _UrlInputDialog(initialUrl: _currentUrl),
    );
    if (submitted == null || !mounted) return;
    final normalized = normalizeHttpUrl(submitted);
    if (normalized == null) {
      showAppToast('无效的网址', context: context);
      return;
    }
    await _controller?.loadUrl(
      urlRequest: URLRequest(url: WebUri(normalized)),
    );
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url;
    if (url == null) return NavigationActionPolicy.ALLOW;

    final scheme = url.scheme.toLowerCase();
    if (_allowedSchemes.contains(scheme)) {
      return NavigationActionPolicy.ALLOW;
    }
    if (scheme == 'javascript') {
      return NavigationActionPolicy.CANCEL;
    }

    final urlString = url.toString();
    if (mounted) {
      await _confirmAndLaunchAppLink(urlString);
    }
    return NavigationActionPolicy.CANCEL;
  }

  Future<void> _confirmAndLaunchAppLink(String appUrl) async {
    if (_appLinkPromptOpen || !mounted) return;
    _appLinkPromptOpen = true;
    try {
      final site = requesterHost(_currentUrl);
      final app = targetAppLabel(appUrl);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('打开外部应用'),
          content: Text('$site 要求打开「$app」'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('拒绝'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('同意'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      final ok = await launchAppLink(appUrl);
      if (!ok && mounted) {
        showAppToast('未找到可处理的应用', context: context);
      }
    } finally {
      _appLinkPromptOpen = false;
    }
  }

  Future<void> _onDownloadStartRequest(
    InAppWebViewController controller,
    DownloadStartRequest request,
  ) async {
    final url = request.url.toString();
    if (url.isEmpty) return;
    ref.read(downloadListProvider.notifier).startDownload(
          url: url,
          suggestedFilename: request.suggestedFilename,
          mimeType: request.mimeType,
          contentLength: request.contentLength,
        );
    if (mounted) {
      showAppToast(
        '开始下载${request.suggestedFilename != null ? '：${request.suggestedFilename}' : ''}',
        context: context,
        action: SnackBarAction(
          label: '查看',
          onPressed: () => DownloadListPage.open(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final displayTitle = _currentTitle.isNotEmpty
        ? _currentTitle
        : (_currentUrl.isNotEmpty ? _currentUrl : '浏览器');
    final incognito =
        ref.watch(settingsProvider).value?.browserIncognito ?? false;
    final bookmarked = ref.watch(
      webBookmarkProvider.select(
        (list) => list.any((e) => e.url == _currentUrl),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            SizedBox(height: top + 6),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
              child: Row(
                children: [
                  LiquidGlassIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showUrlDialog,
                      child: LiquidGlass(
                        borderRadius: 20,
                        blur: 16,
                        shadow: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              incognito
                                  ? Icons.visibility_off_outlined
                                  : Icons.lock_outline_rounded,
                              size: 14,
                              color: secondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _NavIcon(
                    icon: Icons.chevron_left_rounded,
                    enabled: _canGoBack,
                    onTap: () => _controller?.goBack(),
                  ),
                  _NavIcon(
                    icon: Icons.chevron_right_rounded,
                    enabled: _canGoForward,
                    onTap: () => _controller?.goForward(),
                  ),
                  _NavIcon(
                    icon: Icons.refresh_rounded,
                    enabled: true,
                    onTap: () => _controller?.reload(),
                  ),
                  PopupMenuButton<String>(
                    tooltip: '更多',
                    onSelected: (value) {
                      switch (value) {
                        case 'bookmark':
                          _toggleBookmark();
                        case 'copy':
                          _copyUrl();
                        case 'external':
                          _openInSystemBrowser();
                        case 'bookmarks':
                          WebBookmarksPage.open(context);
                        case 'history':
                          WebHistoryPage.open(context);
                        case 'downloads':
                          DownloadListPage.open(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'bookmark',
                        child: Text(bookmarked ? '取消收藏' : '收藏此页'),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: Text('复制链接'),
                      ),
                      const PopupMenuItem(
                        value: 'external',
                        child: Text('系统浏览器打开'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'bookmarks',
                        child: Text('网页收藏'),
                      ),
                      const PopupMenuItem(
                        value: 'history',
                        child: Text('浏览历史'),
                      ),
                      const PopupMenuItem(
                        value: 'downloads',
                        child: Text('下载管理'),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 22,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              LinearProgressIndicator(
                value: _progress > 0 && _progress < 1 ? _progress : null,
                minHeight: 2,
                backgroundColor: isDark ? AppColors.inkSoft : AppColors.wash,
              ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: !incognito,
                  databaseEnabled: !incognito,
                  cacheEnabled: !incognito,
                  cacheMode: incognito
                      ? CacheMode.LOAD_NO_CACHE
                      : CacheMode.LOAD_DEFAULT,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useShouldOverrideUrlLoading: true,
                  useOnDownloadStart: true,
                  transparentBackground: false,
                  supportZoom: true,
                  builtInZoomControls: true,
                  displayZoomControls: false,
                  // Keep cookies for the session so sites work; wipe on leave
                  // when incognito is on.
                  thirdPartyCookiesEnabled: true,
                  sharedCookiesEnabled: !incognito,
                ),
                shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
                onDownloadStartRequest: _onDownloadStartRequest,
                onWebViewCreated: (controller) async {
                  _controller = controller;
                  await _primeIncognitoIfNeeded();
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _isLoading = true;
                    _currentUrl = url?.toString() ?? _currentUrl;
                  });
                },
                onProgressChanged: (controller, progress) {
                  setState(() => _progress = progress / 100);
                },
                onLoadStop: (controller, url) async {
                  final title = await controller.getTitle();
                  final canGoBack = await controller.canGoBack();
                  final canGoForward = await controller.canGoForward();
                  if (!mounted) return;
                  final urlString = url?.toString() ?? _currentUrl;
                  final pageTitle =
                      (title != null && title.isNotEmpty) ? title : _currentTitle;
                  setState(() {
                    _isLoading = false;
                    _progress = 1;
                    _currentUrl = urlString;
                    _canGoBack = canGoBack;
                    _canGoForward = canGoForward;
                    if (title != null && title.isNotEmpty) {
                      _currentTitle = title;
                    }
                  });
                  // Private mode: do not write browsing history.
                  if (!incognito && urlString.isNotEmpty) {
                    ref
                        .read(webHistoryProvider.notifier)
                        .record(urlString, pageTitle);
                  }
                },
                onUpdateVisitedHistory: (controller, url, _) async {
                  final canGoBack = await controller.canGoBack();
                  final canGoForward = await controller.canGoForward();
                  if (!mounted) return;
                  setState(() {
                    _currentUrl = url?.toString() ?? _currentUrl;
                    _canGoBack = canGoBack;
                    _canGoForward = canGoForward;
                  });
                },
                onTitleChanged: (controller, title) {
                  if (title != null && title.isNotEmpty && mounted) {
                    setState(() => _currentTitle = title);
                  }
                },
                onReceivedError: (controller, request, error) {
                  if (request.isForMainFrame == true && mounted) {
                    setState(() => _isLoading = false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = enabled
        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 24, color: color),
    );
  }
}

class _UrlInputDialog extends StatefulWidget {
  const _UrlInputDialog({required this.initialUrl});

  final String initialUrl;

  @override
  State<_UrlInputDialog> createState() => _UrlInputDialogState();
}

class _UrlInputDialogState extends State<_UrlInputDialog> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit([String? value]) {
    Navigator.of(context).pop(value ?? _textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('网址'),
      content: TextField(
        controller: _textController,
        autofocus: true,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.go,
        decoration: const InputDecoration(
          hintText: 'https://',
          border: OutlineInputBorder(),
        ),
        onSubmitted: _submit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('前往'),
        ),
      ],
    );
  }
}

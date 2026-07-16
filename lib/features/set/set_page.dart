import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/config/app_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../core/utils/monogram.dart';
import '../../core/utils/open_url.dart';
import '../../data/models/models.dart';
import '../../data/update/github_update_service.dart';
import '../../providers/feed_providers.dart';
import '../../providers/settings_provider.dart';
import 'llm_settings_section.dart';

class SetPage extends ConsumerWidget {
  const SetPage({super.key});

  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final user = ref.watch(userProfileProvider).value ??
        const UserProfile(displayName: '旅人');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final controller = ref.read(settingsControllerProvider);

    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snap) {
        final version = snap.data?.version ?? '0.0.1';
        return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, top + 10, 20, 120),
      children: [
        Text(
          'Set',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Local only',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ),
        const SizedBox(height: 22),
        _Section(
          title: '常规',
          children: [
            _NavTile(
              icon: Icons.person_outline_rounded,
              title: '我的形象',
              subtitle: user.displayName,
              onTap: () => _openUserEditor(context, controller, user),
            ),
            _NavTile(
              icon: Icons.palette_outlined,
              title: '外观',
              subtitle: _themeLabel(settings.themeMode),
              onTap: () => _openThemePicker(context, controller, settings),
            ),
            _NavTile(
              icon: Icons.text_fields_rounded,
              title: '阅读字号',
              subtitle: '${(settings.fontScale * 100).round()}%',
              onTap: () => _openFontScale(context, controller, settings),
            ),
          ],
        ),
        _Section(
          title: 'RSS',
          children: [
            _NavTile(
              icon: Icons.rss_feed_rounded,
              title: '订阅源',
              subtitle: _feedsSubtitle(ref),
              onTap: () => _openFeedsManager(context, ref),
            ),
            _NavTile(
              icon: Icons.add_link_rounded,
              title: '添加订阅',
              subtitle: '输入 RSS / Atom URL',
              onTap: () => _openAddFeed(context, ref),
            ),
            _NavTile(
              icon: Icons.file_upload_outlined,
              title: '导入 OPML',
              subtitle: '粘贴 OPML 文本迁入',
              onTap: () => _openImportOpml(context, ref),
            ),
            _NavTile(
              icon: Icons.file_download_outlined,
              title: '导出 OPML',
              subtitle: '复制源列表到剪贴板',
              onTap: () => _exportOpml(context, ref),
            ),
            _NavTile(
              icon: Icons.sync_rounded,
              title: '刷新频率',
              subtitle: '后台每 ${settings.refreshMinutes} 分钟（系统最短约 15 分）',
              onTap: () => _openRefresh(context, controller, settings),
            ),
          ],
        ),
        LlmSettingsSection(
          settings: settings,
          onToast: (msg) => showAppToast(msg, context: context),
        ),
        _Section(
          title: 'DATA',
          children: [
            _SwitchTile(
              icon: Icons.notifications_none_rounded,
              title: '更新通知',
              subtitle: '后台刷到新文时本地提醒',
              value: settings.notificationsEnabled,
              onChanged: (v) {
                controller.updateSettings(
                  settings.copyWith(notificationsEnabled: v),
                );
              },
            ),
            _SwitchTile(
              icon: Icons.wifi_rounded,
              title: '仅 Wi-Fi 刷新',
              subtitle: '后台拉源仅走 Wi‑Fi',
              value: settings.wifiOnly,
              onChanged: (v) {
                controller.updateSettings(settings.copyWith(wifiOnly: v));
              },
            ),
            _NavTile(
              icon: Icons.battery_saver_outlined,
              title: '后台被杀？',
              subtitle: '允许自启动 / 无限制电池，周期刷新才稳',
              onTap: () => showAppToast(
                '请在系统设置中允许 WEPSEED 后台运行、自启动与通知权限',
                context: context,
              ),
            ),
            _NavTile(
              icon: Icons.cleaning_services_outlined,
              title: '清理缓存',
              subtitle: '图片与临时文件',
              onTap: () => showAppToast('缓存已清理（模拟）', context: context),
            ),
            _NavTile(
              icon: Icons.ios_share_rounded,
              title: '导出我的数据',
              subtitle: '收藏 / 对话 / 设置',
              onTap: () => showAppToast('数据导出 · 占位', context: context),
            ),
          ],
        ),
        _Section(
          title: '关于',
          children: [
            _NavTile(
              icon: Icons.system_update_alt_rounded,
              title: '检查更新',
              subtitle: '当前 $version',
              onTap: () => _openUpdates(context, version),
            ),
            _NavTile(
              icon: Icons.description_outlined,
              title: '用户协议',
              subtitle: '在 GitHub 查看',
              onTap: () => openExternalUrl(kTermsUrl),
            ),
            _NavTile(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              subtitle: '在 GitHub 查看',
              onTap: () => openExternalUrl(kPrivacyUrl),
            ),
            _NavTile(
              icon: Icons.info_outline_rounded,
              title: '关于 WEPSEED',
              subtitle: '本地优先的 RSS 阅读器',
              onTap: () => _openAbout(context, version),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'WEPSEED  ·  $version',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
      },
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => '跟随系统',
        ThemeMode.light => '浅色',
        ThemeMode.dark => '深色',
      };

  String _feedsSubtitle(WidgetRef ref) {
    final feeds = ref.watch(feedsProvider).value;
    if (feeds == null) return '加载中…';
    if (feeds.isEmpty) return '尚未添加';
    return '${feeds.length} 个源';
  }

  Future<void> _openAddFeed(BuildContext context, WidgetRef ref) async {
    final urlCtrl = TextEditingController();
    var busy = false;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return _SheetScaffold(
              title: '添加订阅',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: urlCtrl,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Feed URL',
                      hintText: 'https://example.com/feed.xml',
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PrimaryButton(
                    label: busy ? '拉取中…' : '添加',
                    onTap: busy
                        ? () {}
                        : () async {
                            final url = urlCtrl.text.trim();
                            if (url.isEmpty) return;
                            setModal(() => busy = true);
                            try {
                              await ref.read(feedActionsProvider).addFeed(url);
                              if (ctx.mounted) Navigator.pop(ctx, true);
                            } catch (e) {
                              setModal(() => busy = false);
                              if (ctx.mounted) {
                                showAppToast('$e', context: ctx);
                              }
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (ok == true && context.mounted) {
      showAppToast('已添加订阅', context: context);
    }
  }

  Future<void> _openFeedsManager(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final feeds = ref.watch(feedsProvider).value ?? const [];
            final actions = ref.read(feedActionsProvider);
            final theme = Theme.of(ctx);
            return _SheetScaffold(
              title: '订阅源',
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
                ),
                child: feeds.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            '还没有订阅，点「添加订阅」开始',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: feeds.length,
                        itemBuilder: (_, i) {
                          final f = feeds[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: MonogramAvatar(
                              label: f.name,
                              size: 36,
                              seed: f.id,
                            ),
                            title: Text(
                              f.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              f.isPaused ? '${f.domain} · 已暂停' : f.domain,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'pause') {
                                  await actions.setPaused(f.id, !f.isPaused);
                                } else if (v == 'refresh') {
                                  try {
                                    await actions.refreshFeed(f.id);
                                    if (ctx.mounted) {
                                      showAppToast('已刷新', context: ctx);
                                    }
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      showAppToast('$e', context: ctx);
                                    }
                                  }
                                } else if (v == 'delete') {
                                  await actions.removeFeed(f.id);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'refresh',
                                  child: const Text('刷新'),
                                ),
                                PopupMenuItem(
                                  value: 'pause',
                                  child: Text(f.isPaused ? '恢复' : '暂停'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('删除'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openImportOpml(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    var busy = false;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return _SheetScaffold(
              title: '导入 OPML',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: '粘贴 OPML XML',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PrimaryButton(
                    label: busy ? '导入中…' : '导入',
                    onTap: busy
                        ? () {}
                        : () async {
                            final xml = ctrl.text.trim();
                            if (xml.isEmpty) return;
                            setModal(() => busy = true);
                            try {
                              await ref
                                  .read(feedActionsProvider)
                                  .importOpml(xml);
                              if (ctx.mounted) Navigator.pop(ctx, true);
                            } catch (e) {
                              setModal(() => busy = false);
                              if (ctx.mounted) {
                                showAppToast('$e', context: ctx);
                              }
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (ok == true && context.mounted) {
      showAppToast('OPML 导入完成', context: context);
    }
  }

  Future<void> _exportOpml(BuildContext context, WidgetRef ref) async {
    try {
      final xml = await ref.read(feedActionsProvider).exportOpml();
      await Clipboard.setData(ClipboardData(text: xml));
      if (context.mounted) {
        showAppToast('OPML 已复制到剪贴板', context: context);
      }
    } catch (e) {
      if (context.mounted) showAppToast('$e', context: context);
    }
  }

  Future<void> _openUserEditor(
    BuildContext context,
    SettingsController controller,
    UserProfile user,
  ) async {
    final nameCtrl = TextEditingController(text: user.displayName);

    final result = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SheetScaffold(
          title: '我的形象',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: nameCtrl,
                    builder: (_, _) => MonogramAvatar(
                      label: nameCtrl.text.isEmpty ? '旅' : nameCtrl.text,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: '显示名'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _PrimaryButton(
                label: '保存',
                onTap: () {
                  Navigator.pop(
                    context,
                    UserProfile(
                      displayName: nameCtrl.text.trim().isEmpty
                          ? '旅人'
                          : nameCtrl.text.trim(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      await controller.updateUser(result);
    }
  }

  Future<void> _openThemePicker(
    BuildContext context,
    SettingsController controller,
    AppSettings settings,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SheetScaffold(
          title: '外观',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values)
                ListTile(
                  title: Text(_themeLabel(mode)),
                  trailing: settings.themeMode == mode
                      ? const Icon(Icons.check_rounded, size: 20)
                      : null,
                  onTap: () => Navigator.pop(context, mode),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await controller.updateSettings(settings.copyWith(themeMode: selected));
    }
  }

  Future<void> _openFontScale(
    BuildContext context,
    SettingsController controller,
    AppSettings settings,
  ) async {
    var scale = settings.fontScale;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SheetScaffold(
          title: '阅读字号',
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(scale * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Slider(
                    value: scale,
                    min: 0.9,
                    max: 1.3,
                    divisions: 8,
                    onChanged: (v) => setModal(() => scale = v),
                  ),
                  _PrimaryButton(
                    label: '应用',
                    onTap: () async {
                      await controller
                          .updateSettings(settings.copyWith(fontScale: scale));
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openRefresh(
    BuildContext context,
    SettingsController controller,
    AppSettings settings,
  ) async {
    final options = [15, 30, 60, 120];
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SheetScaffold(
          title: '刷新频率',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final m in options)
                ListTile(
                  title: Text('每 $m 分钟'),
                  trailing: settings.refreshMinutes == m
                      ? const Icon(Icons.check_rounded, size: 20)
                      : null,
                  onTap: () => Navigator.pop(context, m),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await controller
          .updateSettings(settings.copyWith(refreshMinutes: selected));
    }
  }

  Future<void> _openUpdates(BuildContext context, String currentVersion) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UpdateSheet(currentVersion: currentVersion),
    );
  }

  Future<void> _openAbout(BuildContext context, String version) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return _SheetScaffold(
          title: '关于 WEPSEED',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.inkCard : AppColors.wash,
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  'W',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'WEPSEED',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Local-first RSS · 有温度的阅读',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Version $version',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
              const SizedBox(height: 18),
              _PrimaryButton(
                label: 'GitHub 仓库',
                onTap: () => openExternalUrl(kGithubHome),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Check GitHub Releases → optional in-app download + install.
class _UpdateSheet extends StatefulWidget {
  const _UpdateSheet({required this.currentVersion});

  final String currentVersion;

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
  final _service = GithubUpdateService();
  bool _loading = true;
  String? _error;
  UpdateCheckResult? _result;
  bool _downloading = false;
  double _progress = 0;
  String? _status;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.check(widget.currentVersion);
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _downloadAndInstall() async {
    final latest = _result?.latest;
    if (latest == null) return;
    final asset = _service.pickApkAsset(latest);
    if (asset == null) {
      await openExternalUrl(latest.htmlUrl);
      return;
    }

    setState(() {
      _downloading = true;
      _progress = 0;
      _status = '下载中…';
    });

    try {
      final file = await _service.downloadApk(
        asset,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;

      if (Platform.isAndroid) {
        setState(() => _status = '请求安装权限…');
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          setState(() {
            _downloading = false;
            _status = null;
          });
          if (mounted) {
            showAppToast(
              '需要允许「安装未知应用」才能继续；也可在浏览器打开 Release',
              context: context,
              duration: const Duration(seconds: 3),
            );
          }
          await openExternalUrl(asset.downloadUrl);
          return;
        }
      }

      setState(() => _status = '正在调起安装…');
      final openResult = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      if (!mounted) return;
      if (openResult.type != ResultType.done) {
        showAppToast(
          '无法打开安装器：${openResult.message}',
          context: context,
        );
        await openExternalUrl(asset.downloadUrl);
      } else {
        showAppToast('请按系统提示完成安装', context: context);
      }
    } catch (e) {
      if (mounted) {
        showAppToast('下载失败：$e', context: context);
        final url = _service.pickApkAsset(latest)?.downloadUrl ?? latest.htmlUrl;
        await openExternalUrl(url);
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
          _status = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SheetScaffold(
      title: '检查更新',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '当前版本 ${widget.currentVersion}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_error != null) ...[
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            _PrimaryButton(label: '重试', onTap: _check),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => openExternalUrl(kGithubReleases),
              child: const Text('在浏览器打开 Releases'),
            ),
          ] else if (_result != null && !_result!.hasUpdate) ...[
            Text(
              '已是最新（${_result!.latest?.version ?? widget.currentVersion}）',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _PrimaryButton(
              label: '好的',
              onTap: () => Navigator.pop(context),
            ),
          ] else if (_result?.latest != null) ...[
            Text(
              '发现新版本 ${_result!.latest!.version}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_result!.latest!.body.isNotEmpty) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: SingleChildScrollView(
                  child: Text(
                    _result!.latest!.body,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                ),
              ),
            ],
            if (_downloading) ...[
              const SizedBox(height: 14),
              LinearProgressIndicator(value: _progress > 0 ? _progress : null),
              const SizedBox(height: 8),
              Text(
                _status ?? '下载中… ${(_progress * 100).round()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            _PrimaryButton(
              label: _downloading ? '请稍候…' : '下载并安装',
              onTap: _downloading ? () {} : _downloadAndInstall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => openExternalUrl(_result!.latest!.htmlUrl),
              child: const Text('在浏览器打开 Release'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.inkCard : AppColors.paper,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Divider(
                      height: 0.5,
                      indent: 52,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: 20,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: isDark
            ? AppColors.textTertiaryDark
            : AppColors.textTertiaryLight,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: isDark ? AppColors.black : AppColors.white,
      activeTrackColor: isDark ? AppColors.white : AppColors.black,
      secondary: Icon(
        icon,
        size: 20,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inkElevated : AppColors.canvas,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.white : AppColors.black,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }
}

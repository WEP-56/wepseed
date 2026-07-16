import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/monogram.dart';
import '../../data/models/models.dart';
import '../../providers/feed_providers.dart';
import '../../providers/settings_provider.dart';
import 'llm_settings_section.dart';

class SetPage extends ConsumerWidget {
  const SetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final user = ref.watch(userProfileProvider).value ??
        const UserProfile(displayName: '旅人');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final controller = ref.read(settingsControllerProvider);

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
              subtitle: '每 ${settings.refreshMinutes} 分钟',
              onTap: () => _openRefresh(context, controller, settings),
            ),
          ],
        ),
        LlmSettingsSection(
          settings: settings,
          onToast: (msg) => _toast(context, msg),
        ),
        _Section(
          title: 'DATA',
          children: [
            _SwitchTile(
              icon: Icons.notifications_none_rounded,
              title: '更新通知',
              subtitle: '有新文章时提醒',
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
              subtitle: '后台拉取节省流量',
              value: settings.wifiOnly,
              onChanged: (v) {
                controller.updateSettings(settings.copyWith(wifiOnly: v));
              },
            ),
            _NavTile(
              icon: Icons.cleaning_services_outlined,
              title: '清理缓存',
              subtitle: '图片与临时文件',
              onTap: () => _toast(context, '缓存已清理（模拟）'),
            ),
            _NavTile(
              icon: Icons.ios_share_rounded,
              title: '导出我的数据',
              subtitle: '收藏 / 对话 / 设置',
              onTap: () => _toast(context, '数据导出 · 占位'),
            ),
          ],
        ),
        _Section(
          title: '关于',
          children: [
            _NavTile(
              icon: Icons.system_update_alt_rounded,
              title: '检查更新',
              subtitle: '当前 1.0.0',
              onTap: () => _openUpdates(context),
            ),
            _NavTile(
              icon: Icons.description_outlined,
              title: '用户协议',
              subtitle: '使用条款',
              onTap: () => _openLegal(context, kind: _LegalKind.terms),
            ),
            _NavTile(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              subtitle: '本地优先说明',
              onTap: () => _openLegal(context, kind: _LegalKind.privacy),
            ),
            _NavTile(
              icon: Icons.info_outline_rounded,
              title: '关于 WEPSEED',
              subtitle: '本地优先的 RSS 阅读器',
              onTap: () => _openAbout(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'WEPSEED  ·  1.0.0',
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
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => '跟随系统',
        ThemeMode.light => '浅色',
        ThemeMode.dark => '深色',
      };

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

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
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text('$e'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
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
      _toast(context, '已添加订阅');
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
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text('已刷新'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text('$e'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
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
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text('$e'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
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
      _toast(context, 'OPML 导入完成');
    }
  }

  Future<void> _exportOpml(BuildContext context, WidgetRef ref) async {
    try {
      final xml = await ref.read(feedActionsProvider).exportOpml();
      await Clipboard.setData(ClipboardData(text: xml));
      if (context.mounted) _toast(context, 'OPML 已复制到剪贴板');
    } catch (e) {
      if (context.mounted) _toast(context, '$e');
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

  Future<void> _openUpdates(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SheetScaffold(
          title: '检查更新',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前版本 1.0.0',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '已是最新。后续会在这里显示更新日志与下载。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _PrimaryButton(
                label: '好的',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openLegal(
    BuildContext context, {
    required _LegalKind kind,
  }) async {
    final isTerms = kind == _LegalKind.terms;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SheetScaffold(
          title: isTerms ? '用户协议' : '隐私政策',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTerms
                    ? 'WEPSEED 是一款本地优先的 RSS 阅读工具。你对自己添加的订阅源、笔记与对话内容负责。请勿将本应用用于违法用途。本协议为产品原型占位文本，正式版将替换为完整条款。'
                    : '默认本地存储：订阅、收藏、对话与设置保存在本机。LLM 请求仅在你配置 API Key 后发往你指定的服务商。我们不运营账号体系，也不主动上传你的阅读数据。本政策为产品原型占位文本。',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.55),
              ),
              const SizedBox(height: 16),
              _PrimaryButton(
                label: '关闭',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAbout(BuildContext context) async {
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
                'Version 1.0.0',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
              const SizedBox(height: 18),
              _PrimaryButton(
                label: '关闭',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _LegalKind { terms, privacy }

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

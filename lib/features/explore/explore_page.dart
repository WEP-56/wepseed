import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../data/rsshub/radar_models.dart';
import '../../data/rsshub/radar_probe.dart';
import '../../providers/feed_providers.dart';
import '../../providers/radar_providers.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _paramControllers = <String, TextEditingController>{};
  final _customInstanceController = TextEditingController();
  final _searchController = TextEditingController();
  String? _probeMessage;
  bool? _probeOk;
  bool _probing = false;
  bool _adding = false;
  bool _hydratedControllers = false;

  @override
  void dispose() {
    for (final c in _paramControllers.values) {
      c.dispose();
    }
    _customInstanceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _ensureControllers(RadarDraft draft, RadarRoute? route) {
    final needed = route?.parameters.keys.toSet() ?? <String>{};
    for (final key in needed) {
      if (!_paramControllers.containsKey(key)) {
        final initial = draft.params[key] ??
            route?.parameters[key]?.defaultValue ??
            '';
        _paramControllers[key] = TextEditingController(text: initial);
      }
    }
    // Drop unused
    final stale = _paramControllers.keys
        .where((k) => !needed.contains(k))
        .toList(growable: false);
    for (final k in stale) {
      _paramControllers.remove(k)?.dispose();
    }
    if (!_hydratedControllers) {
      _customInstanceController.text = draft.customInstanceUrl;
      _searchController.text = draft.query;
      _hydratedControllers = true;
    }
  }

  String _instanceOrigin(RadarCatalog catalog, RadarDraft draft) {
    if (draft.instanceId == 'custom') {
      final u = draft.customInstanceUrl.trim().isEmpty
          ? _customInstanceController.text.trim()
          : draft.customInstanceUrl.trim();
      if (u.isEmpty) return '';
      final withScheme = u.startsWith('http') ? u : 'https://$u';
      return RadarInstance(
        id: 'custom',
        url: withScheme,
        label: '自定义',
      ).origin;
    }
    for (final ins in catalog.instances) {
      if (ins.id == draft.instanceId) return ins.origin;
    }
    return catalog.instances.isNotEmpty ? catalog.instances.first.origin : '';
  }

  RadarSource? _sourceOf(RadarCatalog catalog, String namespace) {
    for (final s in catalog.sources) {
      if (s.namespace == namespace) return s;
    }
    return null;
  }

  RadarRoute? _routeOf(RadarSource? source, String path) {
    if (source == null) return null;
    for (final r in source.routes) {
      if (r.path == path) return r;
    }
    return source.routes.isNotEmpty ? source.routes.first : null;
  }

  Map<String, String> _collectParams(RadarRoute? route) {
    if (route == null) return {};
    final map = <String, String>{};
    for (final key in route.parameters.keys) {
      map[key] = _paramControllers[key]?.text.trim() ?? '';
    }
    return map;
  }

  String? _builtUrl(RadarCatalog catalog, RadarDraft draft, RadarRoute? route) {
    if (route == null) return null;
    final origin = _instanceOrigin(catalog, draft);
    if (origin.isEmpty) return null;
    return buildRadarFeedUrl(
      instanceOrigin: origin,
      pathTemplate: route.path,
      params: _collectParams(route),
    );
  }

  Future<void> _persistDraftPatch(RadarDraft Function(RadarDraft) fn) async {
    ref.read(radarDraftProvider.notifier).update(fn);
  }

  Future<void> _onTest(String? url) async {
    if (url == null || url.isEmpty) {
      showAppToast('请先选择路由并填写参数', context: context);
      return;
    }
    setState(() {
      _probing = true;
      _probeMessage = null;
      _probeOk = null;
    });
    final result = await probeRadarUrl(url);
    if (!mounted) return;
    setState(() {
      _probing = false;
      _probeOk = result.ok;
      _probeMessage = result.message;
    });
    showAppToast(result.message, context: context);
  }

  Future<void> _onAdd(String? url) async {
    if (url == null || url.isEmpty) {
      showAppToast('请先选择路由并填写参数', context: context);
      return;
    }
    if (!radarPathIsComplete(Uri.tryParse(url)?.path ?? url)) {
      showAppToast('还有必填参数未填', context: context);
      return;
    }
    setState(() => _adding = true);
    try {
      await ref.read(feedActionsProvider).addFeed(url);
      await ref.read(radarDraftProvider.notifier).persistNow();
      if (!mounted) return;
      showAppToast('已添加订阅', context: context);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      showAppToast(msg, context: context);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final catalogAsync = ref.watch(radarCatalogProvider);
    final draft = ref.watch(radarDraftProvider);

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('雷达目录加载失败\n$e', textAlign: TextAlign.center),
        ),
      ),
      data: (catalog) {
        final filtered = _filterSources(catalog.sources, draft.query);
        var source = _sourceOf(catalog, draft.namespace);
        if (source == null && filtered.isNotEmpty) {
          source = filtered.first;
        }
        var route = _routeOf(source, draft.routePath);
        _ensureControllers(draft, route);

        // Keep draft namespace/route aligned when empty.
        final alignedSource = source;
        final alignedRoute = route;
        if (alignedSource != null && draft.namespace != alignedSource.namespace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final firstPath = alignedSource.routes.isNotEmpty
                ? alignedSource.routes.first.path
                : '';
            _persistDraftPatch(
              (d) => d.copyWith(
                namespace: alignedSource.namespace,
                routePath: firstPath,
                params: {},
              ),
            );
          });
        } else if (alignedSource != null &&
            alignedRoute != null &&
            draft.routePath != alignedRoute.path &&
            draft.routePath.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _persistDraftPatch(
              (d) => d.copyWith(routePath: alignedRoute.path),
            );
          });
        }

        final url = _builtUrl(catalog, draft, route);
        final secondary = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        final tertiary = isDark
            ? AppColors.textTertiaryDark
            : AppColors.textTertiaryLight;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, top + 10, 20, 120),
          children: [
            Text(
              'Explore',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'RSSHub 雷达 · 选实例 → 来源 → 填表订阅',
              style: theme.textTheme.bodyMedium?.copyWith(color: tertiary),
            ),
            const SizedBox(height: 18),

            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. 实例',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _instanceValue(catalog, draft),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: 'RSSHub 实例',
                    ),
                    items: [
                      ...catalog.instances.map(
                        (ins) => DropdownMenuItem(
                          value: ins.id,
                          child: Text(
                            '${ins.label}${ins.official ? ' · 官方' : ''}  ·  ${ins.url.replaceFirst(RegExp(r'https?://'), '')}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: 'custom',
                        child: Text('自定义…'),
                      ),
                    ],
                    onChanged: (id) {
                      if (id == null) return;
                      _persistDraftPatch((d) => d.copyWith(instanceId: id));
                      setState(() {
                        _probeMessage = null;
                        _probeOk = null;
                      });
                    },
                  ),
                  if (draft.instanceId == 'custom') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customInstanceController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        labelText: '自定义实例 URL',
                        hintText: 'https://rsshub.example.com',
                      ),
                      onChanged: (v) {
                        _persistDraftPatch(
                          (d) => d.copyWith(customInstanceUrl: v.trim()),
                        );
                      },
                    ),
                  ],
                  if (draft.instanceId != 'custom') ...[
                    const SizedBox(height: 8),
                    Text(
                      () {
                        for (final e in catalog.instances) {
                          if (e.id == draft.instanceId &&
                              e.notes != null &&
                              e.notes!.isNotEmpty) {
                            return e.notes!;
                          }
                        }
                        return '实例可用性会波动，可点「测试」验证。';
                      }(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),
            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. 内容来源',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      labelText: '搜索来源',
                      hintText: 'bilibili / telegram / 少数派…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: draft.query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _persistDraftPatch((d) => d.copyWith(query: ''));
                              },
                            ),
                    ),
                    onChanged: (v) {
                      _persistDraftPatch((d) => d.copyWith(query: v.trim()));
                    },
                  ),
                  const SizedBox(height: 10),
                  if (filtered.isEmpty)
                    Text(
                      '没有匹配的来源',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondary,
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: source?.namespace,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        labelText: '来源',
                      ),
                      items: filtered
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.namespace,
                              child: Text(
                                '${s.name}  (${s.namespace})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (ns) {
                        if (ns == null) return;
                        final s = _sourceOf(catalog, ns);
                        final first = s?.routes.isNotEmpty == true
                            ? s!.routes.first.path
                            : '';
                        for (final c in _paramControllers.values) {
                          c.dispose();
                        }
                        _paramControllers.clear();
                        _persistDraftPatch(
                          (d) => d.copyWith(
                            namespace: ns,
                            routePath: first,
                            params: {},
                          ),
                        );
                        setState(() {
                          _probeMessage = null;
                          _probeOk = null;
                        });
                      },
                    ),
                  if (source?.blurb != null && source!.blurb!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      source.blurb!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),
            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3. 路由与参数',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (source == null || source.routes.isEmpty)
                    Text(
                      '请选择来源',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondary,
                      ),
                    )
                  else ...[
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: route?.path,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        labelText: '路由',
                      ),
                      items: source.routes
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.path,
                              child: Text(
                                '${r.name}  ·  ${r.path}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (path) {
                        if (path == null) return;
                        for (final c in _paramControllers.values) {
                          c.dispose();
                        }
                        _paramControllers.clear();
                        final r = _routeOf(source, path);
                        final defaults = <String, String>{};
                        r?.parameters.forEach((k, v) {
                          if (v.defaultValue != null) {
                            defaults[k] = v.defaultValue!;
                          }
                        });
                        _persistDraftPatch(
                          (d) => d.copyWith(routePath: path, params: defaults),
                        );
                        setState(() {
                          _probeMessage = null;
                          _probeOk = null;
                        });
                      },
                    ),
                    if (route != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (route.requireConfig)
                            _Chip(
                              label: '可能需实例配置',
                              color: Colors.orange.shade700,
                            ),
                          if (route.antiCrawler)
                            _Chip(
                              label: '反爬较强',
                              color: Colors.red.shade700,
                            ),
                          if (route.example != null)
                            _Chip(
                              label: '例 ${route.example}',
                              color: secondary,
                            ),
                        ],
                      ),
                      if (route.parameters.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            '此路由无需参数',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondary,
                            ),
                          ),
                        )
                      else
                        ...route.parameters.entries.map((e) {
                          final key = e.key;
                          final spec = e.value;
                          final controller = _paramControllers[key]!;
                          final options = spec.options;
                          if (options != null && options.isNotEmpty) {
                            final values = options.map((o) => o.value).toSet();
                            final current = controller.text;
                            final value = values.contains(current)
                                ? current
                                : (spec.defaultValue ?? options.first.value);
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: DropdownButtonFormField<String>(
                                // ignore: deprecated_member_use
                                value: value,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  labelText: key + (spec.required ? ' *' : ''),
                                  helperText: spec.description.isEmpty
                                      ? null
                                      : spec.description,
                                ),
                                items: options
                                    .map(
                                      (o) => DropdownMenuItem(
                                        value: o.value,
                                        child: Text(
                                          o.label.isEmpty ? o.value : o.label,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  controller.text = v;
                                  final next = Map<String, String>.from(
                                    draft.params,
                                  )..[key] = v;
                                  _persistDraftPatch(
                                    (d) => d.copyWith(params: next),
                                  );
                                },
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                isDense: true,
                                labelText: key + (spec.required ? ' *' : ''),
                                helperText: spec.description.isEmpty
                                    ? null
                                    : spec.description,
                                hintText: spec.defaultValue,
                              ),
                              onChanged: (v) {
                                final next = Map<String, String>.from(
                                  draft.params,
                                )..[key] = v.trim();
                                _persistDraftPatch(
                                  (d) => d.copyWith(params: next),
                                );
                              },
                            ),
                          );
                        }),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),
            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '订阅地址',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    url ?? '—',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.35,
                      color: secondary,
                    ),
                  ),
                  if (_probeMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _probeMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _probeOk == true
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _probing || _adding
                              ? null
                              : () => _onTest(url),
                          icon: _probing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.wifi_tethering_rounded),
                          label: const Text('测试'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _probing || _adding
                              ? null
                              : () => _onAdd(url),
                          icon: _adding
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_rounded),
                          label: const Text('添加订阅'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: url == null || url.isEmpty
                            ? null
                            : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: url),
                                );
                                if (!context.mounted) return;
                                showAppToast('已复制 URL', context: context);
                              },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('复制'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await ref.read(radarDraftProvider.notifier).clear();
                          for (final c in _paramControllers.values) {
                            c.dispose();
                          }
                          _paramControllers.clear();
                          _customInstanceController.clear();
                          _searchController.clear();
                          setState(() {
                            _probeMessage = null;
                            _probeOk = null;
                            _hydratedControllers = false;
                          });
                          showAppToast('草稿已清空', context: context);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('清空草稿'),
                      ),
                    ],
                  ),
                  Text(
                    '表单会自动保存草稿，杀进程后仍在。',
                    style: theme.textTheme.bodySmall?.copyWith(color: tertiary),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _instanceValue(RadarCatalog catalog, RadarDraft draft) {
    if (draft.instanceId == 'custom') return 'custom';
    for (final ins in catalog.instances) {
      if (ins.id == draft.instanceId) return ins.id;
    }
    return catalog.instances.isNotEmpty
        ? catalog.instances.first.id
        : 'custom';
  }

  List<RadarSource> _filterSources(List<RadarSource> sources, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sources;
    return sources.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.namespace.toLowerCase().contains(q) ||
          (s.blurb?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181818) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, height: 1.2),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../data/rsshub/radar_models.dart';
import '../../data/rsshub/radar_probe.dart';
import '../../providers/feed_providers.dart';
import '../../providers/radar_providers.dart';

/// Horizontal guided radar: 实例 → 来源 → 参数 → 完成.
/// Pickers use bottom sheets (same language as Set), not dropdown menus.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  static const _steps = ['实例', '来源', '参数', '完成'];

  int _step = 0;
  final _paramControllers = <String, TextEditingController>{};
  final _customInstanceController = TextEditingController();
  final _searchController = TextEditingController();
  String? _probeMessage;
  bool? _probeOk;
  bool _probing = false;
  bool _adding = false;
  bool _hydrated = false;

  @override
  void dispose() {
    for (final c in _paramControllers.values) {
      c.dispose();
    }
    _customInstanceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _hydrate(RadarDraft draft) {
    if (_hydrated) return;
    _customInstanceController.text = draft.customInstanceUrl;
    _searchController.text = draft.query;
    _hydrated = true;
  }

  void _syncParamControllers(RadarDraft draft, RadarRoute? route) {
    final needed = route?.parameters.keys.toSet() ?? <String>{};
    for (final key in needed) {
      if (!_paramControllers.containsKey(key)) {
        final initial =
            draft.params[key] ?? route?.parameters[key]?.defaultValue ?? '';
        _paramControllers[key] = TextEditingController(text: initial);
      }
    }
    for (final key in _paramControllers.keys.toList(growable: false)) {
      if (!needed.contains(key)) {
        _paramControllers.remove(key)?.dispose();
      }
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

  RadarInstance? _instanceOf(RadarCatalog catalog, String id) {
    for (final ins in catalog.instances) {
      if (ins.id == id) return ins;
    }
    return null;
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
    return null;
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

  void _patch(RadarDraft Function(RadarDraft) fn) {
    ref.read(radarDraftProvider.notifier).update(fn);
  }

  bool _canAdvance(RadarCatalog catalog, RadarDraft draft, RadarRoute? route) {
    switch (_step) {
      case 0:
        if (draft.instanceId == 'custom') {
          return _instanceOrigin(catalog, draft).isNotEmpty;
        }
        return draft.instanceId.isNotEmpty;
      case 1:
        return draft.namespace.isNotEmpty &&
            _sourceOf(catalog, draft.namespace) != null;
      case 2:
        if (route == null) return false;
        final path = buildRadarFeedPath(route.path, _collectParams(route));
        return radarPathIsComplete(path);
      default:
        return true;
    }
  }

  Future<void> _onTest(String? url) async {
    if (url == null || url.isEmpty) {
      showAppToast('请先完成前面步骤', context: context);
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
      showAppToast('请先完成前面步骤', context: context);
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
      showAppToast(
        e.toString().replaceFirst('Exception: ', ''),
        context: context,
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _pickInstance(RadarCatalog catalog, RadarDraft draft) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ExploreSheet(
          title: '选择实例',
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final ins in catalog.instances)
                  _SheetTile(
                    title: ins.label + (ins.official ? ' · 官方' : ''),
                    subtitle: ins.url.replaceFirst(RegExp(r'https?://'), ''),
                    selected: draft.instanceId == ins.id,
                    onTap: () => Navigator.pop(ctx, ins.id),
                  ),
                _SheetTile(
                  title: '自定义…',
                  subtitle: '填写自建或其它镜像地址',
                  selected: draft.instanceId == 'custom',
                  onTap: () => Navigator.pop(ctx, 'custom'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    HapticFeedback.selectionClick();
    _patch((d) => d.copyWith(instanceId: selected));
    setState(() {
      _probeMessage = null;
      _probeOk = null;
    });
  }

  Future<void> _pickSource(RadarCatalog catalog, RadarDraft draft) async {
    final searchCtrl = TextEditingController(text: draft.query);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        var query = draft.query;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final filtered = _filterSources(catalog.sources, query);
            return _ExploreSheet(
              title: '选择来源',
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.75,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '搜索 bilibili / telegram / 少数派…',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        query = v.trim();
                        _searchController.text = v;
                        _patch((d) => d.copyWith(query: query));
                        setModal(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final s = filtered[i];
                          return _SheetTile(
                            title: s.name,
                            subtitle: s.namespace +
                                (s.blurb == null || s.blurb!.isEmpty
                                    ? ''
                                    : ' · ${s.blurb}'),
                            selected: draft.namespace == s.namespace,
                            onTap: () => Navigator.pop(ctx, s.namespace),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    searchCtrl.dispose();
    if (selected == null || !mounted) return;
    HapticFeedback.selectionClick();
    final source = _sourceOf(catalog, selected);
    final firstPath =
        source != null && source.routes.isNotEmpty ? source.routes.first.path : '';
    for (final c in _paramControllers.values) {
      c.dispose();
    }
    _paramControllers.clear();
    _patch(
      (d) => d.copyWith(
        namespace: selected,
        routePath: firstPath,
        params: {},
      ),
    );
    setState(() {
      _probeMessage = null;
      _probeOk = null;
    });
  }

  Future<void> _pickRoute(
    RadarSource source,
    RadarDraft draft,
    RadarRoute? current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ExploreSheet(
          title: '选择路由',
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final r in source.routes)
                  _SheetTile(
                    title: r.name,
                    subtitle: r.path +
                        (r.requireConfig ? ' · 可能需配置' : '') +
                        (r.antiCrawler ? ' · 反爬' : ''),
                    selected: current?.path == r.path,
                    onTap: () => Navigator.pop(ctx, r.path),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    HapticFeedback.selectionClick();
    for (final c in _paramControllers.values) {
      c.dispose();
    }
    _paramControllers.clear();
    final route = _routeOf(source, selected);
    final defaults = <String, String>{};
    route?.parameters.forEach((k, v) {
      if (v.defaultValue != null) defaults[k] = v.defaultValue!;
    });
    _patch((d) => d.copyWith(routePath: selected, params: defaults));
    setState(() {
      _probeMessage = null;
      _probeOk = null;
    });
  }

  List<RadarSource> _filterSources(List<RadarSource> sources, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sources;
    return sources
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.namespace.toLowerCase().contains(q) ||
              (s.blurb?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final catalogAsync = ref.watch(radarCatalogProvider);
    final draft = ref.watch(radarDraftProvider);
    final tertiary =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('雷达目录加载失败\n$e')),
      data: (catalog) {
        _hydrate(draft);
        final source = _sourceOf(catalog, draft.namespace);
        final route = _routeOf(source, draft.routePath) ??
            (source != null && source.routes.isNotEmpty
                ? source.routes.first
                : null);
        _syncParamControllers(draft, route);
        final url = _builtUrl(catalog, draft, route);
        final instance = _instanceOf(catalog, draft.instanceId);
        final canNext = _canAdvance(catalog, draft, route);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    'RSSHub 雷达 · 一步一步订阅',
                    style: theme.textTheme.bodyMedium?.copyWith(color: tertiary),
                  ),
                  const SizedBox(height: 16),
                  _StepRail(
                    labels: _steps,
                    current: _step,
                    onTap: (i) {
                      // Only allow jumping back, or forward if prior steps ok.
                      if (i <= _step) {
                        setState(() => _step = i);
                        return;
                      }
                      if (i == _step + 1 && canNext) {
                        setState(() => _step = i);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: KeyedSubtree(
                      key: ValueKey<int>(_step),
                      child: switch (_step) {
                        0 => _stepInstance(
                          theme,
                          isDark,
                          secondary,
                          tertiary,
                          catalog,
                          draft,
                          instance,
                        ),
                        1 => _stepSource(
                          theme,
                          isDark,
                          secondary,
                          tertiary,
                          catalog,
                          draft,
                          source,
                        ),
                        2 => _stepParams(
                          theme,
                          isDark,
                          secondary,
                          tertiary,
                          draft,
                          source,
                          route,
                        ),
                        _ => _stepDone(
                          theme,
                          isDark,
                          secondary,
                          tertiary,
                          url,
                          draft,
                          source,
                          route,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
            _BottomBar(
              isDark: isDark,
              step: _step,
              total: _steps.length,
              canNext: canNext,
              busy: _probing || _adding,
              onBack: _step == 0
                  ? null
                  : () => setState(() => _step -= 1),
              onNext: _step >= _steps.length - 1
                  ? null
                  : (canNext
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() => _step += 1);
                        }
                      : null),
              nextLabel: _step == 2 ? '生成地址' : '下一步',
            ),
          ],
        );
      },
    );
  }

  Widget _stepInstance(
    ThemeData theme,
    bool isDark,
    Color secondary,
    Color tertiary,
    RadarCatalog catalog,
    RadarDraft draft,
    RadarInstance? instance,
  ) {
    return Column(
      key: const ValueKey('s0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选一个 RSSHub 实例',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '公网镜像会波动；测不通就换一个。也可自定义地址。',
          style: theme.textTheme.bodySmall?.copyWith(color: tertiary),
        ),
        const SizedBox(height: 14),
        _PickerTile(
          isDark: isDark,
          icon: Icons.dns_outlined,
          label: '当前实例',
          value: draft.instanceId == 'custom'
              ? (draft.customInstanceUrl.isEmpty
                  ? '自定义（未填写）'
                  : draft.customInstanceUrl)
              : (instance?.label ?? draft.instanceId),
          hint: instance?.url.replaceFirst(RegExp(r'https?://'), ''),
          onTap: () => _pickInstance(catalog, draft),
        ),
        if (draft.instanceId == 'custom') ...[
          const SizedBox(height: 12),
          TextField(
            controller: _customInstanceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              labelText: '自定义 URL',
              hintText: 'https://rsshub.example.com',
            ),
            onChanged: (v) =>
                _patch((d) => d.copyWith(customInstanceUrl: v.trim())),
          ),
        ],
        if (instance?.notes != null && instance!.notes!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            instance.notes!,
            style: theme.textTheme.bodySmall?.copyWith(color: secondary),
          ),
        ],
      ],
    );
  }

  Widget _stepSource(
    ThemeData theme,
    bool isDark,
    Color secondary,
    Color tertiary,
    RadarCatalog catalog,
    RadarDraft draft,
    RadarSource? source,
  ) {
    return Column(
      key: const ValueKey('s1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选内容来源',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '精选热门站点；完整列表仍可在添加订阅里粘贴任意 URL。',
          style: theme.textTheme.bodySmall?.copyWith(color: tertiary),
        ),
        const SizedBox(height: 14),
        _PickerTile(
          isDark: isDark,
          icon: Icons.apps_rounded,
          label: '来源',
          value: source?.name ?? '尚未选择',
          hint: source?.namespace,
          onTap: () => _pickSource(catalog, draft),
        ),
        if (source?.blurb != null && source!.blurb!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            source.blurb!,
            style: theme.textTheme.bodySmall?.copyWith(color: secondary),
          ),
        ],
      ],
    );
  }

  Widget _stepParams(
    ThemeData theme,
    bool isDark,
    Color secondary,
    Color tertiary,
    RadarDraft draft,
    RadarSource? source,
    RadarRoute? route,
  ) {
    if (source == null) {
      return Text(
        '请先选择来源',
        style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
      );
    }
    return Column(
      key: const ValueKey('s2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选路由并填写参数',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '同一来源下有多种订阅方式，例如 UP 投稿 / 动态。',
          style: theme.textTheme.bodySmall?.copyWith(color: tertiary),
        ),
        const SizedBox(height: 14),
        _PickerTile(
          isDark: isDark,
          icon: Icons.route_outlined,
          label: '路由',
          value: route?.name ?? '尚未选择',
          hint: route?.path,
          onTap: () => _pickRoute(source, draft, route),
        ),
        if (route != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (route.requireConfig)
                _SoftChip(label: '可能需实例配置', tone: Colors.orange.shade800),
              if (route.antiCrawler)
                _SoftChip(label: '反爬较强', tone: Colors.red.shade800),
              if (route.example != null)
                _SoftChip(label: '例 ${route.example}', tone: secondary),
            ],
          ),
          if (route.parameters.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                '此路由无需参数，可直接下一步。',
                style: theme.textTheme.bodySmall?.copyWith(color: secondary),
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
                  padding: const EdgeInsets.only(top: 12),
                  child: _PickerTile(
                    isDark: isDark,
                    icon: Icons.tune_rounded,
                    label: key + (spec.required ? ' *' : ''),
                    value: options
                        .firstWhere(
                          (o) => o.value == value,
                          orElse: () => options.first,
                        )
                        .label,
                    hint: spec.description.isEmpty ? null : spec.description,
                    onTap: () async {
                      final picked = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => _ExploreSheet(
                          title: key,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final o in options)
                                _SheetTile(
                                  title: o.label.isEmpty ? o.value : o.label,
                                  subtitle: o.value,
                                  selected: o.value == value,
                                  onTap: () => Navigator.pop(ctx, o.value),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (picked == null) return;
                      controller.text = picked;
                      final next = Map<String, String>.from(draft.params)
                        ..[key] = picked;
                      _patch((d) => d.copyWith(params: next));
                      setState(() {});
                    },
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    labelText: key + (spec.required ? ' *' : ''),
                    helperText:
                        spec.description.isEmpty ? null : spec.description,
                    hintText: spec.defaultValue,
                  ),
                  onChanged: (v) {
                    final next = Map<String, String>.from(draft.params)
                      ..[key] = v.trim();
                    _patch((d) => d.copyWith(params: next));
                  },
                ),
              );
            }),
        ],
      ],
    );
  }

  Widget _stepDone(
    ThemeData theme,
    bool isDark,
    Color secondary,
    Color tertiary,
    String? url,
    RadarDraft draft,
    RadarSource? source,
    RadarRoute? route,
  ) {
    return Column(
      key: const ValueKey('s3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '确认并订阅',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '可先测试连通，再添加。草稿会自动保存。',
          style: theme.textTheme.bodySmall?.copyWith(color: tertiary),
        ),
        const SizedBox(height: 14),
        _SummaryCard(
          isDark: isDark,
          lines: [
            ('实例', draft.instanceId == 'custom'
                ? draft.customInstanceUrl
                : draft.instanceId),
            ('来源', source?.name ?? '—'),
            ('路由', route?.name ?? '—'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.inkCard : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: SelectableText(
            url ?? '—',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.35,
              color: secondary,
            ),
          ),
        ),
        if (_probeMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _probeMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _probeOk == true
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _probing || _adding ? null : () => _onTest(url),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _probing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('测试'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _probing || _adding ? null : () => _onAdd(url),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: isDark ? AppColors.white : AppColors.black,
                  foregroundColor: isDark ? AppColors.black : AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _adding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ),
                      )
                    : const Text('添加订阅'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: url == null || url.isEmpty
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (!mounted) return;
                      showAppToast('已复制 URL', context: context);
                    },
              child: const Text('复制链接'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(radarDraftProvider.notifier).clear();
                for (final c in _paramControllers.values) {
                  c.dispose();
                }
                _paramControllers.clear();
                _customInstanceController.clear();
                _searchController.clear();
                setState(() {
                  _step = 0;
                  _probeMessage = null;
                  _probeOk = null;
                  _hydrated = false;
                });
                showAppToast('草稿已清空', context: context);
              },
              child: const Text('清空草稿'),
            ),
          ],
        ),
      ],
    );
  }
}

// —— chrome matching Set / New ——

class _StepRail extends StatelessWidget {
  const _StepRail({
    required this.labels,
    required this.current,
    required this.onTap,
  });

  final List<String> labels;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final active = isDark ? AppColors.white : AppColors.black;
    final idle =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: i <= current
                    ? active.withValues(alpha: 0.35)
                    : idle.withValues(alpha: 0.25),
              ),
            ),
          GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= current
                        ? active
                        : Colors.transparent,
                    border: Border.all(
                      color: i <= current ? active : idle,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i <= current
                          ? (isDark ? AppColors.black : AppColors.white)
                          : idle,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: i == current ? active : idle,
                    fontWeight:
                        i == current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.hint,
  });

  final bool isDark;
  final IconData icon;
  final String label;
  final String value;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isDark ? AppColors.inkCard : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(value, style: theme.textTheme.titleSmall),
                    if (hint != null && hint!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        hint!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isDark,
    required this.step,
    required this.total,
    required this.canNext,
    required this.busy,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  final bool isDark;
  final int step;
  final int total;
  final bool canNext;
  final bool busy;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottom + 72),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.ink : AppColors.canvas).withValues(
          alpha: 0.92,
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (onBack != null)
            OutlinedButton(
              onPressed: busy ? null : onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(88, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('上一步'),
            )
          else
            const SizedBox(width: 88),
          const Spacer(),
          if (onNext != null)
            FilledButton(
              onPressed: busy || !canNext ? null : onNext,
              style: FilledButton.styleFrom(
                minimumSize: const Size(120, 44),
                backgroundColor: isDark ? AppColors.white : AppColors.black,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                disabledBackgroundColor:
                    (isDark ? AppColors.white : AppColors.black).withValues(
                  alpha: 0.2,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(nextLabel),
            )
          else
            Text(
              '${step + 1} / $total',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
        ],
      ),
    );
  }
}

class _ExploreSheet extends StatelessWidget {
  const _ExploreSheet({required this.title, required this.child});

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
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
      ),
      trailing: selected
          ? Icon(
              Icons.check_rounded,
              size: 20,
              color: isDark ? AppColors.white : AppColors.black,
            )
          : null,
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: tone, height: 1.2),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.isDark, required this.lines});

  final bool isDark;
  final List<(String, String)> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inkCard : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    lines[i].$1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    lines[i].$2.isEmpty ? '—' : lines[i].$2,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

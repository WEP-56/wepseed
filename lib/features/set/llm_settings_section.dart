import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/monogram.dart';
import '../../data/models/models.dart';
import '../../providers/comment_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/llm_providers.dart';
import '../../providers/netizen_providers.dart';
import '../../providers/settings_provider.dart';

/// LLM block for Set page: trigger + providers + netizens.
class LlmSettingsSection extends ConsumerWidget {
  const LlmSettingsSection({
    super.key,
    required this.settings,
    required this.onToast,
  });

  final AppSettings settings;
  final void Function(String) onToast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(llmProvidersListProvider).value ?? const [];
    final netizens = ref.watch(netizensProvider).value ?? const [];
    final controller = ref.read(settingsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'LLM',
          children: [
            _NavTile(
              icon: Icons.forum_outlined,
              title: '评论触发',
              subtitle: _triggerLabel(settings.commentTrigger),
              onTap: () => _openTrigger(context, controller, settings),
            ),
            _NavTile(
              icon: Icons.dns_outlined,
              title: '提供商',
              subtitle: providers.isEmpty
                  ? '未配置'
                  : '${providers.length} 个 · 点进管理',
              onTap: () => _openProviders(context, ref),
            ),
            _NavTile(
              icon: Icons.groups_outlined,
              title: '网友',
              subtitle: netizens.isEmpty
                  ? '未配置'
                  : '${netizens.where((n) => n.isEnabled).length} 位启用 · 点进管理',
              onTap: () => _openNetizens(context, ref),
            ),
            _NavTile(
              icon: Icons.delete_sweep_outlined,
              title: '清除全部评论',
              subtitle: '删掉本地评论（含旧 mock），下次打开可重新生成',
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('清除全部评论？'),
                    content: const Text(
                      '会删除本机所有文章下的评论记录，不可恢复。配置的提供商 / 网友不受影响。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('清除'),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;
                await ref.read(commentControllerProvider).clearAllComments();
                onToast('评论已清空');
              },
            ),
          ],
        ),
      ],
    );
  }

  String _triggerLabel(CommentTrigger t) => switch (t) {
    CommentTrigger.off => '关闭',
    CommentTrigger.onBrowse => '浏览文章时生成',
    CommentTrigger.onOpenComments => '展开评论时生成',
  };

  Future<void> _openTrigger(
    BuildContext context,
    SettingsController controller,
    AppSettings settings,
  ) async {
    final selected = await showModalBottomSheet<CommentTrigger>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _Sheet(
          title: '评论触发',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in CommentTrigger.values)
                ListTile(
                  title: Text(_triggerLabel(t)),
                  trailing: settings.commentTrigger == t
                      ? const Icon(Icons.check_rounded, size: 20)
                      : null,
                  onTap: () => Navigator.pop(context, t),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await controller.updateSettings(
        settings.copyWith(commentTrigger: selected),
      );
    }
  }

  Future<void> _openProviders(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ProvidersSheet(),
    );
  }

  Future<void> _openNetizens(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NetizensSheet(),
    );
  }
}

// ── Providers sheet ──────────────────────────────────────────────

class _ProvidersSheet extends ConsumerWidget {
  const _ProvidersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(llmProvidersListProvider).value ?? const [];
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: _Sheet(
        title: '提供商',
        child: SizedBox(
          height: media.size.height * 0.62,
          child: Column(
            children: [
              Expanded(
                child: providers.isEmpty
                    ? const Center(child: Text('还没有提供商，点下方添加'))
                    : ListView.separated(
                        itemCount: providers.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final p = providers[i];
                          final hasKey =
                              ref.watch(providerHasKeyProvider(p.id)).value ??
                              false;
                          final models =
                              ref
                                  .watch(llmModelsForProviderProvider(p.id))
                                  .value ??
                              const [];
                          return ListTile(
                            title: Text(p.name),
                            subtitle: Text(
                              '${llmProtocolLabel(p.protocol)} · '
                              '${models.length} 模型 · '
                              '并发 ${p.maxConcurrent} · '
                              '${p.requestsPerMinute} RPM · '
                              '${hasKey ? "Key 已设" : "无 Key"}'
                              '${p.isEnabled ? "" : " · 停用"}',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _editProvider(context, ref, p),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              _PrimaryButton(
                label: '添加提供商',
                onTap: () => _editProvider(context, ref, null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProvider(
    BuildContext context,
    WidgetRef ref,
    LlmProvider? existing,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProviderEditorSheet(existing: existing),
    );
  }
}

class _ProviderEditorSheet extends ConsumerStatefulWidget {
  const _ProviderEditorSheet({this.existing});

  final LlmProvider? existing;

  @override
  ConsumerState<_ProviderEditorSheet> createState() =>
      _ProviderEditorSheetState();
}

class _ProviderEditorSheetState extends ConsumerState<_ProviderEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _baseUrl;
  late final TextEditingController _apiKey;
  late final TextEditingController _rpm;
  late LlmProtocol _protocol;
  late bool _enabled;
  late int _maxConcurrent;
  late final String _id;
  bool _savingModel = false;
  String? _inlineHint;

  /// After a successful write, pin the list from getModels so UI updates even
  /// if the StreamProvider is slow / cached empty.
  List<LlmModel>? _modelsPinned;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _id = e?.id ?? 'p_${DateTime.now().microsecondsSinceEpoch}';
    _name = TextEditingController(text: e?.name ?? '');
    _baseUrl = TextEditingController(
      text: e?.baseUrl ?? 'https://api.openai.com/v1',
    );
    _apiKey = TextEditingController();
    _rpm = TextEditingController(text: '${e?.requestsPerMinute ?? 10}');
    _protocol = e?.protocol ?? LlmProtocol.openaiChatCompletions;
    _enabled = e?.isEnabled ?? true;
    _maxConcurrent = e?.maxConcurrent ?? 1;
  }

  @override
  void dispose() {
    _name.dispose();
    _baseUrl.dispose();
    _apiKey.dispose();
    _rpm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamed =
        ref.watch(llmModelsForProviderProvider(_id)).value ??
        const <LlmModel>[];
    final models = _modelsPinned ?? streamed;
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: _Sheet(
        title: widget.existing == null ? '添加提供商' : '编辑提供商',
        child: SizedBox(
          height: media.size.height * 0.72,
          child: ListView(
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<LlmProtocol>(
                // ignore: deprecated_member_use
                value: _protocol,
                decoration: const InputDecoration(labelText: '协议'),
                items: [
                  for (final p in LlmProtocol.values)
                    DropdownMenuItem(
                      value: p,
                      child: Text(llmProtocolLabel(p)),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _protocol = v);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _baseUrl,
                decoration: const InputDecoration(labelText: 'Base URL'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _apiKey,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.existing == null
                      ? 'API Key'
                      : 'API Key（留空则不改）',
                  hintText: 'sk-... / 密钥',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      // ignore: deprecated_member_use
                      value: _maxConcurrent,
                      decoration: const InputDecoration(labelText: '并发请求'),
                      items: [
                        for (var value = 1; value <= 4; value++)
                          DropdownMenuItem(value: value, child: Text('$value')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _maxConcurrent = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _rpm,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'RPM 上限',
                        hintText: '10',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '同一提供商的所有网友共用此额度；默认并发 1，评论会依次出现。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('启用'),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
              const SizedBox(height: 8),
              Text(
                '模型（${models.length}）',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (_inlineHint != null) ...[
                const SizedBox(height: 6),
                Text(
                  _inlineHint!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              if (models.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '还没有模型。点下方添加（会自动先保存本提供商）。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              for (final m in models)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.displayName),
                  subtitle: Text(m.modelId),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (m.isDefault)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text('默认', style: TextStyle(fontSize: 12)),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => ref
                            .read(llmConfigControllerProvider)
                            .deleteModel(m.id),
                      ),
                    ],
                  ),
                  onTap: () => _editModel(m),
                ),
              TextButton.icon(
                onPressed: _savingModel ? null : () => _editModel(null),
                icon: _savingModel
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add, size: 18),
                label: Text(_savingModel ? '保存中…' : '添加模型'),
              ),
              const SizedBox(height: 12),
              _PrimaryButton(label: '保存', onTap: _save),
              if (widget.existing != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(llmConfigControllerProvider)
                        .deleteProvider(_id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    '删除提供商',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editModel(LlmModel? existing) async {
    // Dialog (not nested bottom sheet) — pop result is reliable.
    final result = await showDialog<_ModelEditResult>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => _ModelEditorDialog(existing: existing),
    );
    if (result == null || !mounted) return;
    if (result.modelId.isEmpty) {
      setState(() => _inlineHint = '请填写 Model ID');
      return;
    }

    setState(() {
      _savingModel = true;
      _inlineHint = '正在保存…';
    });
    try {
      // FK: llm_models.providerId → llm_providers.id — provider row first.
      await _persistProvider(popAfter: false);
      if (!mounted) return;

      final model = LlmModel(
        id: existing?.id ?? 'm_${DateTime.now().microsecondsSinceEpoch}',
        providerId: _id,
        modelId: result.modelId,
        displayName: result.displayName.isEmpty
            ? result.modelId
            : result.displayName,
        isDefault: result.isDefault,
        sortOrder: existing?.sortOrder ?? 0,
      );
      await ref.read(llmConfigControllerProvider).upsertModel(model);

      // Verify row landed (surface FK / SQLite failures clearly).
      final listed = await ref
          .read(llmProviderRepositoryProvider)
          .getModels(_id);
      final found = listed.any((m) => m.id == model.id);
      if (!found) {
        throw StateError('写入后查询不到该模型（providerId=$_id）');
      }

      if (mounted) {
        ref.invalidate(llmModelsForProviderProvider(_id));
        setState(() {
          _modelsPinned = listed;
          _inlineHint = existing == null
              ? '已添加：${model.displayName}'
              : '已更新：${model.displayName}';
        });
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('upsertModel failed: $e\n$st');
      if (mounted) {
        setState(() => _inlineHint = '保存失败：$e');
      }
    } finally {
      if (mounted) setState(() => _savingModel = false);
    }
  }

  void _toast(String msg) {
    // Prefer root messenger — sheet-local SnackBars often hide under the modal.
    final root = ScaffoldMessenger.maybeOf(context);
    root?.showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  /// Persist provider row (+ optional key). Used by Save and before model insert.
  Future<void> _persistProvider({required bool popAfter}) async {
    final name = _name.text.trim().isEmpty ? '未命名提供商' : _name.text.trim();
    final base = _baseUrl.text.trim().isEmpty
        ? 'https://api.openai.com/v1'
        : _baseUrl.text.trim();
    final key = _apiKey.text.trim();
    final rpm = (int.tryParse(_rpm.text.trim()) ?? 10).clamp(1, 1000);
    await ref
        .read(llmConfigControllerProvider)
        .upsertProvider(
          LlmProvider(
            id: _id,
            name: name,
            protocol: _protocol,
            baseUrl: base,
            isEnabled: _enabled,
            maxConcurrent: _maxConcurrent,
            requestsPerMinute: rpm,
            sortOrder: widget.existing?.sortOrder ?? 0,
            createdAt: widget.existing?.createdAt ?? DateTime.now(),
          ),
          apiKey: key.isEmpty ? null : key,
        );
    if (popAfter && mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    try {
      await _persistProvider(popAfter: true);
    } catch (e) {
      if (mounted) _toast('保存失败：$e');
    }
  }
}

// ── Model editor dialog (owns controllers; reliable pop result) ──

class _ModelEditResult {
  const _ModelEditResult({
    required this.modelId,
    required this.displayName,
    required this.isDefault,
  });

  final String modelId;
  final String displayName;
  final bool isDefault;
}

class _ModelEditorDialog extends StatefulWidget {
  const _ModelEditorDialog({this.existing});

  final LlmModel? existing;

  @override
  State<_ModelEditorDialog> createState() => _ModelEditorDialogState();
}

class _ModelEditorDialogState extends State<_ModelEditorDialog> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _nameCtrl;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _idCtrl = TextEditingController(text: e?.modelId ?? '');
    _nameCtrl = TextEditingController(text: e?.displayName ?? '');
    _isDefault = e?.isDefault ?? (e == null);
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _ModelEditResult(
        modelId: _idCtrl.text.trim(),
        displayName: _nameCtrl.text.trim(),
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? '添加模型' : '编辑模型'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _idCtrl,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Model ID',
                hintText: 'gpt-4o-mini / claude-...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: '显示名（可空，默认用 ID）'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('设为默认', style: theme.textTheme.bodyMedium),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
    );
  }
}

// ── Netizens sheet ───────────────────────────────────────────────

class _NetizensSheet extends ConsumerWidget {
  const _NetizensSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netizens = ref.watch(netizensProvider).value ?? const [];
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: _Sheet(
        title: '网友',
        child: SizedBox(
          height: media.size.height * 0.62,
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: netizens.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final n = netizens[i];
                    return ListTile(
                      leading: _NetizenAvatar(netizen: n, size: 36),
                      title: Text(n.name),
                      subtitle: Text(
                        '${n.styleLabel ?? "—"} · 权重 ${(n.weight * 100).round()}%'
                        '${n.isEnabled ? "" : " · 停用"}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _NetizenEditorSheet(existing: n),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _PrimaryButton(
                label: '添加网友',
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const _NetizenEditorSheet(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetizenEditorSheet extends ConsumerStatefulWidget {
  const _NetizenEditorSheet({this.existing});

  final Netizen? existing;

  @override
  ConsumerState<_NetizenEditorSheet> createState() =>
      _NetizenEditorSheetState();
}

class _NetizenEditorSheetState extends ConsumerState<_NetizenEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _style;
  late final TextEditingController _hint;
  late double _weight;
  late bool _enabled;
  late final String _id;
  String? _avatarPath;
  String? _providerId;
  String? _modelId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _id = e?.id ?? 'n_${DateTime.now().microsecondsSinceEpoch}';
    _name = TextEditingController(text: e?.name ?? '');
    _style = TextEditingController(text: e?.styleLabel ?? '');
    _hint = TextEditingController(text: e?.systemHint ?? '');
    _weight = e?.weight ?? 0.6;
    _enabled = e?.isEnabled ?? true;
    _avatarPath = e?.avatarPath;
    _providerId = e?.providerId;
    _modelId = e?.modelId;
  }

  @override
  void dispose() {
    _name.dispose();
    _style.dispose();
    _hint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(llmProvidersListProvider).value ?? const [];
    final models = _providerId == null
        ? const <LlmModel>[]
        : (ref.watch(llmModelsForProviderProvider(_providerId!)).value ??
              const []);
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: _Sheet(
        title: widget.existing == null ? '添加网友' : '编辑网友',
        child: SizedBox(
          height: media.size.height * 0.75,
          child: ListView(
            children: [
              Row(
                children: [
                  _NetizenAvatar(
                    netizen: Netizen(
                      id: _id,
                      name: _name.text.isEmpty ? '友' : _name.text,
                      systemHint: '',
                      avatarPath: _avatarPath,
                    ),
                    size: 52,
                  ),
                  const SizedBox(width: 12),
                  TextButton(onPressed: _pickAvatar, child: const Text('选头像')),
                  if (_avatarPath != null)
                    TextButton(
                      onPressed: () => setState(() => _avatarPath = null),
                      child: const Text('清除'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: '名字'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _style,
                decoration: const InputDecoration(labelText: '风格标签'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hint,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '人设提示词',
                  alignLabelWithHint: true,
                  helperText: '只写「怎么说话」。场景（RSS 评论区网友）由系统自动附上，无需重复。',
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '出现概率 ${(_weight * 100).round()}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _weight,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (v) => setState(() => _weight = v),
              ),
              DropdownButtonFormField<String?>(
                // ignore: deprecated_member_use
                value: _providerId,
                decoration: const InputDecoration(labelText: '绑定提供商'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('不绑定'),
                  ),
                  for (final p in providers)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => setState(() {
                  _providerId = v;
                  _modelId = null;
                }),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                // ignore: deprecated_member_use
                value: _modelId,
                decoration: const InputDecoration(labelText: '绑定模型'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('不绑定'),
                  ),
                  for (final m in models)
                    DropdownMenuItem(value: m.id, child: Text(m.displayName)),
                ],
                onChanged: (v) => setState(() => _modelId = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('启用'),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
              const SizedBox(height: 8),
              _PrimaryButton(label: '保存', onTap: _save),
              if (widget.existing != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await ref.read(netizenControllerProvider).delete(_id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    '删除网友',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final avatars = Directory(p.join(dir.path, 'avatars'));
    if (!await avatars.exists()) {
      await avatars.create(recursive: true);
    }
    final dest = p.join(avatars.path, '$_id.jpg');
    await File(file.path).copy(dest);
    setState(() => _avatarPath = dest);
  }

  Future<void> _save() async {
    final name = _name.text.trim().isEmpty ? '网友' : _name.text.trim();
    await ref
        .read(netizenControllerProvider)
        .upsert(
          Netizen(
            id: _id,
            name: name,
            styleLabel: _style.text.trim().isEmpty ? null : _style.text.trim(),
            systemHint: _hint.text.trim(),
            avatarPath: _avatarPath,
            weight: _weight,
            providerId: _providerId,
            modelId: _modelId,
            isEnabled: _enabled,
            sortOrder: widget.existing?.sortOrder ?? 99,
            createdAt: widget.existing?.createdAt,
          ),
        );
    if (mounted) Navigator.pop(context);
  }
}

class _NetizenAvatar extends StatelessWidget {
  const _NetizenAvatar({required this.netizen, required this.size});

  final Netizen netizen;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = netizen.avatarPath;
    if (path != null && File(path).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(path),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return MonogramAvatar(label: netizen.name, size: size, seed: netizen.id);
  }
}

// ── Shared chrome (mirrors Set page style) ───────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

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

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
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
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }
}

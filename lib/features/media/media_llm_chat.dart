import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/llm/llm_client.dart';
import '../../data/llm/llm_resolve.dart';
import '../../data/llm/llm_text_sanitize.dart';
import '../../data/models/models.dart';
import '../../providers/core_providers.dart';
import '../../widgets/liquid_glass.dart';

Future<void> showMediaLlmChat(BuildContext context, Article article) {
  if (!article.isMedia) return Future.value();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭 AI 对话',
    barrierColor: Colors.black.withValues(alpha: 0.38),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => _MediaLlmChat(article: article),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _MediaLlmChat extends ConsumerStatefulWidget {
  const _MediaLlmChat({required this.article});

  final Article article;

  @override
  ConsumerState<_MediaLlmChat> createState() => _MediaLlmChatState();
}

class _MediaLlmChatState extends ConsumerState<_MediaLlmChat> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_ChatEntry>[
    const _ChatEntry(
      role: 'assistant',
      content: '可以和我聊这期内容。我的上下文来自标题与节目说明，不会假装听过或看过未提供的部分。',
    ),
  ];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    _input.clear();
    setState(() {
      _sending = true;
      _error = null;
      _messages.add(_ChatEntry(role: 'user', content: text));
    });
    _scrollToEnd();

    try {
      final repo = ref.read(llmProviderRepositoryProvider);
      final config = await resolveDefaultLlmConfig(
        llmRepo: repo,
        providers: await repo.getProviders(),
        allModels: await repo.getAllModels(),
      );
      if (config == null) {
        throw LlmException('请先在设置中配置可用的默认模型与 API Key');
      }
      final response = await ref
          .read(llmClientProvider)
          .complete(
            _requestMessages(widget.article, _messages),
            config.copyWith(),
          );
      final clean = sanitizeLlmCommentText(response);
      if (clean.isEmpty) throw LlmException('模型没有返回可显示的内容');
      if (!mounted) return;
      setState(
        () => _messages.add(_ChatEntry(role: 'assistant', content: clean)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToEnd();
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      unawaited(
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            48,
            12,
            12 + media.viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: media.size.height * 0.72,
            ),
            child: Material(
              color: Colors.transparent,
              child: LiquidGlass(
                borderRadius: 24,
                blur: 34,
                opacity: isDark ? 0.12 : 0.78,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 15, 8, 11),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 17,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '一起聊',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  widget.article.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.textTertiaryDark
                                            : AppColors.textTertiaryLight,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: '关闭',
                            onPressed: Navigator.of(context).pop,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                        itemCount: _messages.length + (_sending ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return const _ThinkingBubble();
                          }
                          return _MessageBubble(entry: _messages[index]);
                        },
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          _error!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 7, 8, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _input,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                hintText: '问问这期内容…',
                                filled: true,
                                fillColor:
                                    (isDark ? Colors.white : Colors.black)
                                        .withValues(alpha: 0.055),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          IconButton.filled(
                            tooltip: '发送',
                            onPressed: _sending ? null : _send,
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white
                                  : Colors.black,
                              foregroundColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            icon: const Icon(Icons.arrow_upward_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.entry});

  final _ChatEntry entry;

  @override
  Widget build(BuildContext context) {
    final user = entry.role == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: user
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? AppColors.inkSoft : AppColors.wash),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(user ? 16 : 5),
            bottomRight: Radius.circular(user ? 5 : 16),
          ),
        ),
        child: Text(
          entry.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.48,
            color: user ? (isDark ? Colors.black : Colors.white) : null,
          ),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ChatEntry {
  const _ChatEntry({required this.role, required this.content});

  final String role;
  final String content;
}

List<LlmMessage> _requestMessages(Article article, List<_ChatEntry> history) {
  final raw = article.body.trim().isNotEmpty ? article.body : article.summary;
  final excerpt = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  final clipped = excerpt.length > 5000
      ? '${excerpt.substring(0, 5000)}…'
      : excerpt;
  return [
    LlmMessage(
      role: 'system',
      content:
          '''
你是 WEPSEED 音视频内容旁边的简洁对话助手。围绕用户正在播放的内容交流，回答自然、克制、直接。
你只能看到订阅源提供的标题、摘要和节目说明，看不到也听不到媒体流本身。信息不足时明确说明，不得假装已经观看或收听。
不要输出思考过程、工具调用或元话术。默认使用中文。

类型：${article.mediaType == ArticleMediaType.audio ? '音频' : '视频'}
来源：${article.source.name}
标题：${article.title}
节目说明：${clipped.isEmpty ? '（订阅源未提供）' : clipped}
'''
              .trim(),
    ),
    ...history
        .skip(1)
        .take(12)
        .map((entry) => LlmMessage(role: entry.role, content: entry.content)),
  ];
}

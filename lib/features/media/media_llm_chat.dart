import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../../providers/media_chat_providers.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(mediaChatControllerProvider).resume(widget.article));
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(bool busy) async {
    final text = _input.text.trim();
    if (text.isEmpty || busy) return;
    _input.clear();
    await ref.read(mediaChatControllerProvider).send(widget.article, text);
    _scrollToEnd();
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
    final messagesAsync = ref.watch(
      mediaChatMessagesProvider(widget.article.id),
    );
    final messages = messagesAsync.value ?? const <MediaChatMessage>[];
    final busy = messages.any(
      (message) => message.status == MediaChatMessageStatus.pending,
    );
    final media = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.listen(mediaChatMessagesProvider(widget.article.id), (previous, next) {
      _scrollToEnd();
    });

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
                    _Header(article: widget.article),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                    Expanded(
                      child: messagesAsync.isLoading && messages.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              controller: _scroll,
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                16,
                                14,
                                12,
                              ),
                              itemCount: messages.isEmpty ? 1 : messages.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                if (messages.isEmpty) {
                                  return const _WelcomeBubble();
                                }
                                return _MessageBubble(entry: messages[index]);
                              },
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
                              onSubmitted: (_) => _send(busy),
                              decoration: InputDecoration(
                                hintText: busy ? '正在生成回复…' : '问问这期内容…',
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
                            onPressed: busy ? null : () => _send(busy),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white
                                  : Colors.black,
                              foregroundColor: isDark
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            icon: busy
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_upward_rounded),
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

class _Header extends StatelessWidget {
  const _Header({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  article.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    );
  }
}

class _WelcomeBubble extends StatelessWidget {
  const _WelcomeBubble();

  @override
  Widget build(BuildContext context) {
    return const _StaticBubble(
      text: '可以和我聊这期内容。我的上下文来自标题与节目说明，不会假装听过或看过未提供的部分。',
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.entry});

  final MediaChatMessage entry;

  @override
  Widget build(BuildContext context) {
    if (entry.status == MediaChatMessageStatus.pending) {
      return const _StaticBubble(text: '正在生成回复…', loading: true);
    }
    if (entry.status == MediaChatMessageStatus.failed) {
      return _StaticBubble(text: entry.error ?? '生成失败，请重新发送问题', error: true);
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: entry.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: entry.isUser
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? AppColors.inkSoft : AppColors.wash),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(entry.isUser ? 16 : 5),
            bottomRight: Radius.circular(entry.isUser ? 5 : 16),
          ),
        ),
        child: Text(
          entry.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.48,
            color: entry.isUser ? (isDark ? Colors.black : Colors.white) : null,
          ),
        ),
      ),
    );
  }
}

class _StaticBubble extends StatelessWidget {
  const _StaticBubble({
    required this.text,
    this.loading = false,
    this.error = false,
  });

  final String text;
  final bool loading;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.inkSoft
              : AppColors.wash,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.48,
                  color: error ? Theme.of(context).colorScheme.error : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

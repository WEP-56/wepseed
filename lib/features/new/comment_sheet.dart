import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/monogram.dart';
import '../../core/utils/time_labels.dart';
import '../../data/models/models.dart';
import '../../providers/comment_providers.dart';
import '../../providers/netizen_providers.dart';
import '../../providers/settings_provider.dart';

Future<void> showCommentSheet(
  BuildContext context, {
  required String articleId,
  required CommentActivityNotifier activity,
}) async {
  activity.setViewing(articleId, true);
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => CommentSheet(articleId: articleId),
    );
  } finally {
    activity.setViewing(articleId, false);
  }
}

class CommentSheet extends ConsumerStatefulWidget {
  const CommentSheet({super.key, required this.articleId});

  final String articleId;

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _replyToId;
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(commentControllerProvider)
          .ensureGenerated(
            widget.articleId,
            when: CommentTrigger.onOpenComments,
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final height = media.size.height * 0.78;
    final comments =
        ref.watch(commentsForArticleProvider(widget.articleId)).value ??
        const [];
    final netizens = ref.watch(netizensProvider).value ?? const [];
    final user =
        ref.watch(userProfileProvider).value ??
        const UserProfile(displayName: '旅人');
    final trigger =
        ref.watch(settingsProvider).value?.commentTrigger ??
        CommentTrigger.onOpenComments;
    final activity =
        ref.watch(commentActivityProvider)[widget.articleId] ??
        const CommentActivity();

    final netizenMap = {for (final n in netizens) n.id: n};
    final roots = comments.where((c) => c.parentId == null).toList();
    final byParent = <String, List<Comment>>{};
    for (final c in comments) {
      if (c.parentId != null) {
        byParent.putIfAbsent(c.parentId!, () => []).add(c);
      }
    }

    List<(Comment, int)> descendantsOf(String parentId, [int depth = 1]) {
      final result = <(Comment, int)>[];
      for (final child in byParent[parentId] ?? const <Comment>[]) {
        result.add((child, depth));
        result.addAll(descendantsOf(child.id, depth + 1));
      }
      return result;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.inkElevated : AppColors.canvas)
                    .withValues(alpha: 0.98),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        Text(
                          '评论 · ${comments.length}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (activity.isBusy) ...[
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.6),
                          ),
                        ],
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: comments.isEmpty && !activity.isBusy
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    trigger == CommentTrigger.off
                                        ? '评论生成已关闭'
                                        : '还没有评论\n在 Set → LLM 配置 Key 与模型后，打开评论会真请求生成',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight,
                                      height: 1.45,
                                    ),
                                  ),
                                  if (activity.lastEvent?.type ==
                                          CommentActivityEventType.failed &&
                                      trigger != CommentTrigger.off) ...[
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: () => ref
                                          .read(commentControllerProvider)
                                          .retryGeneration(widget.articleId),
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('重试'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            itemCount: roots.length + (activity.isBusy ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == roots.length) {
                                return _TypingRow(
                                  text: activity.statusText ?? '评论正在生成…',
                                );
                              }
                              final root = roots[index];
                              final replies = descendantsOf(root.id);
                              return _CommentThread(
                                root: root,
                                replies: replies,
                                netizenMap: netizenMap,
                                userName: user.displayName,
                                onReply: (id, name) {
                                  setState(() {
                                    _replyToId = id;
                                    _replyToName = name;
                                  });
                                  _focusNode.requestFocus();
                                },
                              );
                            },
                          ),
                  ),
                  if (_replyToId != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '回复 @$_replyToName',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _replyToId = null;
                              _replyToName = null;
                            }),
                            child: Text(
                              '取消',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      0,
                      14,
                      media.padding.bottom > 0 ? 10 : 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: InputDecoration(
                              hintText: _replyToName == null
                                  ? '写评论…（先点某条「回复」）'
                                  : '回复 @$_replyToName…',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: isDark ? AppColors.white : AppColors.black,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _send,
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 46,
                              height: 46,
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color: isDark
                                    ? AppColors.black
                                    : AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
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
    );
  }

  void _send() {
    final t = _controller.text.trim();
    final parent = _replyToId;
    if (t.isEmpty || parent == null) return;
    HapticFeedback.lightImpact();
    ref
        .read(commentControllerProvider)
        .reply(articleId: widget.articleId, parentId: parent, text: t);
    _controller.clear();
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }
}

class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.root,
    required this.replies,
    required this.netizenMap,
    required this.userName,
    required this.onReply,
  });

  final Comment root;
  final List<(Comment, int)> replies;
  final Map<String, Netizen> netizenMap;
  final String userName;
  final void Function(String id, String name) onReply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentRow(
            comment: root,
            name: _nameOf(root),
            avatar: _avatarOf(root),
            onReply: () => onReply(root.id, _nameOf(root)),
          ),
          for (final entry in replies)
            Padding(
              padding: EdgeInsets.only(
                left: 24.0 * entry.$2.clamp(1, 2),
                top: 10,
              ),
              child: _CommentRow(
                comment: entry.$1,
                name: _nameOf(entry.$1),
                avatar: _avatarOf(entry.$1),
                compact: true,
                onReply: entry.$1.authorType == CommentAuthorType.netizen
                    ? () => onReply(entry.$1.id, _nameOf(entry.$1))
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  String _nameOf(Comment c) {
    if (c.authorType == CommentAuthorType.user) return userName;
    final n = c.netizenId == null ? null : netizenMap[c.netizenId!];
    return n?.name ?? '网友';
  }

  Widget _avatarOf(Comment c) {
    if (c.authorType == CommentAuthorType.user) {
      return MonogramAvatar(label: userName, size: 28);
    }
    final n = c.netizenId == null ? null : netizenMap[c.netizenId!];
    if (n?.avatarPath != null && File(n!.avatarPath!).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(n.avatarPath!),
          width: 28,
          height: 28,
          fit: BoxFit.cover,
        ),
      );
    }
    return MonogramAvatar(label: n?.name ?? '友', size: 28, seed: n?.id);
  }
}

class _TypingRow extends StatelessWidget {
  const _TypingRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.08,
              ),
            ),
            child: SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.comment,
    required this.name,
    required this.avatar,
    this.onReply,
    this.compact = false,
  });

  final Comment comment;
  final String name;
  final Widget avatar;
  final VoidCallback? onReply;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    relativeTime(comment.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.content,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              if (onReply != null) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onReply,
                  child: Text(
                    '回复',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

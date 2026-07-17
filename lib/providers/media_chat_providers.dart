import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/llm/llm_client.dart';
import '../data/llm/llm_resolve.dart';
import '../data/llm/llm_text_sanitize.dart';
import '../data/models/models.dart';
import 'core_providers.dart';

final mediaChatMessagesProvider =
    StreamProvider.family<List<MediaChatMessage>, String>((ref, articleId) {
      return ref.watch(mediaChatRepositoryProvider).watchForArticle(articleId);
    });

final mediaChatControllerProvider = Provider<MediaChatController>((ref) {
  return MediaChatController(ref);
});

/// Global controller: a dialog closing never owns or cancels an LLM request.
class MediaChatController {
  MediaChatController(this._ref);

  final Ref _ref;
  final _running = <String, Future<void>>{};

  Future<void> send(Article article, String content) async {
    final text = content.trim();
    if (text.isEmpty || !article.isMedia) return;
    final placeholder = await _ref
        .read(mediaChatRepositoryProvider)
        .enqueue(article.id, text);
    unawaited(_run(article, placeholder.id));
  }

  /// Replays unfinished assistant placeholders after a dialog is reopened or
  /// the app is cold-started on the article again.
  Future<void> resume(Article article) async {
    if (!article.isMedia) return;
    final messages = await _ref
        .read(mediaChatRepositoryProvider)
        .getForArticle(article.id);
    for (final message in messages) {
      if (message.role == 'assistant' &&
          message.status == MediaChatMessageStatus.pending) {
        unawaited(_run(article, message.id));
      }
    }
  }

  Future<void> _run(Article article, String placeholderId) {
    final existing = _running[placeholderId];
    if (existing != null) return existing;
    final task = _generate(article, placeholderId);
    _running[placeholderId] = task;
    return task.whenComplete(() => _running.remove(placeholderId));
  }

  Future<void> _generate(Article article, String placeholderId) async {
    final repository = _ref.read(mediaChatRepositoryProvider);
    try {
      final messages = await repository.getForArticle(article.id);
      final pendingIndex = messages.indexWhere((m) => m.id == placeholderId);
      if (pendingIndex < 0) return;
      final configRepo = _ref.read(llmProviderRepositoryProvider);
      final config = await resolveDefaultLlmConfig(
        llmRepo: configRepo,
        providers: await configRepo.getProviders(),
        allModels: await configRepo.getAllModels(),
      );
      if (config == null) {
        throw LlmException('请先在设置中配置可用的默认模型与 API Key');
      }
      final response = await _ref
          .read(llmClientProvider)
          .complete(
            _requestMessages(article, messages.take(pendingIndex).toList()),
            config,
          );
      final clean = sanitizeLlmCommentText(response);
      if (clean.isEmpty) throw LlmException('模型没有返回可显示的内容');
      await repository.complete(placeholderId, clean);
    } catch (error) {
      await repository.fail(placeholderId, error.toString());
    }
  }
}

List<LlmMessage> _requestMessages(
  Article article,
  List<MediaChatMessage> history,
) {
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
        .where((m) => m.status == MediaChatMessageStatus.completed)
        .take(12)
        .map((m) => LlmMessage(role: m.role, content: m.content)),
  ];
}

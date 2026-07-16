import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_flags.dart';
import '../data/llm/llm_client.dart';
import '../data/models/models.dart';
import '../data/repositories/comment_repository.dart';
import 'core_providers.dart';

final commentsForArticleProvider = StreamProvider.family<List<Comment>, String>(
  (ref, articleId) {
    return ref.watch(commentRepositoryProvider).watchForArticle(articleId);
  },
);

final commentControllerProvider = Provider<CommentController>((ref) {
  return CommentController(ref);
});

final commentActivityProvider =
    NotifierProvider<CommentActivityNotifier, Map<String, CommentActivity>>(
      CommentActivityNotifier.new,
    );

enum CommentActivityEventType { commentsReady, replyReady, partial, failed }

class CommentActivityEvent {
  const CommentActivityEvent({
    required this.id,
    required this.type,
    required this.message,
  });

  final int id;
  final CommentActivityEventType type;
  final String message;
}

class CommentActivity {
  const CommentActivity({
    this.isPreparing = false,
    this.isGenerating = false,
    this.total = 0,
    this.completed = 0,
    this.failed = 0,
    this.queuedNetizens = const {},
    this.activeNetizens = const {},
    this.replyingNetizens = const {},
    this.isViewing = false,
    this.lastEvent,
  });

  final bool isPreparing;
  final bool isGenerating;
  final int total;
  final int completed;
  final int failed;
  final Set<String> queuedNetizens;
  final Set<String> activeNetizens;
  final Set<String> replyingNetizens;
  final bool isViewing;
  final CommentActivityEvent? lastEvent;

  bool get isBusy => isPreparing || isGenerating || replyingNetizens.isNotEmpty;

  String? get statusText {
    if (replyingNetizens.isNotEmpty) {
      return '${replyingNetizens.join('、')} 正在回复你…';
    }
    if (activeNetizens.isNotEmpty) {
      return '${activeNetizens.join('、')} 正在评论…';
    }
    if (queuedNetizens.isNotEmpty) {
      return '${queuedNetizens.join('、')} 等待评论…';
    }
    if (isPreparing) return '正在邀请网友…';
    if (isGenerating) return '评论正在生成…';
    return null;
  }

  CommentActivity copyWith({
    bool? isPreparing,
    bool? isGenerating,
    int? total,
    int? completed,
    int? failed,
    Set<String>? queuedNetizens,
    Set<String>? activeNetizens,
    Set<String>? replyingNetizens,
    bool? isViewing,
    CommentActivityEvent? lastEvent,
  }) {
    return CommentActivity(
      isPreparing: isPreparing ?? this.isPreparing,
      isGenerating: isGenerating ?? this.isGenerating,
      total: total ?? this.total,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      queuedNetizens: queuedNetizens ?? this.queuedNetizens,
      activeNetizens: activeNetizens ?? this.activeNetizens,
      replyingNetizens: replyingNetizens ?? this.replyingNetizens,
      isViewing: isViewing ?? this.isViewing,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }
}

class CommentActivityNotifier extends Notifier<Map<String, CommentActivity>> {
  @override
  Map<String, CommentActivity> build() => const {};

  CommentActivity _for(String articleId) =>
      state[articleId] ?? const CommentActivity();

  void _set(String articleId, CommentActivity value) {
    state = {...state, articleId: value};
  }

  void beginGeneration(String articleId) {
    _set(
      articleId,
      _for(articleId).copyWith(
        isPreparing: true,
        isGenerating: true,
        total: 0,
        completed: 0,
        failed: 0,
        queuedNetizens: const {},
        activeNetizens: const {},
      ),
    );
  }

  void setViewing(String articleId, bool value) {
    _set(articleId, _for(articleId).copyWith(isViewing: value));
  }

  void generationProgress(
    String articleId,
    CommentGenerationProgress progress,
  ) {
    final current = _for(articleId);
    final queued = {...current.queuedNetizens};
    final active = {...current.activeNetizens};
    var completed = current.completed;
    var failed = current.failed;
    switch (progress.phase) {
      case LlmQueuePhase.queued:
        queued.add(progress.netizenName);
      case LlmQueuePhase.running:
        queued.remove(progress.netizenName);
        active.add(progress.netizenName);
      case LlmQueuePhase.completed:
        queued.remove(progress.netizenName);
        active.remove(progress.netizenName);
        completed++;
      case LlmQueuePhase.failed:
        queued.remove(progress.netizenName);
        active.remove(progress.netizenName);
        failed++;
    }
    _set(
      articleId,
      current.copyWith(
        isPreparing: false,
        isGenerating: true,
        total: progress.total,
        completed: completed,
        failed: failed,
        queuedNetizens: queued,
        activeNetizens: active,
      ),
    );
  }

  void finishGeneration(String articleId, CommentGenerationResult result) {
    final current = _for(articleId);
    CommentActivityEvent? event;
    if (!result.alreadyPresent && result.generated > 0) {
      final partial = result.failed > 0;
      event = CommentActivityEvent(
        id: DateTime.now().microsecondsSinceEpoch,
        type: partial
            ? CommentActivityEventType.partial
            : CommentActivityEventType.commentsReady,
        message: partial
            ? '${result.generated} 位网友评论好了，${result.failed} 位暂时没发出来'
            : '${result.generated} 位网友评论好了，可以看了',
      );
    } else if (!result.alreadyPresent && result.total > 0) {
      event = CommentActivityEvent(
        id: DateTime.now().microsecondsSinceEpoch,
        type: CommentActivityEventType.failed,
        message: '这次评论没有生成成功，请稍后重试',
      );
    }
    _set(
      articleId,
      current.copyWith(
        isPreparing: false,
        isGenerating: false,
        total: result.total,
        completed: result.generated,
        failed: result.failed,
        queuedNetizens: const {},
        activeNetizens: const {},
        lastEvent: event,
      ),
    );
  }

  void failGeneration(String articleId) {
    final current = _for(articleId);
    _set(
      articleId,
      current.copyWith(
        isPreparing: false,
        isGenerating: false,
        queuedNetizens: const {},
        activeNetizens: const {},
        lastEvent: CommentActivityEvent(
          id: DateTime.now().microsecondsSinceEpoch,
          type: CommentActivityEventType.failed,
          message: '评论生成中断，请稍后重试',
        ),
      ),
    );
  }

  void replyProgress(String articleId, String name, LlmQueuePhase phase) {
    final current = _for(articleId);
    final replying = {...current.replyingNetizens};
    switch (phase) {
      case LlmQueuePhase.queued || LlmQueuePhase.running:
        replying.add(name);
      case LlmQueuePhase.completed || LlmQueuePhase.failed:
        replying.remove(name);
    }
    _set(articleId, current.copyWith(replyingNetizens: replying));
  }

  void finishReply(String articleId, CommentReplyResult result) {
    final current = _for(articleId);
    final replying = {...current.replyingNetizens};
    if (result.netizenName != null) replying.remove(result.netizenName);
    _set(
      articleId,
      current.copyWith(
        replyingNetizens: replying,
        lastEvent: result.replied
            ? CommentActivityEvent(
                id: DateTime.now().microsecondsSinceEpoch,
                type: CommentActivityEventType.replyReady,
                message: '${result.netizenName} 回复了你',
              )
            : null,
      ),
    );
  }
}

class CommentController {
  CommentController(this._ref);

  final Ref _ref;
  final Map<String, Future<void>> _generationTasks = {};

  /// [when] is the call site: only generates if settings.commentTrigger matches.
  Future<void> ensureGenerated(
    String articleId, {
    required CommentTrigger when,
  }) async {
    final settings = await _ref.read(settingsRepositoryProvider).get();
    if (settings.commentTrigger != when) return;

    final running = _generationTasks[articleId];
    if (running != null) return running;
    final task = _runGeneration(articleId, settings.commentTrigger);
    _generationTasks[articleId] = task;
    try {
      await task;
    } finally {
      if (identical(_generationTasks[articleId], task)) {
        _generationTasks.remove(articleId);
      }
    }
  }

  Future<void> _runGeneration(String articleId, CommentTrigger trigger) async {
    final activity = _ref.read(commentActivityProvider.notifier);
    activity.beginGeneration(articleId);

    final article = await _ref.read(articleRepositoryProvider).get(articleId);
    if (article == null) {
      activity.failGeneration(articleId);
      return;
    }
    final pool = await _ref.read(netizenRepositoryProvider).getAll();
    final providers = await _ref
        .read(llmProviderRepositoryProvider)
        .getProviders();
    final models = await _ref
        .read(llmProviderRepositoryProvider)
        .getAllModels();

    try {
      final result = await _ref
          .read(commentRepositoryProvider)
          .ensureGenerated(
            articleId,
            trigger: trigger,
            pool: pool,
            article: article,
            providers: providers,
            models: models,
            llmRepo: _ref.read(llmProviderRepositoryProvider),
            llmClient: _ref.read(llmClientProvider),
            forceMock: kUseMockComments,
            onProgress: (progress) =>
                activity.generationProgress(articleId, progress),
          );
      activity.finishGeneration(articleId, result);
    } catch (_) {
      activity.failGeneration(articleId);
    }
  }

  Future<void> reply({
    required String articleId,
    required String parentId,
    required String text,
  }) async {
    final article = await _ref.read(articleRepositoryProvider).get(articleId);
    if (article == null) return;
    final pool = await _ref.read(netizenRepositoryProvider).getAll();
    final providers = await _ref
        .read(llmProviderRepositoryProvider)
        .getProviders();
    final models = await _ref
        .read(llmProviderRepositoryProvider)
        .getAllModels();

    final activity = _ref.read(commentActivityProvider.notifier);
    final result = await _ref
        .read(commentRepositoryProvider)
        .addUserReply(
          articleId: articleId,
          parentId: parentId,
          text: text,
          pool: pool,
          article: article,
          providers: providers,
          models: models,
          llmRepo: _ref.read(llmProviderRepositoryProvider),
          llmClient: _ref.read(llmClientProvider),
          forceMock: kUseMockComments,
          onProgress: (name, phase) =>
              activity.replyProgress(articleId, name, phase),
        );
    activity.finishReply(articleId, result);
  }

  Future<void> retryGeneration(String articleId) async {
    final settings = await _ref.read(settingsRepositoryProvider).get();
    if (settings.commentTrigger == CommentTrigger.off) return;
    final running = _generationTasks[articleId];
    if (running != null) return running;
    final task = _runGeneration(articleId, settings.commentTrigger);
    _generationTasks[articleId] = task;
    try {
      await task;
    } finally {
      if (identical(_generationTasks[articleId], task)) {
        _generationTasks.remove(articleId);
      }
    }
  }

  /// Clear all comments (remove old mock rows so real LLM can re-generate).
  Future<void> clearAllComments() async {
    await _ref.read(commentRepositoryProvider).clearAll();
  }

  Future<void> clearCommentsForArticle(String articleId) async {
    await _ref.read(commentRepositoryProvider).clearForArticle(articleId);
  }
}

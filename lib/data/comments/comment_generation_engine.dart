import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/config/app_flags.dart';
import '../db/app_database.dart';
import '../llm/llm_client.dart';
import '../llm/llm_prompt.dart';
import '../llm/llm_resolve.dart';
import '../llm/llm_text_sanitize.dart';
import '../models/models.dart';
import '../repositories/comment_job_repository.dart';
import '../repositories/comment_repository.dart';
import '../repositories/llm_provider_repository.dart';
import 'comment_job_models.dart';

/// Shared top-level comment generation used by UI isolate and WM isolate.
class CommentGenerationEngine {
  CommentGenerationEngine({
    required AppDatabase db,
    required CommentJobRepository jobs,
    Random? rng,
  }) : _db = db,
       _jobs = jobs,
       _rng = rng ?? Random();

  final AppDatabase _db;
  final CommentJobRepository _jobs;
  final Random _rng;

  /// Weighted sample of enabled netizens (≥1 when pool non-empty).
  List<Netizen> sampleNetizens(List<Netizen> pool) {
    final enabled = pool.where((n) => n.isEnabled).toList();
    if (enabled.isEmpty) return const [];
    final picked = <Netizen>[];
    for (final n in enabled) {
      if (_rng.nextDouble() < n.weight.clamp(0.0, 1.0)) {
        picked.add(n);
      }
    }
    if (picked.isEmpty) {
      picked.add(_weightedChoice(enabled));
    }
    return picked;
  }

  /// Run all pending items for [jobId] under [owner] lease.
  ///
  /// Returns a [CommentGenerationResult] compatible with existing UI.
  Future<CommentGenerationResult> runJob({
    required String jobId,
    required String owner,
    required Article article,
    required List<Netizen> pool,
    required List<LlmProvider> providers,
    required List<LlmModel> models,
    required LlmProviderRepository llmRepo,
    required LlmClient llmClient,
    bool forceMock = false,
    void Function(CommentGenerationProgress progress)? onProgress,
  }) async {
    final claimed = await _jobs.claimJob(jobId: jobId, owner: owner);
    if (claimed == null) {
      // Another isolate owns it — treat as in-flight, not alreadyPresent.
      final job = await _jobs.getJob(jobId);
      final items = job == null
          ? <CommentJobItem>[]
          : await _jobs.getItems(jobId);
      final total = items.length;
      final done = items
          .where((i) => i.status == CommentJobItemStatus.succeeded)
          .length;
      return CommentGenerationResult(total: total, generated: done);
    }

    final byId = {for (final n in pool) n.id: n};
    final items = await _jobs.getItems(jobId);
    final total = items.length;
    var generated = 0;
    final useMock = forceMock || kUseMockComments;

    for (final item in items) {
      if (item.isTerminal) {
        if (item.status == CommentJobItemStatus.succeeded) generated++;
        continue;
      }

      final netizen = byId[item.netizenId];
      if (netizen == null || !netizen.isEnabled) {
        await _jobs.markItemSkipped(item.id, reason: 'netizen missing');
        onProgress?.call(
          CommentGenerationProgress(
            netizenName: netizen?.name ?? item.netizenId,
            phase: LlmQueuePhase.failed,
            total: total,
          ),
        );
        continue;
      }

      // Already has a top-level comment for this netizen (partial kill recovery).
      final existingId = await _existingTopLevelCommentId(
        articleId: article.id,
        netizenId: netizen.id,
      );
      if (existingId != null) {
        await _jobs.markItemSucceeded(itemId: item.id, commentId: existingId);
        generated++;
        onProgress?.call(
          CommentGenerationProgress(
            netizenName: netizen.name,
            phase: LlmQueuePhase.completed,
            total: total,
          ),
        );
        continue;
      }

      await _jobs.heartbeat(jobId: jobId, owner: owner);
      await _jobs.markItemRunning(item.id);

      var reported = false;
      final content = await _topLevelContent(
        netizen: netizen,
        article: article,
        useMock: useMock,
        providers: providers,
        models: models,
        llmRepo: llmRepo,
        llmClient: llmClient,
        onQueuePhase: (phase) {
          reported = true;
          onProgress?.call(
            CommentGenerationProgress(
              netizenName: netizen.name,
              phase: phase,
              total: total,
            ),
          );
        },
      );

      if (content == null || content.trim().isEmpty) {
        // No Key / empty / error → skip (do not plant filler).
        await _jobs.markItemSkipped(item.id, reason: 'empty or no key');
        if (!reported) {
          onProgress?.call(
            CommentGenerationProgress(
              netizenName: netizen.name,
              phase: LlmQueuePhase.failed,
              total: total,
            ),
          );
        }
        continue;
      }

      final commentId =
          'c_${article.id}_${netizen.id}_${DateTime.now().microsecondsSinceEpoch}';
      await _db
          .into(_db.comments)
          .insert(
            CommentsCompanion.insert(
              id: commentId,
              articleId: article.id,
              authorType: 'netizen',
              netizenId: Value(netizen.id),
              content: content.trim(),
              createdAt: DateTime.now(),
            ),
          );
      await _jobs.markItemSucceeded(itemId: item.id, commentId: commentId);
      generated++;
    }

    await _jobs.finalizeJob(jobId);
    return CommentGenerationResult(total: total, generated: generated);
  }

  Future<String?> _existingTopLevelCommentId({
    required String articleId,
    required String netizenId,
  }) async {
    final rows =
        await (_db.select(_db.comments)..where(
              (t) =>
                  t.articleId.equals(articleId) &
                  t.netizenId.equals(netizenId) &
                  t.parentId.isNull() &
                  t.authorType.equals('netizen'),
            ))
            .get();
    if (rows.isEmpty) return null;
    return rows.first.id;
  }

  Future<String?> _topLevelContent({
    required Netizen netizen,
    required Article article,
    required bool useMock,
    required List<LlmProvider> providers,
    required List<LlmModel> models,
    required LlmProviderRepository llmRepo,
    required LlmClient llmClient,
    void Function(LlmQueuePhase phase)? onQueuePhase,
  }) async {
    if (useMock) {
      final summary = article.summary.isEmpty ? article.title : article.summary;
      final short = summary.length <= 64
          ? summary
          : '${summary.substring(0, 64)}…';
      return '「${netizen.name}」${netizen.styleLabel ?? ""}：$short';
    }

    final cfg = await resolveLlmConfigForNetizen(
      netizen: netizen,
      llmRepo: llmRepo,
      providers: providers,
      allModels: models,
    );
    if (cfg == null) return null;

    try {
      final text = await llmClient.complete(
        netizenTopLevelMessages(netizen: netizen, article: article),
        cfg.copyWith(onQueuePhase: onQueuePhase),
      );
      final cleaned = sanitizeLlmCommentText(text);
      if (cleaned.isNotEmpty) return cleaned;
      return null;
    } on LlmException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Netizen _weightedChoice(List<Netizen> list) {
    final positive = list.where((n) => n.weight > 0).toList();
    final pool = positive.isEmpty ? list : positive;
    final total = pool.fold<double>(0, (s, n) => s + n.weight.clamp(0.01, 1.0));
    var r = _rng.nextDouble() * total;
    for (final n in pool) {
      r -= n.weight.clamp(0.01, 1.0);
      if (r <= 0) return n;
    }
    return pool.last;
  }
}

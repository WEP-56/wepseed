import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/comments/comment_generation_engine.dart';
import '../../data/db/app_database.dart';
import '../../data/llm/http_llm_client.dart';
import '../../data/llm/scheduled_llm_client.dart';
import '../../data/repositories/comment_job_repository_impl.dart';
import '../../data/repositories/drift_article_repository.dart';
import '../../data/repositories/llm_provider_repository_impl.dart';
import '../../data/repositories/netizen_repository_impl.dart';
import '../../data/repositories/secure_settings_impl.dart';

/// One-off WorkManager identity for draining durable comment jobs (D-task).
const kCommentJobUniqueName = 'wepseed.oneoff-comment-jobs';

/// Value delivered as `taskName` inside [backgroundCallbackDispatcher].
const kCommentJobTaskName = 'wepseed.drain-comment-jobs';

const kCommentJobTag = 'wepseed.comments';

const _leaseOwnerWm = 'wm-isolate';

/// Drain open comment jobs in a background isolate (own DB + secure keys).
///
/// Returns true when the worker finishes without fatal errors. Incomplete jobs
/// stay pending and should be re-enqueued by the caller / cold start.
Future<bool> runCommentJobsDrain({int maxJobs = 3}) async {
  final db = AppDatabase();
  final jobs = CommentJobRepositoryImpl(db);
  final engine = CommentGenerationEngine(db: db, jobs: jobs);
  final secure = SecureSettingsImpl();
  final llmRepo = LlmProviderRepositoryImpl(db, secure);
  final articles = DriftArticleRepository(db);
  final netizens = NetizenRepositoryImpl(db);
  final llmClient = ScheduledLlmClient(HttpLlmClient());

  try {
    await jobs.releaseExpiredLeases();
    final open = await jobs.listJobsNeedingWork();
    if (open.isEmpty) return true;

    final pool = await netizens.getAll();
    final providers = await llmRepo.getProviders();
    final models = await llmRepo.getAllModels();

    var processed = 0;
    for (final job in open) {
      if (processed >= maxJobs) break;
      final article = await articles.get(job.articleId);
      if (article == null) {
        await jobs.cancelJobsForArticle(job.articleId);
        continue;
      }
      try {
        await engine.runJob(
          jobId: job.id,
          owner: _leaseOwnerWm,
          article: article,
          pool: pool,
          providers: providers,
          models: models,
          llmRepo: llmRepo,
          llmClient: llmClient,
        );
      } catch (e, st) {
        debugPrint('wepseed comment job ${job.id} failed: $e\n$st');
        await jobs.finalizeJob(job.id, lastError: e.toString());
      }
      processed++;
    }

    // More work left → schedule another one-off (best-effort).
    if (await jobs.hasWorkPending()) {
      await enqueueCommentJobDrain();
    }
    return true;
  } catch (e, st) {
    debugPrint('wepseed runCommentJobsDrain error: $e\n$st');
    return false;
  } finally {
    llmClient.dispose();
    articles.dispose();
    await db.close();
  }
}

/// Enqueue a one-off drain when durable jobs may need a process-dead recovery.
Future<void> enqueueCommentJobDrain() async {
  if (!Platform.isAndroid) return;
  try {
    await Workmanager().registerOneOffTask(
      kCommentJobUniqueName,
      kCommentJobTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
      tag: kCommentJobTag,
    );
  } catch (e, st) {
    debugPrint('wepseed enqueueCommentJobDrain failed: $e\n$st');
  }
}

/// Cold start: release stale leases, optionally drain in-process if work exists.
///
/// Prefer UI-side [CommentController.recoverPendingJobs] when Riverpod is up;
/// this path only ensures WM one-off is registered for kill-background cases.
Future<void> recoverCommentJobsOnColdStart() async {
  final db = AppDatabase();
  final jobs = CommentJobRepositoryImpl(db);
  try {
    await jobs.releaseExpiredLeases();
    if (await jobs.hasWorkPending()) {
      await enqueueCommentJobDrain();
    }
  } catch (e, st) {
    debugPrint('wepseed recoverCommentJobsOnColdStart failed: $e\n$st');
  } finally {
    await db.close();
  }
}

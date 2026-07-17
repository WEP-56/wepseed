import '../comments/comment_job_models.dart';
import '../models/models.dart';

/// Persistence for durable top-level comment generation jobs (D-task).
abstract class CommentJobRepository {
  /// Non-terminal job for [articleId], if any.
  Future<CommentJob?> getOpenJobForArticle(String articleId);

  Future<CommentJob?> getJob(String jobId);

  Future<List<CommentJobItem>> getItems(String jobId);

  /// Snapshot for UI hydration: open job + items for one article.
  Future<({CommentJob job, List<CommentJobItem> items})?>
  getOpenJobSnapshotForArticle(String articleId);

  /// Create a new job + pending items (sampling already done by caller).
  Future<CommentJob> createJob({
    required String articleId,
    required CommentTrigger trigger,
    required List<String> pickedNetizenIds,
    int maxAttempts = 3,
  });

  /// Re-open a failed job: pending/failed items become pending; status → pending.
  Future<CommentJob?> reopenFailedJob(String jobId);

  /// Claim lease on an open job. Returns null if another owner holds a valid lease.
  Future<CommentJob?> claimJob({
    required String jobId,
    required String owner,
    Duration lease = const Duration(minutes: 2),
  });

  /// Extend lease while still working.
  Future<void> heartbeat({
    required String jobId,
    required String owner,
    Duration lease = const Duration(minutes: 2),
  });

  Future<void> markItemRunning(String itemId);

  Future<void> markItemSucceeded({
    required String itemId,
    required String commentId,
  });

  Future<void> markItemSkipped(String itemId, {String? reason});

  Future<void> markItemFailed(String itemId, {String? error});

  /// Recompute job terminal state from items; bump attempt if still open.
  Future<CommentJob> finalizeJob(String jobId, {String? lastError});

  /// Expire stale leases (running → pending) so recovery can re-claim.
  Future<int> releaseExpiredLeases({DateTime? now});

  /// Open jobs that need work (pending, or running with expired lease).
  Future<List<CommentJob>> listJobsNeedingWork({DateTime? now});

  Future<void> cancelJobsForArticle(String articleId);

  Future<void> cancelAllJobs();

  /// Whether any open job still has non-terminal items.
  Future<bool> hasWorkPending();
}

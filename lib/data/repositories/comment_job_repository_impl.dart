import 'dart:convert';

import 'package:drift/drift.dart';

import '../comments/comment_job_models.dart';
import '../db/app_database.dart';
import '../models/models.dart';
import 'comment_job_repository.dart';

class CommentJobRepositoryImpl implements CommentJobRepository {
  CommentJobRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _openStatuses = ['pending', 'running'];
  static const _itemOpenStatuses = ['pending', 'running'];

  @override
  Future<CommentJob?> getOpenJobForArticle(String articleId) async {
    final row =
        await (_db.select(_db.commentJobs)
              ..where(
                (t) =>
                    t.articleId.equals(articleId) &
                    t.status.isIn(_openStatuses),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _mapJob(row);
  }

  @override
  Future<CommentJob?> getJob(String jobId) async {
    final row = await (_db.select(
      _db.commentJobs,
    )..where((t) => t.id.equals(jobId))).getSingleOrNull();
    return row == null ? null : _mapJob(row);
  }

  @override
  Future<List<CommentJobItem>> getItems(String jobId) async {
    final rows =
        await (_db.select(_db.commentJobItems)
              ..where((t) => t.jobId.equals(jobId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_mapItem).toList();
  }

  @override
  Future<({CommentJob job, List<CommentJobItem> items})?>
  getOpenJobSnapshotForArticle(String articleId) async {
    final job = await getOpenJobForArticle(articleId);
    if (job == null) return null;
    final items = await getItems(job.id);
    return (job: job, items: items);
  }

  @override
  Future<CommentJob> createJob({
    required String articleId,
    required CommentTrigger trigger,
    required List<String> pickedNetizenIds,
    int maxAttempts = 3,
  }) async {
    final now = DateTime.now();
    final jobId = 'cj_${articleId}_${now.microsecondsSinceEpoch}';
    await _db
        .into(_db.commentJobs)
        .insert(
          CommentJobsCompanion.insert(
            id: jobId,
            articleId: articleId,
            status: commentJobStatusToDb(CommentJobStatus.pending),
            trigger: commentTriggerToDb(trigger),
            pickedNetizenIdsJson: Value(jsonEncode(pickedNetizenIds)),
            maxAttempts: Value(maxAttempts),
            createdAt: now,
            updatedAt: now,
          ),
        );

    for (var i = 0; i < pickedNetizenIds.length; i++) {
      final netizenId = pickedNetizenIds[i];
      final itemId = 'cji_${jobId}_$i';
      await _db
          .into(_db.commentJobItems)
          .insert(
            CommentJobItemsCompanion.insert(
              id: itemId,
              jobId: jobId,
              netizenId: netizenId,
              status: commentJobItemStatusToDb(CommentJobItemStatus.pending),
              sortOrder: Value(i),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    return (await getJob(jobId))!;
  }

  @override
  Future<CommentJob?> reopenFailedJob(String jobId) async {
    final job = await getJob(jobId);
    if (job == null || job.status != CommentJobStatus.failed) return null;
    final now = DateTime.now();
    await (_db.update(_db.commentJobs)..where((t) => t.id.equals(jobId))).write(
      CommentJobsCompanion(
        status: Value(commentJobStatusToDb(CommentJobStatus.pending)),
        lastError: const Value(null),
        leaseOwner: const Value(null),
        leaseUntil: const Value(null),
        updatedAt: Value(now),
      ),
    );
    final items = await getItems(jobId);
    for (final item in items) {
      if (item.status == CommentJobItemStatus.succeeded ||
          item.status == CommentJobItemStatus.skipped) {
        continue;
      }
      await (_db.update(
        _db.commentJobItems,
      )..where((t) => t.id.equals(item.id))).write(
        CommentJobItemsCompanion(
          status: Value(commentJobItemStatusToDb(CommentJobItemStatus.pending)),
          lastError: const Value(null),
          updatedAt: Value(now),
        ),
      );
    }
    return getJob(jobId);
  }

  @override
  Future<CommentJob?> claimJob({
    required String jobId,
    required String owner,
    Duration lease = const Duration(minutes: 2),
  }) async {
    final now = DateTime.now();
    final job = await getJob(jobId);
    if (job == null || job.isTerminal) return null;

    final leaseOk =
        job.leaseOwner == null ||
        job.leaseOwner == owner ||
        job.leaseUntil == null ||
        !job.leaseUntil!.isAfter(now);
    if (!leaseOk) return null;

    final until = now.add(lease);
    await (_db.update(_db.commentJobs)..where((t) => t.id.equals(jobId))).write(
      CommentJobsCompanion(
        status: Value(commentJobStatusToDb(CommentJobStatus.running)),
        leaseOwner: Value(owner),
        leaseUntil: Value(until),
        attempt: Value(
          job.attempt + (job.status == CommentJobStatus.pending ? 1 : 0),
        ),
        updatedAt: Value(now),
      ),
    );
    return getJob(jobId);
  }

  @override
  Future<void> heartbeat({
    required String jobId,
    required String owner,
    Duration lease = const Duration(minutes: 2),
  }) async {
    final now = DateTime.now();
    final job = await getJob(jobId);
    if (job == null || job.leaseOwner != owner) return;
    await (_db.update(_db.commentJobs)..where((t) => t.id.equals(jobId))).write(
      CommentJobsCompanion(
        leaseUntil: Value(now.add(lease)),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> markItemRunning(String itemId) async {
    final now = DateTime.now();
    await (_db.update(
      _db.commentJobItems,
    )..where((t) => t.id.equals(itemId))).write(
      CommentJobItemsCompanion(
        status: Value(commentJobItemStatusToDb(CommentJobItemStatus.running)),
        attempt: const Value.absent(),
        updatedAt: Value(now),
      ),
    );
    // bump attempt
    final row = await (_db.select(
      _db.commentJobItems,
    )..where((t) => t.id.equals(itemId))).getSingleOrNull();
    if (row != null) {
      await (_db.update(
        _db.commentJobItems,
      )..where((t) => t.id.equals(itemId))).write(
        CommentJobItemsCompanion(
          attempt: Value(row.attempt + 1),
          updatedAt: Value(now),
        ),
      );
    }
  }

  @override
  Future<void> markItemSucceeded({
    required String itemId,
    required String commentId,
  }) async {
    final now = DateTime.now();
    await (_db.update(
      _db.commentJobItems,
    )..where((t) => t.id.equals(itemId))).write(
      CommentJobItemsCompanion(
        status: Value(commentJobItemStatusToDb(CommentJobItemStatus.succeeded)),
        commentId: Value(commentId),
        lastError: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> markItemSkipped(String itemId, {String? reason}) async {
    final now = DateTime.now();
    await (_db.update(
      _db.commentJobItems,
    )..where((t) => t.id.equals(itemId))).write(
      CommentJobItemsCompanion(
        status: Value(commentJobItemStatusToDb(CommentJobItemStatus.skipped)),
        lastError: Value(reason),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> markItemFailed(String itemId, {String? error}) async {
    final now = DateTime.now();
    await (_db.update(
      _db.commentJobItems,
    )..where((t) => t.id.equals(itemId))).write(
      CommentJobItemsCompanion(
        status: Value(commentJobItemStatusToDb(CommentJobItemStatus.failed)),
        lastError: Value(error),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<CommentJob> finalizeJob(String jobId, {String? lastError}) async {
    final items = await getItems(jobId);
    final now = DateTime.now();
    final open = items.where((i) => !i.isTerminal).toList();
    final job = (await getJob(jobId))!;

    if (open.isEmpty) {
      await (_db.update(
        _db.commentJobs,
      )..where((t) => t.id.equals(jobId))).write(
        CommentJobsCompanion(
          status: Value(commentJobStatusToDb(CommentJobStatus.completed)),
          lastError: Value(lastError),
          leaseOwner: const Value(null),
          leaseUntil: const Value(null),
          updatedAt: Value(now),
        ),
      );
      return (await getJob(jobId))!;
    }

    // Still open items: if job attempt exhausted, mark remaining failed + job failed.
    if (job.attempt >= job.maxAttempts) {
      for (final item in open) {
        await markItemFailed(item.id, error: lastError ?? 'max attempts');
      }
      await (_db.update(
        _db.commentJobs,
      )..where((t) => t.id.equals(jobId))).write(
        CommentJobsCompanion(
          status: Value(commentJobStatusToDb(CommentJobStatus.failed)),
          lastError: Value(lastError ?? 'max attempts'),
          leaseOwner: const Value(null),
          leaseUntil: const Value(null),
          updatedAt: Value(now),
        ),
      );
      return (await getJob(jobId))!;
    }

    // Leave as pending for recovery; drop lease.
    await (_db.update(_db.commentJobs)..where((t) => t.id.equals(jobId))).write(
      CommentJobsCompanion(
        status: Value(commentJobStatusToDb(CommentJobStatus.pending)),
        lastError: Value(lastError),
        leaseOwner: const Value(null),
        leaseUntil: const Value(null),
        updatedAt: Value(now),
      ),
    );
    // Reset stuck running items to pending.
    for (final item in open) {
      if (item.status == CommentJobItemStatus.running) {
        await (_db.update(
          _db.commentJobItems,
        )..where((t) => t.id.equals(item.id))).write(
          CommentJobItemsCompanion(
            status: Value(
              commentJobItemStatusToDb(CommentJobItemStatus.pending),
            ),
            updatedAt: Value(now),
          ),
        );
      }
    }
    return (await getJob(jobId))!;
  }

  @override
  Future<int> releaseExpiredLeases({DateTime? now}) async {
    final n = now ?? DateTime.now();
    // Drift DateTime compare can be flaky across sqlite bindings; filter in Dart.
    final running = await (_db.select(
      _db.commentJobs,
    )..where((t) => t.status.equals('running'))).get();
    final stuck = running
        .where((row) => row.leaseUntil != null && !row.leaseUntil!.isAfter(n))
        .toList();
    for (final row in stuck) {
      await (_db.update(
        _db.commentJobs,
      )..where((t) => t.id.equals(row.id))).write(
        CommentJobsCompanion(
          status: Value(commentJobStatusToDb(CommentJobStatus.pending)),
          leaseOwner: const Value(null),
          leaseUntil: const Value(null),
          updatedAt: Value(n),
        ),
      );
      final items =
          await (_db.select(_db.commentJobItems)..where(
                (t) => t.jobId.equals(row.id) & t.status.equals('running'),
              ))
              .get();
      for (final item in items) {
        await (_db.update(
          _db.commentJobItems,
        )..where((t) => t.id.equals(item.id))).write(
          CommentJobItemsCompanion(
            status: Value(
              commentJobItemStatusToDb(CommentJobItemStatus.pending),
            ),
            updatedAt: Value(n),
          ),
        );
      }
    }
    return stuck.length;
  }

  @override
  Future<List<CommentJob>> listJobsNeedingWork({DateTime? now}) async {
    await releaseExpiredLeases(now: now);
    final rows =
        await (_db.select(_db.commentJobs)
              ..where((t) => t.status.isIn(_openStatuses))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map(_mapJob).toList();
  }

  @override
  Future<void> cancelJobsForArticle(String articleId) async {
    final now = DateTime.now();
    final jobs =
        await (_db.select(_db.commentJobs)..where(
              (t) =>
                  t.articleId.equals(articleId) & t.status.isIn(_openStatuses),
            ))
            .get();
    for (final job in jobs) {
      await (_db.update(
        _db.commentJobs,
      )..where((t) => t.id.equals(job.id))).write(
        CommentJobsCompanion(
          status: Value(commentJobStatusToDb(CommentJobStatus.cancelled)),
          leaseOwner: const Value(null),
          leaseUntil: const Value(null),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.commentJobItems)..where(
            (t) => t.jobId.equals(job.id) & t.status.isIn(_itemOpenStatuses),
          ))
          .write(
            CommentJobItemsCompanion(
              status: Value(
                commentJobItemStatusToDb(CommentJobItemStatus.failed),
              ),
              lastError: const Value('cancelled'),
              updatedAt: Value(now),
            ),
          );
    }
  }

  @override
  Future<void> cancelAllJobs() async {
    final now = DateTime.now();
    await (_db.update(
      _db.commentJobs,
    )..where((t) => t.status.isIn(_openStatuses))).write(
      CommentJobsCompanion(
        status: Value(commentJobStatusToDb(CommentJobStatus.cancelled)),
        leaseOwner: const Value(null),
        leaseUntil: const Value(null),
        updatedAt: Value(now),
      ),
    );
    await (_db.update(
      _db.commentJobItems,
    )..where((t) => t.status.isIn(_itemOpenStatuses))).write(
      CommentJobItemsCompanion(
        status: Value(commentJobItemStatusToDb(CommentJobItemStatus.failed)),
        lastError: const Value('cancelled'),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<bool> hasWorkPending() async {
    final jobs = await listJobsNeedingWork();
    for (final job in jobs) {
      final items = await getItems(job.id);
      if (items.any((i) => !i.isTerminal)) return true;
    }
    return false;
  }

  CommentJob _mapJob(CommentJobRow row) {
    List<String> picked = const [];
    try {
      final decoded = jsonDecode(row.pickedNetizenIdsJson);
      if (decoded is List) {
        picked = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return CommentJob(
      id: row.id,
      articleId: row.articleId,
      status: commentJobStatusFromDb(row.status),
      trigger: commentTriggerFromDb(row.trigger),
      pickedNetizenIds: picked,
      attempt: row.attempt,
      maxAttempts: row.maxAttempts,
      lastError: row.lastError,
      leaseOwner: row.leaseOwner,
      leaseUntil: row.leaseUntil,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  CommentJobItem _mapItem(CommentJobItemRow row) {
    return CommentJobItem(
      id: row.id,
      jobId: row.jobId,
      netizenId: row.netizenId,
      status: commentJobItemStatusFromDb(row.status),
      attempt: row.attempt,
      lastError: row.lastError,
      commentId: row.commentId,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

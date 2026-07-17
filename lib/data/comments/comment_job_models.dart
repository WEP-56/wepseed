import '../models/models.dart';

/// Article-level durable comment generation job (D-task).
enum CommentJobStatus { pending, running, completed, failed, cancelled }

/// Per-netizen unit of work inside a [CommentJob].
enum CommentJobItemStatus { pending, running, succeeded, skipped, failed }

class CommentJob {
  const CommentJob({
    required this.id,
    required this.articleId,
    required this.status,
    required this.trigger,
    required this.pickedNetizenIds,
    required this.attempt,
    required this.maxAttempts,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
    this.leaseOwner,
    this.leaseUntil,
  });

  final String id;
  final String articleId;
  final CommentJobStatus status;
  final CommentTrigger trigger;
  final List<String> pickedNetizenIds;
  final int attempt;
  final int maxAttempts;
  final String? lastError;
  final String? leaseOwner;
  final DateTime? leaseUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTerminal =>
      status == CommentJobStatus.completed ||
      status == CommentJobStatus.failed ||
      status == CommentJobStatus.cancelled;

  bool get isOpen =>
      status == CommentJobStatus.pending || status == CommentJobStatus.running;
}

class CommentJobItem {
  const CommentJobItem({
    required this.id,
    required this.jobId,
    required this.netizenId,
    required this.status,
    required this.attempt,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
    this.commentId,
  });

  final String id;
  final String jobId;
  final String netizenId;
  final CommentJobItemStatus status;
  final int attempt;
  final String? lastError;
  final String? commentId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTerminal =>
      status == CommentJobItemStatus.succeeded ||
      status == CommentJobItemStatus.skipped ||
      status == CommentJobItemStatus.failed;
}

String commentJobStatusToDb(CommentJobStatus s) => s.name;

CommentJobStatus commentJobStatusFromDb(String raw) {
  return CommentJobStatus.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => CommentJobStatus.pending,
  );
}

String commentJobItemStatusToDb(CommentJobItemStatus s) => s.name;

CommentJobItemStatus commentJobItemStatusFromDb(String raw) {
  return CommentJobItemStatus.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => CommentJobItemStatus.pending,
  );
}

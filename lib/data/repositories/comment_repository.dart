import '../llm/llm_client.dart';
import '../models/models.dart';
import 'llm_provider_repository.dart';

abstract class CommentRepository {
  Stream<List<Comment>> watchForArticle(String articleId);

  /// Generate top-level comments once per article (if empty).
  ///
  /// Real LLM only when [llmClient] + provider Key resolve. No Key → skip
  /// (no mock filler). [forceMock] kept for tests only.
  Future<CommentGenerationResult> ensureGenerated(
    String articleId, {
    required CommentTrigger trigger,
    required List<Netizen> pool,
    required Article article,
    List<LlmProvider> providers = const [],
    List<LlmModel> models = const [],
    LlmProviderRepository? llmRepo,
    LlmClient? llmClient,
    bool forceMock = false,
    void Function(CommentGenerationProgress progress)? onProgress,
  });

  Future<CommentReplyResult> addUserReply({
    required String articleId,
    required String parentId,
    required String text,
    required List<Netizen> pool,
    required Article article,
    List<LlmProvider> providers = const [],
    List<LlmModel> models = const [],
    LlmProviderRepository? llmRepo,
    LlmClient? llmClient,
    bool forceMock = false,
    void Function(String netizenName, LlmQueuePhase phase)? onProgress,
  });

  /// Wipe all stored comments (clear Phase C mock leftovers).
  Future<void> clearAll();

  /// Wipe comments for one article (re-generate on next open).
  Future<void> clearForArticle(String articleId);
}

class CommentGenerationProgress {
  const CommentGenerationProgress({
    required this.netizenName,
    required this.phase,
    required this.total,
  });

  final String netizenName;
  final LlmQueuePhase phase;
  final int total;
}

class CommentGenerationResult {
  const CommentGenerationResult({
    required this.total,
    required this.generated,
    this.alreadyPresent = false,
  });

  final int total;
  final int generated;
  final bool alreadyPresent;
  int get failed => total - generated;
}

class CommentReplyResult {
  const CommentReplyResult({this.netizenName, this.replied = false});

  final String? netizenName;
  final bool replied;
}

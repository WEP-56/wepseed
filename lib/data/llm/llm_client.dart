import '../models/models.dart';

enum LlmQueuePhase { queued, running, completed, failed }

/// Chat message for LLM requests.
class LlmMessage {
  const LlmMessage({required this.role, required this.content});

  /// `system` | `user` | `assistant`
  final String role;
  final String content;
}

/// Resolved endpoint + credentials for one completion call.
class LlmRequestConfig {
  const LlmRequestConfig({
    this.providerId,
    required this.protocol,
    required this.baseUrl,
    required this.modelId,
    required this.apiKey,
    this.timeout = const Duration(seconds: 45),
    this.maxTokens = 512,
    this.temperature = 0.7,
    this.maxConcurrent = 1,
    this.requestsPerMinute = 10,
    this.onQueuePhase,
  });

  final String? providerId;
  final LlmProtocol protocol;
  final String baseUrl;
  final String modelId;
  final String apiKey;
  final Duration timeout;
  final int maxTokens;
  final double temperature;
  final int maxConcurrent;
  final int requestsPerMinute;
  final void Function(LlmQueuePhase phase)? onQueuePhase;

  LlmRequestConfig copyWith({
    void Function(LlmQueuePhase phase)? onQueuePhase,
  }) {
    return LlmRequestConfig(
      providerId: providerId,
      protocol: protocol,
      baseUrl: baseUrl,
      modelId: modelId,
      apiKey: apiKey,
      timeout: timeout,
      maxTokens: maxTokens,
      temperature: temperature,
      maxConcurrent: maxConcurrent,
      requestsPerMinute: requestsPerMinute,
      onQueuePhase: onQueuePhase ?? this.onQueuePhase,
    );
  }
}

/// Thrown on HTTP / protocol failures (user-facing via [message]).
class LlmException implements Exception {
  LlmException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => message;
}

/// Phase D: multi-protocol LLM HTTP client.
abstract class LlmClient {
  /// Non-streaming completion; returns full assistant text.
  Future<String> complete(List<LlmMessage> messages, LlmRequestConfig config);

  /// Streaming tokens (optional protocols may yield once).
  Stream<String> completeStream(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  );
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/llm/llm_client.dart';
import 'package:wepseed/data/llm/scheduled_llm_client.dart';
import 'package:wepseed/data/models/models.dart';

void main() {
  const messages = [LlmMessage(role: 'user', content: '评论')];

  test('same provider respects maxConcurrent', () async {
    final inner = _TrackingClient(delay: const Duration(milliseconds: 15));
    final client = ScheduledLlmClient(inner);
    const config = LlmRequestConfig(
      providerId: 'p1',
      protocol: LlmProtocol.openaiChatCompletions,
      baseUrl: 'https://api.example.com/v1',
      modelId: 'model',
      apiKey: 'key',
      maxConcurrent: 1,
      requestsPerMinute: 100,
    );

    final results = await Future.wait([
      client.complete(messages, config),
      client.complete(messages, config),
      client.complete(messages, config),
    ]);

    expect(results, ['ok', 'ok', 'ok']);
    expect(inner.maxActive, 1);
    client.dispose();
  });

  test('same provider waits when RPM window is exhausted', () async {
    final inner = _TrackingClient();
    final client = ScheduledLlmClient(
      inner,
      rateWindow: const Duration(milliseconds: 40),
    );
    const config = LlmRequestConfig(
      providerId: 'p1',
      protocol: LlmProtocol.openaiChatCompletions,
      baseUrl: 'https://api.example.com/v1',
      modelId: 'model',
      apiKey: 'key',
      maxConcurrent: 3,
      requestsPerMinute: 2,
    );

    final stopwatch = Stopwatch()..start();
    await Future.wait([
      client.complete(messages, config),
      client.complete(messages, config),
      client.complete(messages, config),
    ]);

    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(30));
    expect(inner.calls, 3);
    client.dispose();
  });
}

class _TrackingClient implements LlmClient {
  _TrackingClient({this.delay = Duration.zero});

  final Duration delay;
  int active = 0;
  int maxActive = 0;
  int calls = 0;

  @override
  Future<String> complete(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async {
    calls++;
    active++;
    if (active > maxActive) maxActive = active;
    await Future<void>.delayed(delay);
    active--;
    return 'ok';
  }

  @override
  Stream<String> completeStream(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async* {
    yield await complete(messages, config);
  }
}

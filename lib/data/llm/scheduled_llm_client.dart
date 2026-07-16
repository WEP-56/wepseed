import 'dart:async';
import 'dart:collection';

import 'llm_client.dart';

/// App-process request coordinator shared by every netizen and article.
///
/// Requests using the same provider share one concurrency gate and one
/// sliding-window RPM budget. This prevents separate screens/replies from
/// accidentally bypassing provider limits.
class ScheduledLlmClient implements LlmClient {
  ScheduledLlmClient(
    this._inner, {
    this.rateWindow = const Duration(minutes: 1),
  });

  final LlmClient _inner;
  final Duration rateWindow;
  final Map<String, _ProviderLane> _lanes = {};
  bool _disposed = false;

  @override
  Future<String> complete(List<LlmMessage> messages, LlmRequestConfig config) {
    if (_disposed) {
      return Future.error(LlmException('评论请求队列已关闭'));
    }
    final key =
        config.providerId ??
        '${config.protocol.name}|${config.baseUrl.trim().toLowerCase()}';
    final lane = _lanes.putIfAbsent(
      key,
      () => _ProviderLane(rateWindow: rateWindow),
    );
    return lane.schedule(
      config: config,
      run: () => _inner.complete(messages, config),
    );
  }

  @override
  Stream<String> completeStream(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async* {
    yield await complete(messages, config);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final lane in _lanes.values) {
      lane.dispose();
    }
    _lanes.clear();
  }
}

class _ProviderLane {
  _ProviderLane({required this.rateWindow});

  final Duration rateWindow;
  final Queue<_QueuedRequest> _queue = Queue();
  final Queue<DateTime> _starts = Queue();
  int _active = 0;
  Timer? _wakeTimer;
  bool _disposed = false;

  Future<String> schedule({
    required LlmRequestConfig config,
    required Future<String> Function() run,
  }) {
    if (_disposed) return Future.error(LlmException('评论请求队列已关闭'));
    final completer = Completer<String>();
    _queue.add(_QueuedRequest(config, run, completer));
    config.onQueuePhase?.call(LlmQueuePhase.queued);
    _pump();
    return completer.future;
  }

  void _pump() {
    if (_disposed || _queue.isEmpty) return;
    final now = DateTime.now();
    while (_starts.isNotEmpty && !now.isBefore(_starts.first.add(rateWindow))) {
      _starts.removeFirst();
    }

    final next = _queue.first;
    final concurrency = next.config.maxConcurrent.clamp(1, 8);
    final rpm = next.config.requestsPerMinute.clamp(1, 1000);
    if (_active >= concurrency) return;
    if (_starts.length >= rpm) {
      final delay = _starts.first.add(rateWindow).difference(now);
      _wakeTimer?.cancel();
      _wakeTimer = Timer(delay.isNegative ? Duration.zero : delay, _pump);
      return;
    }

    final request = _queue.removeFirst();
    _starts.addLast(now);
    _active++;
    request.config.onQueuePhase?.call(LlmQueuePhase.running);
    Future.sync(request.run)
        .then(
          (value) {
            request.config.onQueuePhase?.call(LlmQueuePhase.completed);
            request.completer.complete(value);
          },
          onError: (Object error, StackTrace stackTrace) {
            request.config.onQueuePhase?.call(LlmQueuePhase.failed);
            request.completer.completeError(error, stackTrace);
          },
        )
        .whenComplete(() {
          _active--;
          _pump();
        });

    // Fill the configured concurrency slots while RPM budget remains.
    _pump();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _wakeTimer?.cancel();
    while (_queue.isNotEmpty) {
      _queue.removeFirst().completer.completeError(
        LlmException('应用已关闭，评论请求已取消'),
      );
    }
  }
}

class _QueuedRequest {
  _QueuedRequest(this.config, this.run, this.completer);

  final LlmRequestConfig config;
  final Future<String> Function() run;
  final Completer<String> completer;
}

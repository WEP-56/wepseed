import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'llm_client.dart';
import 'llm_text_sanitize.dart';

/// Real HTTP client for OpenAI-compatible chat/completions, Responses, and Anthropic.
class HttpLlmClient implements LlmClient {
  HttpLlmClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<String> complete(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async {
    final buf = StringBuffer();
    await for (final chunk in completeStream(messages, config)) {
      buf.write(chunk);
    }
    final raw = buf.toString().trim();
    if (raw.isEmpty) {
      throw LlmException('模型返回为空');
    }
    _validateModelText(raw);
    final text = sanitizeLlmCommentText(raw);
    if (text.isEmpty) {
      throw LlmException('模型只返回了思考过程，没有可用评论');
    }
    return text;
  }

  @override
  Stream<String> completeStream(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async* {
    // Phase D v1: non-stream HTTP then single yield (stream UI can plug later).
    final text = await switch (config.protocol) {
      LlmProtocol.openaiChatCompletions => _openaiChatCompletions(
        messages,
        config,
      ),
      LlmProtocol.openaiResponses => _openaiResponses(messages, config),
      LlmProtocol.anthropicMessages => _anthropicMessages(messages, config),
    };
    if (text.isNotEmpty) yield text;
  }

  Future<String> _openaiChatCompletions(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async {
    final uri = _join(config.baseUrl, 'chat/completions');
    final body = {
      'model': config.modelId,
      'messages': [
        for (final m in messages) {'role': m.role, 'content': m.content},
      ],
      'max_tokens': config.maxTokens,
      'temperature': config.temperature,
    };
    final res = await _postJson(
      uri,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
      timeout: config.timeout,
    );
    final responseBody = _decodeUtf8Body(res);
    final data = _decodeMap(res, responseBody);
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw LlmException(
        '响应无 choices',
        statusCode: res.statusCode,
        body: responseBody,
      );
    }
    final msg = choices.first is Map ? choices.first['message'] : null;
    final content = msg is Map ? msg['content'] : null;
    if (content is String) return content.trim();
    // Some proxies return content as list of parts.
    if (content is List) {
      return content
          .map((p) {
            if (p is Map && p['text'] is String) return p['text'] as String;
            if (p is String) return p;
            return '';
          })
          .join()
          .trim();
    }
    throw LlmException(
      '无法解析回复内容',
      statusCode: res.statusCode,
      body: responseBody,
    );
  }

  Future<String> _openaiResponses(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async {
    final uri = _join(config.baseUrl, 'responses');
    // Flatten system + user into input items.
    final input = <Map<String, dynamic>>[];
    for (final m in messages) {
      if (m.role == 'system') {
        input.add({
          'role': 'system',
          'content': [
            {'type': 'input_text', 'text': m.content},
          ],
        });
      } else {
        input.add({
          'role': m.role == 'assistant' ? 'assistant' : 'user',
          'content': [
            {
              'type': m.role == 'assistant' ? 'output_text' : 'input_text',
              'text': m.content,
            },
          ],
        });
      }
    }
    final body = {
      'model': config.modelId,
      'input': input,
      'max_output_tokens': config.maxTokens,
      'temperature': config.temperature,
    };
    final res = await _postJson(
      uri,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
      timeout: config.timeout,
    );
    final responseBody = _decodeUtf8Body(res);
    final data = _decodeMap(res, responseBody);
    // Prefer output_text convenience field if present.
    final outputText = data['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }
    final output = data['output'];
    if (output is List) {
      final buf = StringBuffer();
      for (final item in output) {
        if (item is! Map) continue;
        final content = item['content'];
        if (content is! List) continue;
        for (final part in content) {
          if (part is Map &&
              (part['type'] == 'output_text' || part['type'] == 'text') &&
              part['text'] is String) {
            buf.write(part['text']);
          }
        }
      }
      final t = buf.toString().trim();
      if (t.isNotEmpty) return t;
    }
    throw LlmException(
      '无法解析 Responses 回复',
      statusCode: res.statusCode,
      body: responseBody,
    );
  }

  Future<String> _anthropicMessages(
    List<LlmMessage> messages,
    LlmRequestConfig config,
  ) async {
    final uri = _join(config.baseUrl, 'messages');
    String? system;
    final apiMessages = <Map<String, dynamic>>[];
    for (final m in messages) {
      if (m.role == 'system') {
        system = system == null ? m.content : '$system\n\n${m.content}';
        continue;
      }
      apiMessages.add({
        'role': m.role == 'assistant' ? 'assistant' : 'user',
        'content': m.content,
      });
    }
    if (apiMessages.isEmpty) {
      apiMessages.add({'role': 'user', 'content': '请开始。'});
    }
    final body = <String, dynamic>{
      'model': config.modelId,
      'max_tokens': config.maxTokens,
      'messages': apiMessages,
      if (system != null && system.isNotEmpty) 'system': system,
    };
    final res = await _postJson(
      uri,
      headers: {
        'x-api-key': config.apiKey,
        'anthropic-version': '2023-06-01',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
      timeout: config.timeout,
    );
    final responseBody = _decodeUtf8Body(res);
    final data = _decodeMap(res, responseBody);
    final content = data['content'];
    if (content is List) {
      final buf = StringBuffer();
      for (final part in content) {
        if (part is Map && part['type'] == 'text' && part['text'] is String) {
          buf.write(part['text']);
        }
      }
      final t = buf.toString().trim();
      if (t.isNotEmpty) return t;
    }
    throw LlmException(
      '无法解析 Anthropic 回复',
      statusCode: res.statusCode,
      body: responseBody,
    );
  }

  static const _maxAttempts = 3; // 1 initial + 2 retries

  Future<http.Response> _postJson(
    Uri uri, {
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    required Duration timeout,
  }) async {
    final encoded = jsonEncode(body);
    Object? lastError;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      if (attempt > 0) {
        final delayMs = attempt == 1 ? 400 : 1200;
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
      try {
        final res = await _client
            .post(uri, headers: headers, body: encoded)
            .timeout(timeout);
        if (res.statusCode >= 200 && res.statusCode < 300) return res;

        final responseBody = _decodeUtf8Body(res);
        final retryable = res.statusCode == 429 || res.statusCode >= 500;
        final err = LlmException(
          _friendlyError(res.statusCode, responseBody),
          statusCode: res.statusCode,
          body: responseBody,
        );
        if (!retryable || attempt >= _maxAttempts - 1) throw err;

        // Honor Retry-After seconds when present (429).
        final retryAfter = res.headers['retry-after'];
        final secs = int.tryParse(retryAfter ?? '');
        if (secs != null && secs > 0 && secs <= 30) {
          await Future<void>.delayed(Duration(seconds: secs));
        }
        lastError = err;
        continue;
      } on TimeoutException {
        lastError = LlmException('请求超时，请稍后重试');
        if (attempt >= _maxAttempts - 1) throw lastError;
      } on LlmException {
        rethrow;
      } catch (e) {
        lastError = LlmException('网络错误：$e');
        if (attempt >= _maxAttempts - 1) throw lastError;
      }
    }
    throw lastError is LlmException ? lastError : LlmException('请求失败');
  }

  /// JSON APIs are UTF-8 by specification, but many compatible gateways omit
  /// `charset`. `Response.body` may then use a legacy fallback and corrupt CJK
  /// before JSON parsing, so always decode the original bytes explicitly.
  String _decodeUtf8Body(http.Response res) {
    try {
      return utf8.decode(res.bodyBytes, allowMalformed: false);
    } on FormatException {
      throw LlmException('模型服务返回了无效 UTF-8 数据', statusCode: res.statusCode);
    }
  }

  Map<String, dynamic> _decodeMap(http.Response res, String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      /* fall through */
    }
    throw LlmException(
      '响应不是 JSON',
      statusCode: res.statusCode,
      body: responseBody,
    );
  }

  String _friendlyError(int statusCode, String responseBody) {
    String? apiMsg;
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map) {
        final err = decoded['error'];
        if (err is Map && err['message'] is String) {
          apiMsg = err['message'] as String;
        } else if (decoded['message'] is String) {
          apiMsg = decoded['message'] as String;
        }
      }
    } catch (_) {
      /* ignore */
    }
    final detail = apiMsg != null && apiMsg.isNotEmpty ? '：$apiMsg' : '';
    return switch (statusCode) {
      401 || 403 => 'API Key 无效或无权访问$detail',
      404 => '接口地址不正确（404）$detail',
      429 => '请求过于频繁，请稍后再试$detail',
      >= 500 => '模型服务暂时不可用（$statusCode）$detail',
      _ => '请求失败（$statusCode）$detail',
    };
  }

  void _validateModelText(String text) {
    var invalid = 0;
    for (final rune in text.runes) {
      final isReplacement = rune == 0xfffd || rune == 0xfffc;
      final isControl =
          (rune < 0x20 && rune != 0x09 && rune != 0x0a && rune != 0x0d) ||
          (rune >= 0x7f && rune <= 0x9f);
      if (isReplacement || isControl) invalid++;
    }
    if (invalid > 0) {
      throw LlmException('模型返回包含无法识别的乱码，请重试');
    }
  }

  /// Join base URL with path; handles trailing slash and full path bases.
  static Uri _join(String baseUrl, String path) {
    var base = baseUrl.trim();
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    // If user already pointed at .../v1/chat/completions, use as-is for chat.
    if (base.endsWith('/$path') || base.endsWith(path)) {
      return Uri.parse(base);
    }
    // Common: https://api.openai.com/v1
    return Uri.parse('$base/$path');
  }
}

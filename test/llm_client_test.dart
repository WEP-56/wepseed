import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wepseed/data/llm/http_llm_client.dart';
import 'package:wepseed/data/llm/llm_client.dart';
import 'package:wepseed/data/llm/llm_prompt.dart';
import 'package:wepseed/data/models/models.dart';

void main() {
  test('HttpLlmClient openai chat/completions parses content', () async {
    final mock = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://api.example.com/v1/chat/completions',
      );
      expect(request.headers['Authorization'], 'Bearer sk-test');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['model'], 'gpt-test');
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'role': 'assistant', 'content': '这是一条短评。'},
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = HttpLlmClient(client: mock);
    final text = await client.complete(
      const [
        LlmMessage(role: 'system', content: '你是网友'),
        LlmMessage(role: 'user', content: '评一下'),
      ],
      const LlmRequestConfig(
        protocol: LlmProtocol.openaiChatCompletions,
        baseUrl: 'https://api.example.com/v1',
        modelId: 'gpt-test',
        apiKey: 'sk-test',
      ),
    );
    expect(text, '这是一条短评。');
  });

  test('HttpLlmClient decodes UTF-8 when response omits charset', () async {
    final payload = jsonEncode({
      'choices': [
        {
          'message': {'role': 'assistant', 'content': '中文评论不应该乱码。'},
        },
      ],
    });
    final mock = MockClient((request) async {
      expect(request.headers['content-type'], contains('charset=utf-8'));
      expect(request.headers['accept'], 'application/json');
      return http.Response.bytes(
        utf8.encode(payload),
        200,
        // This reproduces gateways that omit both JSON media type and charset.
        headers: {'content-type': 'application/octet-stream'},
      );
    });

    final client = HttpLlmClient(client: mock);
    final text = await client.complete(
      const [LlmMessage(role: 'user', content: '评一下')],
      const LlmRequestConfig(
        protocol: LlmProtocol.openaiChatCompletions,
        baseUrl: 'https://api.example.com/v1',
        modelId: 'gpt-test',
        apiKey: 'sk-test',
      ),
    );

    expect(text, '中文评论不应该乱码。');
  });

  test(
    'HttpLlmClient rejects replacement characters before persistence',
    () async {
      final mock = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'choices': [
                {
                  'message': {'role': 'assistant', 'content': '损坏�评论'},
                },
              ],
            }),
          ),
          200,
        );
      });
      final client = HttpLlmClient(client: mock);

      expect(
        () => client.complete(
          const [LlmMessage(role: 'user', content: '评一下')],
          const LlmRequestConfig(
            protocol: LlmProtocol.openaiChatCompletions,
            baseUrl: 'https://api.example.com/v1',
            modelId: 'gpt-test',
            apiKey: 'sk-test',
          ),
        ),
        throwsA(
          isA<LlmException>().having(
            (error) => error.message,
            'message',
            contains('乱码'),
          ),
        ),
      );
    },
  );

  test('HttpLlmClient surfaces 401 as friendly error', () async {
    final mock = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'error': {'message': 'Incorrect API key'},
        }),
        401,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = HttpLlmClient(client: mock);
    expect(
      () => client.complete(
        const [LlmMessage(role: 'user', content: 'hi')],
        const LlmRequestConfig(
          protocol: LlmProtocol.openaiChatCompletions,
          baseUrl: 'https://api.example.com/v1',
          modelId: 'gpt-test',
          apiKey: 'bad',
        ),
      ),
      throwsA(isA<LlmException>()),
    );
  });

  test('HttpLlmClient retries 500 then succeeds', () async {
    var calls = 0;
    final mock = MockClient((request) async {
      calls++;
      if (calls == 1) {
        return http.Response('{"error":{"message":"busy"}}', 500);
      }
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'role': 'assistant', 'content': '重试后成功'},
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = HttpLlmClient(client: mock);
    final text = await client.complete(
      const [LlmMessage(role: 'user', content: 'hi')],
      const LlmRequestConfig(
        protocol: LlmProtocol.openaiChatCompletions,
        baseUrl: 'https://api.example.com/v1',
        modelId: 'gpt-test',
        apiKey: 'sk',
        timeout: Duration(seconds: 5),
      ),
    );
    expect(text, '重试后成功');
    expect(calls, 2);
  });

  test('HttpLlmClient does not retry 401', () async {
    var calls = 0;
    final mock = MockClient((request) async {
      calls++;
      return http.Response(
        jsonEncode({
          'error': {'message': 'bad key'},
        }),
        401,
      );
    });
    final client = HttpLlmClient(client: mock);
    await expectLater(
      client.complete(
        const [LlmMessage(role: 'user', content: 'hi')],
        const LlmRequestConfig(
          protocol: LlmProtocol.openaiChatCompletions,
          baseUrl: 'https://api.example.com/v1',
          modelId: 'gpt-test',
          apiKey: 'bad',
        ),
      ),
      throwsA(isA<LlmException>()),
    );
    expect(calls, 1);
  });

  test('netizenTopLevelMessages includes title and system hint', () {
    const netizen = Netizen(
      id: 'n1',
      name: '总结君',
      systemHint: '三条要点',
      styleLabel: '干货摘要',
    );
    final article = Article(
      id: 'a1',
      source: const FeedSource(id: 'f1', name: '源', domain: 'example.com'),
      title: '测试标题',
      summary: '摘要一段',
      body: '正文更长一些用于摘录。',
      publishedAt: DateTime(2026, 7, 1),
    );
    final msgs = netizenTopLevelMessages(netizen: netizen, article: article);
    expect(msgs.length, 2);
    expect(msgs.first.role, 'system');
    expect(msgs.first.content, contains('WEPSEED'));
    expect(msgs.first.content, contains('评论区'));
    expect(msgs.first.content, contains('总结君'));
    expect(msgs.first.content, contains('三条要点'));
    expect(msgs.first.content, contains('顶层评论'));
    expect(msgs.last.role, 'user');
    expect(msgs.last.content, contains('测试标题'));
  });

  test('HttpLlmClient anthropic messages parses text blocks', () async {
    final mock = MockClient((request) async {
      expect(request.url.path, endsWith('/messages'));
      expect(request.headers['x-api-key'], 'ak-test');
      expect(request.headers['anthropic-version'], isNotEmpty);
      return http.Response(
        jsonEncode({
          'content': [
            {'type': 'text', 'text': '冷淡一句。'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = HttpLlmClient(client: mock);
    final text = await client.complete(
      const [
        LlmMessage(role: 'system', content: '少说话'),
        LlmMessage(role: 'user', content: '评'),
      ],
      const LlmRequestConfig(
        protocol: LlmProtocol.anthropicMessages,
        baseUrl: 'https://api.anthropic.com/v1',
        modelId: 'claude-test',
        apiKey: 'ak-test',
      ),
    );
    expect(text, '冷淡一句。');
  });
}

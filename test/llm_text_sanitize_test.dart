import 'package:flutter_test/flutter_test.dart';
import 'package:wepseed/data/llm/llm_text_sanitize.dart';

void main() {
  test('strips closed think blocks and keeps final comment', () {
    final out = sanitizeLlmCommentText(
      '<think>先分析标题再写</think>\n信息量挺大的一期，开源动作值得跟。',
    );
    expect(out, '信息量挺大的一期，开源动作值得跟。');
  });

  test('drops pure planning monologue like screenshot 总结君', () {
    final out = sanitizeLlmCommentText('先快速核对原文要点，确保摘要准确。');
    expect(out, isEmpty);
  });

  test('drops 先把…再下嘴 planning', () {
    final out = sanitizeLlmCommentText('先把早报摸清楚，再下嘴。');
    expect(out, isEmpty);
  });

  test('strips toolcall noise lines', () {
    final out = sanitizeLlmCommentText(
      '开源动作挺干脆。\n'
      '0xfntoolcall.open_page:url:https://daily.juya.uk/issues/2026-07-16/',
    );
    expect(out, '开源动作挺干脆。');
    expect(out.contains('toolcall'), isFalse);
  });

  test('keeps real multi-sentence netizen take', () {
    const real =
        '信息量挺大的一期。开源动作多——Grok Build 源码公开，对开发者和隐私都更友好。';
    expect(sanitizeLlmCommentText(real), real);
  });

  test('uses final answer marker body', () {
    final out = sanitizeLlmCommentText(
      '思考：先读完再评\n\n最终回复：这期早报值得扫一眼标题。',
    );
    expect(out, '这期早报值得扫一眼标题。');
  });
}

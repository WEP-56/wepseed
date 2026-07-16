/// Strip model "thinking" / tool-call leakage so only the final netizen
/// comment is stored and shown.
///
/// Handles common gateway shapes:
/// - `<think>…</think>`, `<thinking>…</thinking>`, `…</think>` leftovers
/// - Markdown `**思考过程**` / `思考：` style preambles
/// - Tool / function call dumps (`toolcall`, `open_page`, `0xfn…`)
/// - Reasoning then final answer split by blank lines
String sanitizeLlmCommentText(String raw) {
  var text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  if (text.isEmpty) return '';

  // Closed XML-ish thinking blocks (greedy per block).
  text = text.replaceAll(
    RegExp(
      r'<(think|thinking|reasoning|reflection)[^>]*>[\s\S]*?</\1\s*>',
      caseSensitive: false,
    ),
    '',
  );

  // Unclosed open tags: drop from open tag to end-of-block or EOF, then keep
  // any trailing text after a blank line if present — but prefer stripping
  // the whole prefix when the open tag is at the start.
  text = text.replaceAll(
    RegExp(
      r'<(think|thinking|reasoning|reflection)[^>]*>[\s\S]*?(?=\n\n|\Z)',
      caseSensitive: false,
    ),
    '',
  );

  // Orphan close tags alone (models sometimes only emit closing).
  text = text.replaceAll(
    RegExp(r'</\s*(think|thinking|reasoning|reflection)\s*>', caseSensitive: false),
    '',
  );

  // Explicit "final answer" markers: keep only after the last marker.
  final finalMarkers = RegExp(
    r'(?:^|\n)\s*(?:'
    r'最终回复|最终评论|最终答案|正式评论|输出评论|最终输出|'
    r'Final\s*Answer|Final\s*Response|Answer\s*:|'
    r'【最终】|【回复】'
    r')\s*[:：]?\s*',
    caseSensitive: false,
  );
  final finalMatches = finalMarkers.allMatches(text).toList();
  if (finalMatches.isNotEmpty) {
    final last = finalMatches.last;
    final after = text.substring(last.end).trim();
    if (after.isNotEmpty) text = after;
  }

  // Chinese / EN "thinking process" headers: drop that section if a later
  // body remains; otherwise strip the header line only.
  text = _stripLabeledPreamble(text);

  // Tool-call / function-call leakage (seen with agentic Grok-style proxies).
  text = text.replaceAll(
    RegExp(
      r'(?:'
      r'0xfn\w*\.?|'
      r'tool[_ ]?call\.?|'
      r'function[_ ]?call\.?|'
      r'open_page\s*:|'
      r'browser_open\s*:|'
      r'invoke\s+\w+\s*\('
      r')[^\n]*',
      caseSensitive: false,
    ),
    '',
  );

  // Lines that are pure tool / protocol noise.
  final cleanedLines = <String>[];
  for (final line in text.split('\n')) {
    final t = line.trim();
    if (t.isEmpty) {
      cleanedLines.add('');
      continue;
    }
    if (_isNoiseLine(t)) continue;
    cleanedLines.add(line);
  }
  text = cleanedLines.join('\n');

  // Collapse excess blank lines.
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

  // If still looks like pure internal monologue, try last paragraph only when
  // earlier parts match thinking heuristics.
  if (_looksLikeThinkingOnly(text)) {
    final parts = text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      final last = parts.last;
      if (!_looksLikeThinkingOnly(last) && last.length >= 8) {
        text = last;
      }
    }
  }

  text = text.trim();
  // Drop pure planning monologues so callers skip insert (no fake comment).
  if (_looksLikeThinkingOnly(text)) return '';
  return text;
}

String _stripLabeledPreamble(String text) {
  final header = RegExp(
    r'^(?:'
    r'\*{0,2}思考(?:过程|路径)?\*{0,2}|'
    r'\*{0,2}推理(?:过程)?\*{0,2}|'
    r'\*{0,2}内心独白\*{0,2}|'
    r'\*{0,2}分析\*{0,2}|'
    r'Thinking(?:\s*Process)?|'
    r'Reasoning(?:\s*Process)?|'
    r'Chain\s*of\s*Thought'
    r')\s*[:：]?\s*$',
    caseSensitive: false,
    multiLine: true,
  );

  final m = header.firstMatch(text);
  if (m == null) {
    // Inline "思考：" on first line with body after blank line.
    final inline = RegExp(
      r'^(?:思考|推理|分析)\s*[:：]\s*([\s\S]+?)(?:\n\s*\n+)([\s\S]+)$',
    );
    final im = inline.firstMatch(text);
    if (im != null) {
      final body = im.group(2)?.trim() ?? '';
      if (body.isNotEmpty) return body;
    }
    return text;
  }

  // Drop from header through next blank line, keep rest; if nothing left,
  // drop only the header line.
  final afterHeader = text.substring(m.end).trimLeft();
  final split = RegExp(r'\n\s*\n').firstMatch(afterHeader);
  if (split != null) {
    final body = afterHeader.substring(split.end).trim();
    if (body.isNotEmpty) return body;
  }
  // No blank split — remove the header line only.
  return (text.substring(0, m.start) + afterHeader).trim();
}

bool _isNoiseLine(String t) {
  final lower = t.toLowerCase();
  if (lower.contains('toolcall') ||
      lower.contains('tool_call') ||
      lower.contains('function_call') ||
      lower.contains('0xfn') ||
      lower.startsWith('open_page') ||
      lower.startsWith('url:http') && t.length > 80) {
    return true;
  }
  // Bare tool URL dumps without surrounding prose.
  if (RegExp(r'^https?://\S+$').hasMatch(t) && t.contains('tool')) {
    return true;
  }
  return false;
}

bool _looksLikeThinkingOnly(String text) {
  final t = text.trim();
  if (t.isEmpty) return true;
  final lower = t.toLowerCase();

  // Classic planning openers seen in agentic models (screenshot cases).
  if (RegExp(
    r'^(先快速|先把|先核对|先看|先读|先理|先摸|确保|我先|让我|首先|接下来我|开始分析)',
  ).hasMatch(t)) {
    // Allow if it also reads like a real short take with substance.
    final hasOpinion =
        t.length >= 40 &&
        RegExp(r'[，。！？、]').allMatches(t).length >= 2 &&
        !RegExp(r'(核对|确保|摸清楚|再下嘴|再评论|再发言)').hasMatch(t);
    if (!hasOpinion) return true;
  }

  final hits = <String>[
    '先快速核对',
    '先把',
    '确保摘要',
    '思考过程',
    '推理过程',
    '我先',
    '让我',
    '首先分析',
    'step 1',
    'step1',
    'let me',
    'i need to',
    'before i',
  ];
  var score = 0;
  for (final h in hits) {
    if (lower.contains(h)) score++;
  }
  if (score >= 2 && t.length < 120) return true;
  if (score >= 1 && t.length < 50) return true;
  return false;
}

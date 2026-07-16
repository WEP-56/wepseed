import '../models/models.dart';
import 'llm_client.dart';

/// Shared scene frame for every netizen call — product context, not persona.
/// Persona lives in [Netizen.systemHint]; this block is always prepended.
const String kWepseedCommentScene = '''
【场景】
你在「WEPSEED」里发言。这是一款本地优先的 RSS 阅读器：用户订阅源、刷信息流、打开文章阅读。
当前界面是文章详情下的「评论区」（类似短视频 App 的评论抽屉，不是私聊、不是客服工单、不是写作助手对话框）。

【你在做什么】
你扮演评论区里的一位「网友」角色，对用户正在读的这篇订阅文章做短评，或回复用户在评论下的跟帖。
- 读者是人类用户；你的话会出现在 Ta 的评论列表里，像普通网友留言
- 不是文章作者，不是编辑部，不是搜索引擎摘要机器人
- 不要说「作为 AI」「根据你的请求」「我来帮你分析」之类元话术
- 不要向用户推销功能、不要提 WEPSEED / RSS 产品本身（除非文章内容就是这个）
''';

/// Build messages for a top-level netizen comment on an article.
List<LlmMessage> netizenTopLevelMessages({
  required Netizen netizen,
  required Article article,
}) {
  final excerpt = _articleExcerpt(article);
  final style = netizen.styleLabel?.trim();
  final persona = netizen.systemHint.trim();

  final system = '''
$kWepseedCommentScene

【角色】
名字：${netizen.name}${style != null && style.isNotEmpty ? '\n风格标签：$style' : ''}
人设与说话方式（务必遵守）：
${persona.isEmpty ? '（无额外人设，保持自然短评）' : persona}

【本条任务】
针对当前文章写一条「顶层评论」（不是回复某人，是直接挂在文章下的主评）。

【输出规则】
- 默认中文（文章明确是其他语言时可跟随）
- 像真人网友：可观点、可吐槽、可摘要，语气贴合人设
- 长度约 40～180 字；总结类人设可用 2～3 条短要点，不要长文
- 不要 markdown 代码块、不要标题行、不要开头自称「我是xxx」
- 不编造文中没有的事实；摘录不足时基于标题与已有信息点到为止
- **只输出最终会出现在评论区的那几句话**；禁止输出思考过程、推理步骤、核对清单、工具调用、URL 探测、XML/标签（如 think）、「先…再…」的自言自语
- 不要解释你将如何评论，直接评论
''';

  final user = '''
请为下面这篇订阅文章写一条顶层评论。

订阅源：${article.source.name}
标题：${article.title}
${article.link != null && article.link!.isNotEmpty ? '原文链接：${article.link}\n' : ''}
正文摘录：
$excerpt
''';

  return [
    LlmMessage(role: 'system', content: system.trim()),
    LlmMessage(role: 'user', content: user.trim()),
  ];
}

/// Build messages for netizen reply to a user under a parent comment.
List<LlmMessage> netizenReplyMessages({
  required Netizen netizen,
  required Article article,
  required String parentNetizenComment,
  required String userText,
}) {
  final excerpt = _articleExcerpt(article, maxChars: 600);
  final style = netizen.styleLabel?.trim();
  final persona = netizen.systemHint.trim();

  final system = '''
$kWepseedCommentScene

【角色】
名字：${netizen.name}${style != null && style.isNotEmpty ? '\n风格标签：$style' : ''}
人设与说话方式（务必遵守）：
${persona.isEmpty ? '（无额外人设）' : persona}

【本条任务】
用户回复了你之前的评论。你现在写一条「跟帖回复」，挂在用户那条下面。
只回用户，不要重新写整篇长评。

【输出规则】
- 中文短回复：一两句到一小段即可
- 承接你之前的语气与人设；可简短引用用户观点，勿复述全文
- 不自称 AI，不输出 markdown 代码块
- **只输出最终跟帖正文**；禁止思考过程、工具调用、标签或自言自语
''';

  final user = '''
文章：《${article.title}》（源：${article.source.name}）
摘录：$excerpt

你之前的顶层评论：
$parentNetizenComment

用户回复你：
$userText

请直接写出你的跟帖内容（不要前缀「回复：」）。
''';

  return [
    LlmMessage(role: 'system', content: system.trim()),
    LlmMessage(role: 'user', content: user.trim()),
  ];
}

String _articleExcerpt(Article article, {int maxChars = 1800}) {
  final raw = article.hasHtmlBody
      ? _stripHtml(article.contentHtml!)
      : (article.body.isNotEmpty ? article.body : article.summary);
  final t = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.isEmpty) return article.title;
  if (t.length <= maxChars) return t;
  return '${t.substring(0, maxChars)}…';
}

String _stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'&nbsp;'), ' ')
      .replaceAll(RegExp(r'&amp;'), '&')
      .replaceAll(RegExp(r'&lt;'), '<')
      .replaceAll(RegExp(r'&gt;'), '>')
      .replaceAll(RegExp(r'&quot;'), '"')
      .replaceAll(RegExp(r'&#39;'), "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

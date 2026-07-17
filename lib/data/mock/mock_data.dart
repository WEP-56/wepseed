import '../models/models.dart';

abstract final class MockData {
  static final now = DateTime.now();

  static const sources = <FeedSource>[
    FeedSource(id: 's1', name: '少数派', domain: 'sspai.com'),
    FeedSource(id: 's2', name: '爱范儿', domain: 'ifanr.com'),
    FeedSource(id: 's3', name: 'The Verge', domain: 'theverge.com'),
    FeedSource(id: 's4', name: 'Hacker News', domain: 'news.ycombinator.com'),
    FeedSource(id: 's5', name: '设计癖', domain: 'shejipi.com'),
    FeedSource(id: 's6', name: '晚点 LatePost', domain: 'latepost.com'),
    FeedSource(id: 's7', name: '果壳', domain: 'guokr.com'),
    FeedSource(id: 's8', name: 'V2EX', domain: 'v2ex.com'),
  ];

  static UserProfile defaultUser = const UserProfile(displayName: '旅人');

  static List<Article> articles() {
    final s = sources;
    return [
      Article(
        id: 'a1',
        source: s[0],
        title: '把信息流做成杂志：为什么你的阅读器不该像邮箱',
        summary: '订阅不等于堆积。当 RSS 开始学习杂志的节奏，阅读会重新变得诱人。',
        body: _bodyMagazine,
        publishedAt: now.subtract(const Duration(minutes: 42)),
        imageUrl: 'https://picsum.photos/seed/wepseed1/800/1000',
        imageAspect: 0.8,
        featured: true,
        tags: const ['产品', '阅读'],
      ),
      Article(
        id: 'a2',
        source: s[2],
        title: 'AI companions are quietly becoming the new browser tabs',
        summary:
            'Not chatbots. Not search. Something closer to a reading buddy.',
        body: _bodyAiCompanion,
        publishedAt: now.subtract(const Duration(hours: 2)),
        imageUrl: 'https://picsum.photos/seed/wepseed2/900/700',
        imageAspect: 1.28,
        tags: const ['AI', 'UX'],
      ),
      Article(
        id: 'a3',
        source: s[3],
        title: 'Show HN: A local-first RSS reader that talks back',
        summary:
            'No account. No cloud timeline. Just you, your feeds, and a quiet companion.',
        body: _bodyShowHn,
        publishedAt: now.subtract(const Duration(hours: 3, minutes: 20)),
        tags: const ['开源', '本地优先'],
      ),
      Article(
        id: 'a4',
        source: s[4],
        title: '圆角、毛玻璃与留白：2026 移动端高级感的三件套',
        summary: '高级感不是堆特效。是克制的材质、可信的层级，和让人想多停一秒的呼吸感。',
        body: _bodyDesign,
        publishedAt: now.subtract(const Duration(hours: 5)),
        imageUrl: 'https://picsum.photos/seed/wepseed4/700/900',
        imageAspect: 0.78,
        tags: const ['设计'],
      ),
      Article(
        id: 'a5',
        source: s[5],
        title: '内容平台的下一站：从“刷完”到“留下痕迹”',
        summary: '收藏夹吃灰的反面，是一条有温度的时间轴。',
        body: _bodyTraces,
        publishedAt: now.subtract(const Duration(hours: 8)),
        imageUrl: 'https://picsum.photos/seed/wepseed5/900/600',
        imageAspect: 1.5,
        tags: const ['媒体'],
      ),
      Article(
        id: 'a6',
        source: s[6],
        title: '为什么大脑喜欢不规则的信息拼贴',
        summary: '整齐网格很安全，但探索欲往往来自轻微的不对称。',
        body: _bodyMasonry,
        publishedAt: now.subtract(const Duration(hours: 11)),
        tags: const ['认知', '交互'],
      ),
      Article(
        id: 'a7',
        source: s[1],
        title: '在安卓上做一支“有玻璃质感”的底栏',
        summary: '不是照抄 iOS，而是借材质语言，让导航变得轻一点。',
        body: _bodyGlassNav,
        publishedAt: now.subtract(const Duration(hours: 14)),
        imageUrl: 'https://picsum.photos/seed/wepseed7/800/800',
        imageAspect: 1.0,
        tags: const ['Flutter', 'Android'],
      ),
      Article(
        id: 'a8',
        source: s[7],
        title: '有没有人在用 LLM 当阅读批注？',
        summary: '不是让它替你读，是让它坐在旁边，偶尔插一句。',
        body: _bodyAnnotate,
        publishedAt: now.subtract(const Duration(hours: 18)),
        tags: const ['讨论'],
      ),
      Article(
        id: 'a9',
        source: s[0],
        title: 'OPML 仍是最浪漫的数据自由',
        summary: '一份列表，带走你所有的源。换应用时，世界还在。',
        body: _bodyOpml,
        publishedAt: now.subtract(const Duration(days: 1, hours: 2)),
        imageUrl: 'https://picsum.photos/seed/wepseed9/900/1100',
        imageAspect: 0.82,
        tags: const ['数据'],
      ),
      Article(
        id: 'a10',
        source: s[2],
        title: 'Notifications that feel like a friend texting a headline',
        summary: '“3 new items” is dead. Context is the new badge.',
        body: _bodyNotify,
        publishedAt: now.subtract(const Duration(days: 1, hours: 6)),
        imageUrl: 'https://picsum.photos/seed/wepseed10/900/650',
        imageAspect: 1.38,
        tags: const ['通知'],
      ),
      Article(
        id: 'a11',
        source: s[4],
        title: '夜间模式不该只是反色',
        summary: '真正的暗色主题，是重新调过的纸张、油墨和强调色。',
        body: _bodyDark,
        publishedAt: now.subtract(const Duration(days: 1, hours: 10)),
        tags: const ['主题'],
      ),
      Article(
        id: 'a12',
        source: s[5],
        title: '我们在一期产品里只做三件事：刷、聊、回看',
        summary: '功能可以以后加。气质必须第一天就在。',
        body: _bodyThreeThings,
        publishedAt: now.subtract(const Duration(days: 2)),
        imageUrl: 'https://picsum.photos/seed/wepseed12/800/960',
        imageAspect: 0.83,
        featured: true,
        tags: const ['产品'],
      ),
    ];
  }

  static List<MeEvent> meEvents(List<Article> articles) {
    Article a(String id) => articles.firstWhere((e) => e.id == id);
    return [
      MeEvent(
        id: 'e1',
        type: MeEventType.chat,
        createdAt: now.subtract(const Duration(minutes: 25)),
        title: '和墨白聊了《把信息流做成杂志》',
        subtitle: '这篇像在劝你：别当收件箱，当编辑。',
        articleId: a('a1').id,
      ),
      MeEvent(
        id: 'e2',
        type: MeEventType.bookmark,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
        title: '收藏了 The Verge',
        subtitle: a('a2').title,
        articleId: a('a2').id,
      ),
      MeEvent(
        id: 'e3',
        type: MeEventType.dwell,
        createdAt: now.subtract(const Duration(hours: 3)),
        title: '在这篇停了 6 分钟',
        subtitle: a('a4').title,
        articleId: a('a4').id,
      ),
      MeEvent(
        id: 'e4',
        type: MeEventType.binge,
        createdAt: now.subtract(const Duration(hours: 9)),
        title: '今天刷了 11 篇',
        subtitle: '节奏不错，像翻完一本杂志。',
      ),
      MeEvent(
        id: 'e5',
        type: MeEventType.bookmark,
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
        title: '收藏 · OPML 仍是最浪漫的数据自由',
        subtitle: a('a9').source.name,
        articleId: a('a9').id,
      ),
      MeEvent(
        id: 'e6',
        type: MeEventType.streak,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        title: '连续 3 天在看少数派',
        subtitle: '这个源对你的口味很准。',
      ),
      MeEvent(
        id: 'e7',
        type: MeEventType.nightOwl,
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
        title: '凌晨 1:14 还在读',
        subtitle: '夜读时对比已略微压低。',
      ),
      MeEvent(
        id: 'e8',
        type: MeEventType.chat,
        createdAt: now.subtract(const Duration(days: 2, hours: 2)),
        title: '和墨白聊了一篇 HN',
        subtitle: 'Show HN 的标题有时比产品本身更会讲故事。',
        articleId: a('a3').id,
      ),
    ];
  }

  static const _bodyMagazine = '''
订阅不等于堆积。

很长一段时间里，RSS 阅读器长得像邮箱：未读角标、列表、标记已读。高效，但冷。

杂志不是这样工作的。它有封面节奏、有跨页大图、有故意的留白，也有你愿意为某一页停留的理由。

当我们把信息流重新排成“可逛”的拼贴，阅读会从任务变回欲望。你不是在清空收件箱，你是在翻一本每天自动更新的杂志。

当然，杂志需要编辑。在本地优先的世界里，编辑可以是你——加上一个坐在旁边的阅读伴侣。
''';

  static const _bodyAiCompanion = '''
The best AI features in reading apps don't try to finish the article for you.

They sit nearby. They notice what you lingered on. They offer a short take, a sharper question, a quieter joke. They make solitude feel less empty without turning reading into a group chat.

That's the bet: companionship over automation.
''';

  static const _bodyShowHn = '''
Local-first is not nostalgia. It's a boundary.

Your feeds, your notes, your late-night rabbit holes — they don't need a server to feel real. A reader that talks back can still keep every word on your phone.
''';

  static const _bodyDesign = '''
高级感很少来自更多控件。

它来自：

1. 可信的层级（什么先被看见）
2. 克制的材质（玻璃是空气，不是塑料）
3. 让人愿意多停一秒的节奏（动效、触感、呼吸）

移动端尤其如此。拇指会原谅功能缺失，但不会原谅廉价感。
''';

  static const _bodyTraces = '''
收藏是一种轻微的承诺：这篇值得回头。

如果承诺之后只剩一个冰冷的文件夹，温度就断了。把收藏、短评、驻留、偶发的小记录串成时间轴，应用才会像在陪你生活，而不是在记账。
''';

  static const _bodyMasonry = '''
规则网格节省认知，不规则拼贴唤起探索。

Instagram 探索页之所以耐刷，不只是内容，而是“下一张不确定”的轻微惊喜。RSS 也可以借用这套节奏：有图走图，无图把文字排成有份量的卡片。
''';

  static const _bodyGlassNav = '''
悬浮底栏要轻。

轻的意思是：不抢内容、不贴死屏幕、在滚动时仍可辨认。毛玻璃是手段，目的是让导航像浮在空气里的一层薄冰。
''';

  static const _bodyAnnotate = '''
批注的最高境界不是标准答案，而是一句刚好的旁白。

LLM 适合做这件事：短、准、带立场。它不替你读完，它让你更想读下去。
''';

  static const _bodyOpml = '''
OPML 看起来土，土得很自由。

一份列表带走所有源。换应用、换手机、换十年后的你，订阅关系还在。本地优先的产品，应该把这种自由当成默认礼貌。
''';

  static const _bodyNotify = '''
A good notification sounds like a friend who knows your taste.

Not "3 new items". More like: 少数派更新了——把信息流做成杂志。 Context is care.
''';

  static const _bodyDark = '''
反色很省事，也很容易脏。

暗色主题要重新决定：纸张多深、文字多亮、强调色如何在夜里仍然干净。夜间模式是第二次设计，不是开关。
''';

  static const _bodyThreeThings = '''
刷：让你进来。
聊：让你留下观点。
回看：让你感到被记住。

三件事做透，产品就有人格。其他的，可以以后慢慢长出来。
''';
}

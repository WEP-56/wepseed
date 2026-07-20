import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Feeds,
    Articles,
    ChatSessions,
    ChatMessages,
    MediaChatMessages,
    Companions,
    UserProfiles,
    WarmEvents,
    AppSettingsRows,
    LlmProviders,
    LlmModels,
    Netizens,
    Comments,
    CommentJobs,
    CommentJobItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(appSettingsRows, appSettingsRows.commentTrigger);
        await m.createTable(llmProviders);
        await m.createTable(llmModels);
        await m.createTable(netizens);
        await m.createTable(comments);
        await _seedDefaults();
      }
      // A v1 database creates the latest provider table above, so only
      // existing v2 tables need the two additive columns.
      if (from == 2) {
        await m.addColumn(llmProviders, llmProviders.maxConcurrent);
        await m.addColumn(llmProviders, llmProviders.requestsPerMinute);
      }
      if (from < 4) {
        await m.addColumn(appSettingsRows, appSettingsRows.feedFilterJson);
      }
      if (from < 5) {
        await m.createTable(commentJobs);
        await m.createTable(commentJobItems);
      }
      if (from < 6) {
        await m.addColumn(articles, articles.mediaType);
        await m.addColumn(articles, articles.enclosureUrl);
        await m.addColumn(articles, articles.enclosureMime);
        await m.addColumn(articles, articles.enclosureLength);
        await m.addColumn(articles, articles.durationSeconds);
      }
      if (from < 7) {
        await m.createTable(mediaChatMessages);
      }
      if (from < 8) {
        await m.addColumn(appSettingsRows, appSettingsRows.browserIncognito);
      }
      if (from < 9) {
        await m.addColumn(feeds, feeds.lastSuccessAt);
        await m.addColumn(feeds, feeds.lastErrorAt);
        await m.addColumn(feeds, feeds.lastErrorMessage);
        await m.addColumn(feeds, feeds.consecutiveFailures);
        await m.addColumn(feeds, feeds.avgLatencyMs);
      }
    },
  );

  Future<void> _seedDefaults() async {
    final now = DateTime.now();
    final existing = await select(netizens).get();
    if (existing.isNotEmpty) return;

    // Persona-only hints; product scene is injected in llm_prompt.dart.
    final seeds = <NetizensCompanion>[
      NetizensCompanion.insert(
        id: 'n_summary',
        name: '总结君',
        styleLabel: const Value('干货摘要'),
        systemHint: '说话像爱记笔记的读者：用不超过三条的短要点概括「这篇文章在说什么、值不值得细读」。干净、实用、不废话、不卖萌。',
        weight: const Value(1.0),
        sortOrder: const Value(0),
        createdAt: now,
        updatedAt: now,
      ),
      NetizensCompanion.insert(
        id: 'n_spicy',
        name: '辣评姐',
        styleLabel: const Value('锋利吐槽'),
        systemHint: '说话像嘴硬心明的网友：敢点标题党、注水、套路，锋利短句，带一点刺，但不人身攻击、不阴阳整篇文章作者私德。',
        weight: const Value(0.7),
        sortOrder: const Value(1),
        createdAt: now,
        updatedAt: now,
      ),
      NetizensCompanion.insert(
        id: 'n_cool',
        name: '冷淡叔',
        styleLabel: const Value('克制旁观'),
        systemHint: '说话极简：一两句就够，留白、克制、不热脸。宁可寡淡，也不展开长评。像路过扫了一眼标题的人。',
        weight: const Value(0.5),
        sortOrder: const Value(2),
        createdAt: now,
        updatedAt: now,
      ),
      NetizensCompanion.insert(
        id: 'n_neutral',
        name: '中立菌',
        styleLabel: const Value('两边看'),
        systemHint: '说话像爱平衡的读者：各给一句优点与顾虑，不站队、不煽情，语气平稳，结论可「看你需要什么」。',
        weight: const Value(0.6),
        sortOrder: const Value(3),
        createdAt: now,
        updatedAt: now,
      ),
    ];
    for (final s in seeds) {
      await into(netizens).insertOnConflictUpdate(s);
    }
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'wepseed');
  }
}

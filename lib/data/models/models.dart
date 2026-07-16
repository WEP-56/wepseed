import 'package:flutter/material.dart';

enum MeEventType { bookmark, chat, dwell, binge, streak, nightOwl }

enum CommentTrigger { off, onBrowse, onOpenComments }

enum LlmProtocol { openaiChatCompletions, openaiResponses, anthropicMessages }

enum CommentAuthorType { user, netizen }

class FeedSource {
  const FeedSource({
    required this.id,
    required this.name,
    required this.domain,
    this.url,
    this.siteUrl,
    this.isPaused = false,
  });

  final String id;
  final String name;
  final String domain;
  final String? url;
  final String? siteUrl;
  final bool isPaused;
}

class Article {
  const Article({
    required this.id,
    required this.source,
    required this.title,
    required this.summary,
    required this.body,
    required this.publishedAt,
    this.link,
    this.contentHtml,
    this.imageUrl,
    this.imageAspect = 1.0,
    this.featured = false,
    this.tags = const [],
  });

  final String id;
  final FeedSource source;
  final String title;
  final String summary;

  /// Plain-text body (stripped HTML) — fallback when [contentHtml] is empty.
  final String body;
  final DateTime publishedAt;
  final String? link;

  /// Raw HTML from RSS content:encoded / Atom content (Phase C render).
  final String? contentHtml;
  final String? imageUrl;
  final double imageAspect;
  final bool featured;
  final List<String> tags;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasHtmlBody => contentHtml != null && contentHtml!.trim().isNotEmpty;

  /// Lead summary under title: hide when it duplicates the body start.
  bool get showSummaryAsLead {
    final s = summary.trim();
    if (s.isEmpty) return false;
    final plain = body.trim();
    if (plain.isEmpty) return true;
    if (plain == s) return false;
    if (plain.startsWith(s)) return false;
    return true;
  }
}

class UserProfile {
  const UserProfile({required this.displayName});

  final String displayName;

  UserProfile copyWith({String? displayName}) {
    return UserProfile(displayName: displayName ?? this.displayName);
  }
}

class MeEvent {
  const MeEvent({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.title,
    required this.subtitle,
    this.articleId,
  });

  final String id;
  final MeEventType type;
  final DateTime createdAt;
  final String title;
  final String subtitle;
  final String? articleId;
}

class LlmProvider {
  const LlmProvider({
    required this.id,
    required this.name,
    required this.protocol,
    required this.baseUrl,
    this.isEnabled = true,
    this.maxConcurrent = 1,
    this.requestsPerMinute = 10,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final LlmProtocol protocol;
  final String baseUrl;
  final bool isEnabled;

  /// Maximum in-flight requests shared by all netizens using this provider.
  final int maxConcurrent;

  /// Sliding-window request budget shared by this provider.
  final int requestsPerMinute;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LlmProvider copyWith({
    String? id,
    String? name,
    LlmProtocol? protocol,
    String? baseUrl,
    bool? isEnabled,
    int? maxConcurrent,
    int? requestsPerMinute,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LlmProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      baseUrl: baseUrl ?? this.baseUrl,
      isEnabled: isEnabled ?? this.isEnabled,
      maxConcurrent: maxConcurrent ?? this.maxConcurrent,
      requestsPerMinute: requestsPerMinute ?? this.requestsPerMinute,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LlmModel {
  const LlmModel({
    required this.id,
    required this.providerId,
    required this.modelId,
    required this.displayName,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  final String id;
  final String providerId;
  final String modelId;
  final String displayName;
  final bool isDefault;
  final int sortOrder;

  LlmModel copyWith({
    String? id,
    String? providerId,
    String? modelId,
    String? displayName,
    bool? isDefault,
    int? sortOrder,
  }) {
    return LlmModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      displayName: displayName ?? this.displayName,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class Netizen {
  const Netizen({
    required this.id,
    required this.name,
    required this.systemHint,
    this.styleLabel,
    this.avatarPath,
    this.weight = 0.6,
    this.providerId,
    this.modelId,
    this.isEnabled = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String systemHint;
  final String? styleLabel;
  final String? avatarPath;
  final double weight;
  final String? providerId;
  final String? modelId;
  final bool isEnabled;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Netizen copyWith({
    String? id,
    String? name,
    String? systemHint,
    String? styleLabel,
    String? avatarPath,
    bool clearAvatar = false,
    double? weight,
    String? providerId,
    String? modelId,
    bool clearProvider = false,
    bool clearModel = false,
    bool? isEnabled,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Netizen(
      id: id ?? this.id,
      name: name ?? this.name,
      systemHint: systemHint ?? this.systemHint,
      styleLabel: styleLabel ?? this.styleLabel,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      weight: weight ?? this.weight,
      providerId: clearProvider ? null : (providerId ?? this.providerId),
      modelId: clearModel ? null : (modelId ?? this.modelId),
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Comment {
  const Comment({
    required this.id,
    required this.articleId,
    required this.authorType,
    required this.content,
    required this.createdAt,
    this.netizenId,
    this.parentId,
  });

  final String id;
  final String articleId;
  final CommentAuthorType authorType;
  final String? netizenId;
  final String? parentId;
  final String content;
  final DateTime createdAt;

  bool get isTopLevel => parentId == null;
}

/// New 页信息流筛选（本地持久化）。
///
/// - [onlyToday] / [onlyUnread] 可叠加
/// - [feedIds] 非空 = 只看这些源；空 = 不限源
/// - 刷新限刷只看 [feedIds]（今日/未看不缩刷新范围）
class FeedFilter {
  const FeedFilter({
    this.onlyToday = false,
    this.onlyUnread = false,
    this.feedIds = const {},
  });

  final bool onlyToday;
  final bool onlyUnread;

  /// Empty means all sources.
  final Set<String> feedIds;

  bool get isDefault => !onlyToday && !onlyUnread && feedIds.isEmpty;

  bool get limitsRefresh => feedIds.isNotEmpty;

  FeedFilter copyWith({
    bool? onlyToday,
    bool? onlyUnread,
    Set<String>? feedIds,
  }) {
    return FeedFilter(
      onlyToday: onlyToday ?? this.onlyToday,
      onlyUnread: onlyUnread ?? this.onlyUnread,
      feedIds: feedIds ?? this.feedIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FeedFilter) return false;
    if (onlyToday != other.onlyToday || onlyUnread != other.onlyUnread) {
      return false;
    }
    if (feedIds.length != other.feedIds.length) return false;
    return feedIds.containsAll(other.feedIds);
  }

  @override
  int get hashCode => Object.hash(
    onlyToday,
    onlyUnread,
    Object.hashAllUnordered(feedIds),
  );
}

/// UX prefs. LLM endpoints live in LlmProvider / LlmModel.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.refreshMinutes = 30,
    this.wifiOnly = false,
    this.notificationsEnabled = true,
    this.useMockFeed = true,
    this.commentTrigger = CommentTrigger.onOpenComments,
    this.feedFilter = const FeedFilter(),
  });

  final ThemeMode themeMode;
  final double fontScale;
  final int refreshMinutes;
  final bool wifiOnly;
  final bool notificationsEnabled;
  final bool useMockFeed;
  final CommentTrigger commentTrigger;
  final FeedFilter feedFilter;

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    int? refreshMinutes,
    bool? wifiOnly,
    bool? notificationsEnabled,
    bool? useMockFeed,
    CommentTrigger? commentTrigger,
    FeedFilter? feedFilter,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      refreshMinutes: refreshMinutes ?? this.refreshMinutes,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      useMockFeed: useMockFeed ?? this.useMockFeed,
      commentTrigger: commentTrigger ?? this.commentTrigger,
      feedFilter: feedFilter ?? this.feedFilter,
    );
  }
}

String llmProtocolLabel(LlmProtocol p) => switch (p) {
  LlmProtocol.openaiChatCompletions => 'OpenAI Chat Completions',
  LlmProtocol.openaiResponses => 'OpenAI Responses',
  LlmProtocol.anthropicMessages => 'Anthropic Messages',
};

String llmProtocolToDb(LlmProtocol p) => switch (p) {
  LlmProtocol.openaiChatCompletions => 'openai_chat',
  LlmProtocol.openaiResponses => 'openai_responses',
  LlmProtocol.anthropicMessages => 'anthropic_messages',
};

LlmProtocol llmProtocolFromDb(String v) => switch (v) {
  'openai_responses' => LlmProtocol.openaiResponses,
  'anthropic_messages' => LlmProtocol.anthropicMessages,
  _ => LlmProtocol.openaiChatCompletions,
};

String commentTriggerToDb(CommentTrigger t) => switch (t) {
  CommentTrigger.off => 'off',
  CommentTrigger.onBrowse => 'onBrowse',
  CommentTrigger.onOpenComments => 'onOpenComments',
};

CommentTrigger commentTriggerFromDb(String v) => switch (v) {
  'off' => CommentTrigger.off,
  'onBrowse' => CommentTrigger.onBrowse,
  _ => CommentTrigger.onOpenComments,
};

import 'package:drift/drift.dart';

@DataClassName('FeedRow')
class Feeds extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get siteUrl => text().nullable()();
  TextColumn get iconUrl => text().nullable()();
  DateTimeColumn get lastFetchedAt => dateTime().nullable()();
  TextColumn get etag => text().nullable()();
  TextColumn get lastModified => text().nullable()();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {url},
  ];
}

@DataClassName('ArticleRow')
class Articles extends Table {
  TextColumn get id => text()();
  TextColumn get feedId => text().references(Feeds, #id)();
  TextColumn get guid => text()();
  TextColumn get link => text().nullable()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get contentHtml => text().nullable()();
  TextColumn get contentText => text().withDefault(const Constant(''))();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get imageAspect => real().withDefault(const Constant(1.0))();
  BoolColumn get featured => boolean().withDefault(const Constant(false))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get publishedAt => dateTime()();
  DateTimeColumn get fetchedAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get bookmarkedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {feedId, guid},
  ];
}

// Legacy tables kept for schema continuity (no longer primary product path).
class ChatSessions extends Table {
  TextColumn get id => text()();
  TextColumn get articleId => text()();
  TextColumn get companionSnapshotJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {articleId},
  ];
}

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(ChatSessions, #id)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CompanionRow')
class Companions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get styleLabel => text()();
  TextColumn get systemHint => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class WarmEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  TextColumn get articleId => text().nullable()();
  TextColumn get payloadJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettingsRows extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get id => text()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  RealColumn get fontScale => real().withDefault(const Constant(1.0))();
  IntColumn get refreshMinutes => integer().withDefault(const Constant(30))();
  BoolColumn get wifiOnly => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  // Legacy unused columns (kept for migration safety).
  TextColumn get llmBaseUrl =>
      text().withDefault(const Constant('https://api.openai.com/v1'))();
  TextColumn get llmModel =>
      text().withDefault(const Constant('gpt-4o-mini'))();
  BoolColumn get useMockFeed => boolean().withDefault(const Constant(true))();
  TextColumn get commentTrigger =>
      text().withDefault(const Constant('onOpenComments'))();
  /// New-page stream filter JSON: {onlyToday, onlyUnread, feedIds}.
  TextColumn get feedFilterJson =>
      text().withDefault(const Constant('{}'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LlmProviderRow')
class LlmProviders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get protocol => text()();
  TextColumn get baseUrl => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get maxConcurrent => integer().withDefault(const Constant(1))();
  IntColumn get requestsPerMinute =>
      integer().withDefault(const Constant(10))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LlmModelRow')
class LlmModels extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text().references(LlmProviders, #id)();
  TextColumn get modelId => text()();
  TextColumn get displayName => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('NetizenRow')
class Netizens extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get styleLabel => text().nullable()();
  TextColumn get systemHint => text()();
  TextColumn get avatarPath => text().nullable()();
  RealColumn get weight => real().withDefault(const Constant(0.6))();
  TextColumn get providerId => text().nullable()();
  TextColumn get modelId => text().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CommentRow')
class Comments extends Table {
  TextColumn get id => text()();
  TextColumn get articleId => text()();
  TextColumn get authorType => text()(); // user | netizen
  TextColumn get netizenId => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../mock/mock_data.dart';
import '../models/models.dart';
import 'settings_repository.dart';

const _defaultRowId = 'default';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  Future<void> ensureDefaults() async {
    final settings = await (_db.select(_db.appSettingsRows)
          ..where((t) => t.id.equals(_defaultRowId)))
        .getSingleOrNull();
    if (settings == null) {
      await _db.into(_db.appSettingsRows).insert(
            AppSettingsRowsCompanion.insert(
              id: _defaultRowId,
              updatedAt: DateTime.now(),
            ),
          );
    }

    final user = await (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(_defaultRowId)))
        .getSingleOrNull();
    if (user == null) {
      await _db.into(_db.userProfiles).insert(
            UserProfilesCompanion.insert(
              id: _defaultRowId,
              displayName: MockData.defaultUser.displayName,
              updatedAt: DateTime.now(),
            ),
          );
    }
  }

  @override
  Stream<AppSettings> watch() async* {
    await ensureDefaults();
    yield* (_db.select(_db.appSettingsRows)
          ..where((t) => t.id.equals(_defaultRowId)))
        .watchSingle()
        .map(_mapSettings);
  }

  @override
  Future<AppSettings> get() async {
    await ensureDefaults();
    final row = await (_db.select(_db.appSettingsRows)
          ..where((t) => t.id.equals(_defaultRowId)))
        .getSingle();
    return _mapSettings(row);
  }

  @override
  Future<void> save(AppSettings settings) async {
    await ensureDefaults();
    await (_db.update(_db.appSettingsRows)
          ..where((t) => t.id.equals(_defaultRowId)))
        .write(
      AppSettingsRowsCompanion(
        themeMode: Value(_themeModeToString(settings.themeMode)),
        fontScale: Value(settings.fontScale),
        refreshMinutes: Value(settings.refreshMinutes),
        wifiOnly: Value(settings.wifiOnly),
        notificationsEnabled: Value(settings.notificationsEnabled),
        useMockFeed: Value(settings.useMockFeed),
        commentTrigger: Value(commentTriggerToDb(settings.commentTrigger)),
        feedFilterJson: Value(feedFilterToDb(settings.feedFilter)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<UserProfile> watchUser() async* {
    await ensureDefaults();
    yield* (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(_defaultRowId)))
        .watchSingle()
        .map((r) => UserProfile(displayName: r.displayName));
  }

  @override
  Future<UserProfile> getUser() async {
    await ensureDefaults();
    final row = await (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(_defaultRowId)))
        .getSingle();
    return UserProfile(displayName: row.displayName);
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    await ensureDefaults();
    await (_db.update(_db.userProfiles)
          ..where((t) => t.id.equals(_defaultRowId)))
        .write(
      UserProfilesCompanion(
        displayName: Value(user.displayName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  AppSettings _mapSettings(AppSettingsRow row) {
    return AppSettings(
      themeMode: _themeModeFromString(row.themeMode),
      fontScale: row.fontScale,
      refreshMinutes: row.refreshMinutes,
      wifiOnly: row.wifiOnly,
      notificationsEnabled: row.notificationsEnabled,
      useMockFeed: row.useMockFeed,
      commentTrigger: commentTriggerFromDb(row.commentTrigger),
      feedFilter: feedFilterFromDb(row.feedFilterJson),
    );
  }

  static String _themeModeToString(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  static ThemeMode _themeModeFromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}

String feedFilterToDb(FeedFilter filter) {
  final ids = filter.feedIds.toList()..sort();
  return jsonEncode({
    'onlyToday': filter.onlyToday,
    'onlyUnread': filter.onlyUnread,
    'feedIds': ids,
  });
}

FeedFilter feedFilterFromDb(String raw) {
  if (raw.trim().isEmpty || raw.trim() == '{}') {
    return const FeedFilter();
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const FeedFilter();
    final map = Map<String, dynamic>.from(decoded);
    final onlyToday = map['onlyToday'] == true;
    final onlyUnread = map['onlyUnread'] == true;
    final rawIds = map['feedIds'];
    final ids = <String>{};
    if (rawIds is List) {
      for (final id in rawIds) {
        if (id is String && id.isNotEmpty) ids.add(id);
      }
    }
    return FeedFilter(
      onlyToday: onlyToday,
      onlyUnread: onlyUnread,
      feedIds: ids,
    );
  } catch (_) {
    return const FeedFilter();
  }
}

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

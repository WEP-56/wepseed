import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'radar_models.dart';

/// Local UI prefs for explore radar (no Drift migration).
class RadarPrefs {
  RadarPrefs({Directory? directory}) : _directory = directory;

  Directory? _directory;
  File? _file;

  Future<File> _prefsFile() async {
    if (_file != null) return _file!;
    final dir = _directory ?? await getApplicationSupportDirectory();
    _file = File(p.join(dir.path, 'radar_prefs.json'));
    return _file!;
  }

  Future<Map<String, dynamic>> _readMap() async {
    try {
      final file = await _prefsFile();
      if (!await file.exists()) return {};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  Future<void> _writeMap(Map<String, dynamic> map) async {
    final file = await _prefsFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
  }

  Future<bool> loadShowExploreTab() async {
    final map = await _readMap();
    final v = map['showExploreTab'];
    if (v is bool) return v;
    return true;
  }

  Future<void> saveShowExploreTab(bool value) async {
    final map = await _readMap();
    map['showExploreTab'] = value;
    await _writeMap(map);
  }

  Future<RadarDraft> loadDraft() async {
    final map = await _readMap();
    final raw = map['draft'];
    if (raw is Map) {
      return RadarDraft.fromJson(Map<String, dynamic>.from(raw));
    }
    return RadarDraft.empty;
  }

  Future<void> saveDraft(RadarDraft draft) async {
    final map = await _readMap();
    map['draft'] = draft.toJson();
    await _writeMap(map);
  }

  Future<void> clearDraft() async {
    final map = await _readMap();
    map.remove('draft');
    await _writeMap(map);
  }
}

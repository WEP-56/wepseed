import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// JSON list store under application support (bookmarks / history).
class BrowserJsonStore {
  BrowserJsonStore(this.fileName);

  final String fileName;

  Future<File> _file() async {
    final base = await getApplicationSupportDirectory();
    return File(p.join(base.path, fileName));
  }

  Future<List<Map<String, dynamic>>> load() async {
    final file = await _file();
    if (!await file.exists()) return [];
    try {
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Map<String, dynamic>> items) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(items));
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';

import 'radar_models.dart';

const kRadarCatalogAsset = 'assets/rsshub/radar_catalog.json';

Future<RadarCatalog> loadRadarCatalog({
  AssetBundle? bundle,
}) async {
  final raw = await (bundle ?? rootBundle).loadString(kRadarCatalogAsset);
  final decoded = jsonDecode(raw);
  if (decoded is! Map) {
    throw const FormatException('radar_catalog.json root must be an object');
  }
  return RadarCatalog.fromJson(Map<String, dynamic>.from(decoded));
}

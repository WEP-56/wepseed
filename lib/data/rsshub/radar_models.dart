// Curated RSSHub radar catalog models (see assets/rsshub/radar_catalog.json).

class RadarCatalog {
  const RadarCatalog({
    required this.version,
    required this.updated,
    required this.instances,
    required this.sources,
  });

  final int version;
  final String updated;
  final List<RadarInstance> instances;
  final List<RadarSource> sources;

  factory RadarCatalog.fromJson(Map<String, dynamic> json) {
    final instances = <RadarInstance>[];
    final rawInstances = json['instances'];
    if (rawInstances is List) {
      for (final item in rawInstances) {
        if (item is Map) {
          instances.add(
            RadarInstance.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    final sources = <RadarSource>[];
    final rawSources = json['sources'];
    if (rawSources is List) {
      for (final item in rawSources) {
        if (item is Map) {
          sources.add(RadarSource.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return RadarCatalog(
      version: (json['version'] as num?)?.toInt() ?? 1,
      updated: json['updated'] as String? ?? '',
      instances: instances,
      sources: sources,
    );
  }
}

class RadarInstance {
  const RadarInstance({
    required this.id,
    required this.url,
    required this.label,
    this.location,
    this.maintainer,
    this.official = false,
    this.notes,
  });

  final String id;
  final String url;
  final String label;
  final String? location;
  final String? maintainer;
  final bool official;
  final String? notes;

  factory RadarInstance.fromJson(Map<String, dynamic> json) {
    return RadarInstance(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      label: json['label'] as String? ?? json['id'] as String? ?? '',
      location: json['location'] as String?,
      maintainer: json['maintainer'] as String?,
      official: json['official'] == true,
      notes: json['notes'] as String?,
    );
  }

  String get origin {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return url.replaceAll(RegExp(r'/+$'), '');
    return uri.origin + (uri.path.isEmpty || uri.path == '/' ? '' : uri.path.replaceAll(RegExp(r'/+$'), ''));
  }
}

class RadarSource {
  const RadarSource({
    required this.namespace,
    required this.name,
    required this.routes,
    this.siteUrl,
    this.priority = 999,
    this.icon,
    this.blurb,
    this.docsUrl,
  });

  final String namespace;
  final String name;
  final String? siteUrl;
  final int priority;
  final String? icon;
  final String? blurb;
  final String? docsUrl;
  final List<RadarRoute> routes;

  factory RadarSource.fromJson(Map<String, dynamic> json) {
    final routes = <RadarRoute>[];
    final raw = json['routes'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          routes.add(RadarRoute.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return RadarSource(
      namespace: json['namespace'] as String? ?? '',
      name: json['name'] as String? ?? '',
      siteUrl: json['siteUrl'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 999,
      icon: json['icon'] as String?,
      blurb: json['blurb'] as String?,
      docsUrl: json['docsUrl'] as String?,
      routes: routes,
    );
  }
}

class RadarRoute {
  const RadarRoute({
    required this.id,
    required this.path,
    required this.name,
    required this.parameters,
    this.routePath,
    this.example,
    this.categories = const [],
    this.requireConfig = false,
    this.antiCrawler = false,
    this.docsUrl,
  });

  final String id;
  final String path;
  final String name;
  final String? routePath;
  final String? example;
  final List<String> categories;
  final Map<String, RadarParam> parameters;
  final bool requireConfig;
  final bool antiCrawler;
  final String? docsUrl;

  factory RadarRoute.fromJson(Map<String, dynamic> json) {
    final params = <String, RadarParam>{};
    final raw = json['parameters'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (key is! String) return;
        if (value is Map) {
          params[key] = RadarParam.fromJson(Map<String, dynamic>.from(value));
        } else if (value is String) {
          params[key] = RadarParam(description: value, required: true);
        }
      });
    }
    final cats = <String>[];
    final rawCats = json['categories'];
    if (rawCats is List) {
      for (final c in rawCats) {
        if (c is String) cats.add(c);
      }
    }
    return RadarRoute(
      id: json['id'] as String? ?? json['path'] as String? ?? '',
      path: json['path'] as String? ?? '',
      routePath: json['routePath'] as String?,
      name: json['name'] as String? ?? '',
      example: json['example'] as String?,
      categories: cats,
      parameters: params,
      requireConfig: json['requireConfig'] == true,
      antiCrawler: json['antiCrawler'] == true,
      docsUrl: json['docsUrl'] as String?,
    );
  }
}

class RadarParam {
  const RadarParam({
    this.description = '',
    this.defaultValue,
    this.required = false,
    this.options,
  });

  final String description;
  final String? defaultValue;
  final bool required;
  final List<RadarParamOption>? options;

  factory RadarParam.fromJson(Map<String, dynamic> json) {
    List<RadarParamOption>? options;
    final raw = json['options'];
    if (raw is List) {
      options = [];
      for (final item in raw) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          options.add(
            RadarParamOption(
              label: m['label']?.toString() ?? m['value']?.toString() ?? '',
              value: m['value']?.toString() ?? '',
            ),
          );
        }
      }
    }
    final def = json['default'];
    return RadarParam(
      description: json['description'] as String? ?? '',
      defaultValue: def == null ? null : def.toString(),
      required: json['required'] == true,
      options: options,
    );
  }
}

class RadarParamOption {
  const RadarParamOption({required this.label, required this.value});

  final String label;
  final String value;
}

/// In-progress radar form (auto-saved locally).
class RadarDraft {
  const RadarDraft({
    this.instanceId = 'rssforever',
    this.customInstanceUrl = '',
    this.namespace = '',
    this.routePath = '',
    this.params = const {},
    this.query = '',
  });

  final String instanceId;
  final String customInstanceUrl;
  final String namespace;
  final String routePath;
  final Map<String, String> params;
  final String query;

  static const empty = RadarDraft();

  RadarDraft copyWith({
    String? instanceId,
    String? customInstanceUrl,
    String? namespace,
    String? routePath,
    Map<String, String>? params,
    String? query,
  }) {
    return RadarDraft(
      instanceId: instanceId ?? this.instanceId,
      customInstanceUrl: customInstanceUrl ?? this.customInstanceUrl,
      namespace: namespace ?? this.namespace,
      routePath: routePath ?? this.routePath,
      params: params ?? this.params,
      query: query ?? this.query,
    );
  }

  Map<String, dynamic> toJson() => {
    'instanceId': instanceId,
    'customInstanceUrl': customInstanceUrl,
    'namespace': namespace,
    'routePath': routePath,
    'params': params,
    'query': query,
  };

  factory RadarDraft.fromJson(Map<String, dynamic> json) {
    final params = <String, String>{};
    final raw = json['params'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (k is String) params[k] = v?.toString() ?? '';
      });
    }
    return RadarDraft(
      instanceId: json['instanceId'] as String? ?? 'rssforever',
      customInstanceUrl: json['customInstanceUrl'] as String? ?? '',
      namespace: json['namespace'] as String? ?? '',
      routePath: json['routePath'] as String? ?? '',
      params: params,
      query: json['query'] as String? ?? '',
    );
  }
}

/// Expand `/ns/a/:id/:opt?` with param map. Empty optional segments are dropped.
String buildRadarFeedPath(String pathTemplate, Map<String, String> params) {
  final parts = pathTemplate.split('/');
  final out = <String>[];
  for (final part in parts) {
    if (part.isEmpty) {
      if (out.isEmpty) out.add('');
      continue;
    }
    if (!part.startsWith(':')) {
      out.add(part);
      continue;
    }
    var token = part.substring(1);
    // Strip regex/brace suffixes: filepath{.+}, id(foo)
    final brace = token.indexOf('{');
    if (brace >= 0) token = token.substring(0, brace);
    final paren = token.indexOf('(');
    if (paren >= 0) token = token.substring(0, paren);
    final optional = token.endsWith('?');
    final name = optional ? token.substring(0, token.length - 1) : token;
    final raw = params[name]?.trim() ?? '';
    if (raw.isEmpty) {
      if (optional) continue;
      // Keep placeholder so callers can detect incomplete required params.
      out.add(':$name');
      continue;
    }
    out.add(Uri.encodeComponent(raw).replaceAll('%40', '@'));
  }
  var path = out.join('/');
  if (!path.startsWith('/')) path = '/$path';
  // Collapse accidental double slashes (except leading).
  path = path.replaceAll(RegExp(r'/{2,}'), '/');
  return path;
}

String buildRadarFeedUrl({
  required String instanceOrigin,
  required String pathTemplate,
  required Map<String, String> params,
}) {
  final base = instanceOrigin.replaceAll(RegExp(r'/+$'), '');
  final path = buildRadarFeedPath(pathTemplate, params);
  return '$base$path';
}

bool radarPathIsComplete(String path) => !path.contains('/:');

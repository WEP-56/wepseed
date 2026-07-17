// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FeedsTable extends Feeds with TableInfo<$FeedsTable, FeedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteUrlMeta = const VerificationMeta(
    'siteUrl',
  );
  @override
  late final GeneratedColumn<String> siteUrl = GeneratedColumn<String>(
    'site_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconUrlMeta = const VerificationMeta(
    'iconUrl',
  );
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
    'icon_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFetchedAtMeta = const VerificationMeta(
    'lastFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchedAt =
      GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    url,
    siteUrl,
    iconUrl,
    lastFetchedAt,
    etag,
    lastModified,
    isPaused,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('site_url')) {
      context.handle(
        _siteUrlMeta,
        siteUrl.isAcceptableOrUnknown(data['site_url']!, _siteUrlMeta),
      );
    }
    if (data.containsKey('icon_url')) {
      context.handle(
        _iconUrlMeta,
        iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta),
      );
    }
    if (data.containsKey('last_fetched_at')) {
      context.handle(
        _lastFetchedAtMeta,
        lastFetchedAt.isAcceptableOrUnknown(
          data['last_fetched_at']!,
          _lastFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {url},
  ];
  @override
  FeedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      siteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_url'],
      ),
      iconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_url'],
      ),
      lastFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      ),
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified'],
      ),
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FeedsTable createAlias(String alias) {
    return $FeedsTable(attachedDatabase, alias);
  }
}

class FeedRow extends DataClass implements Insertable<FeedRow> {
  final String id;
  final String title;
  final String url;
  final String? siteUrl;
  final String? iconUrl;
  final DateTime? lastFetchedAt;
  final String? etag;
  final String? lastModified;
  final bool isPaused;
  final DateTime createdAt;
  const FeedRow({
    required this.id,
    required this.title,
    required this.url,
    this.siteUrl,
    this.iconUrl,
    this.lastFetchedAt,
    this.etag,
    this.lastModified,
    required this.isPaused,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || siteUrl != null) {
      map['site_url'] = Variable<String>(siteUrl);
    }
    if (!nullToAbsent || iconUrl != null) {
      map['icon_url'] = Variable<String>(iconUrl);
    }
    if (!nullToAbsent || lastFetchedAt != null) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt);
    }
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String>(lastModified);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FeedsCompanion toCompanion(bool nullToAbsent) {
    return FeedsCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      siteUrl: siteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(siteUrl),
      iconUrl: iconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(iconUrl),
      lastFetchedAt: lastFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchedAt),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      isPaused: Value(isPaused),
      createdAt: Value(createdAt),
    );
  }

  factory FeedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      siteUrl: serializer.fromJson<String?>(json['siteUrl']),
      iconUrl: serializer.fromJson<String?>(json['iconUrl']),
      lastFetchedAt: serializer.fromJson<DateTime?>(json['lastFetchedAt']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'siteUrl': serializer.toJson<String?>(siteUrl),
      'iconUrl': serializer.toJson<String?>(iconUrl),
      'lastFetchedAt': serializer.toJson<DateTime?>(lastFetchedAt),
      'etag': serializer.toJson<String?>(etag),
      'lastModified': serializer.toJson<String?>(lastModified),
      'isPaused': serializer.toJson<bool>(isPaused),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeedRow copyWith({
    String? id,
    String? title,
    String? url,
    Value<String?> siteUrl = const Value.absent(),
    Value<String?> iconUrl = const Value.absent(),
    Value<DateTime?> lastFetchedAt = const Value.absent(),
    Value<String?> etag = const Value.absent(),
    Value<String?> lastModified = const Value.absent(),
    bool? isPaused,
    DateTime? createdAt,
  }) => FeedRow(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url ?? this.url,
    siteUrl: siteUrl.present ? siteUrl.value : this.siteUrl,
    iconUrl: iconUrl.present ? iconUrl.value : this.iconUrl,
    lastFetchedAt: lastFetchedAt.present
        ? lastFetchedAt.value
        : this.lastFetchedAt,
    etag: etag.present ? etag.value : this.etag,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    isPaused: isPaused ?? this.isPaused,
    createdAt: createdAt ?? this.createdAt,
  );
  FeedRow copyWithCompanion(FeedsCompanion data) {
    return FeedRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      siteUrl: data.siteUrl.present ? data.siteUrl.value : this.siteUrl,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('isPaused: $isPaused, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    url,
    siteUrl,
    iconUrl,
    lastFetchedAt,
    etag,
    lastModified,
    isPaused,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.siteUrl == this.siteUrl &&
          other.iconUrl == this.iconUrl &&
          other.lastFetchedAt == this.lastFetchedAt &&
          other.etag == this.etag &&
          other.lastModified == this.lastModified &&
          other.isPaused == this.isPaused &&
          other.createdAt == this.createdAt);
}

class FeedsCompanion extends UpdateCompanion<FeedRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> siteUrl;
  final Value<String?> iconUrl;
  final Value<DateTime?> lastFetchedAt;
  final Value<String?> etag;
  final Value<String?> lastModified;
  final Value<bool> isPaused;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FeedsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedsCompanion.insert({
    required String id,
    required String title,
    required String url,
    this.siteUrl = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isPaused = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       url = Value(url),
       createdAt = Value(createdAt);
  static Insertable<FeedRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? siteUrl,
    Expression<String>? iconUrl,
    Expression<DateTime>? lastFetchedAt,
    Expression<String>? etag,
    Expression<String>? lastModified,
    Expression<bool>? isPaused,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (siteUrl != null) 'site_url': siteUrl,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
      if (etag != null) 'etag': etag,
      if (lastModified != null) 'last_modified': lastModified,
      if (isPaused != null) 'is_paused': isPaused,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? url,
    Value<String?>? siteUrl,
    Value<String?>? iconUrl,
    Value<DateTime?>? lastFetchedAt,
    Value<String?>? etag,
    Value<String?>? lastModified,
    Value<bool>? isPaused,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FeedsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      siteUrl: siteUrl ?? this.siteUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      etag: etag ?? this.etag,
      lastModified: lastModified ?? this.lastModified,
      isPaused: isPaused ?? this.isPaused,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (siteUrl.present) {
      map['site_url'] = Variable<String>(siteUrl.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String>(lastModified.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('isPaused: $isPaused, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArticlesTable extends Articles
    with TableInfo<$ArticlesTable, ArticleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES feeds (id)',
    ),
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentHtmlMeta = const VerificationMeta(
    'contentHtml',
  );
  @override
  late final GeneratedColumn<String> contentHtml = GeneratedColumn<String>(
    'content_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTextMeta = const VerificationMeta(
    'contentText',
  );
  @override
  late final GeneratedColumn<String> contentText = GeneratedColumn<String>(
    'content_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('blog'),
  );
  static const VerificationMeta _enclosureUrlMeta = const VerificationMeta(
    'enclosureUrl',
  );
  @override
  late final GeneratedColumn<String> enclosureUrl = GeneratedColumn<String>(
    'enclosure_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enclosureMimeMeta = const VerificationMeta(
    'enclosureMime',
  );
  @override
  late final GeneratedColumn<String> enclosureMime = GeneratedColumn<String>(
    'enclosure_mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enclosureLengthMeta = const VerificationMeta(
    'enclosureLength',
  );
  @override
  late final GeneratedColumn<int> enclosureLength = GeneratedColumn<int>(
    'enclosure_length',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageAspectMeta = const VerificationMeta(
    'imageAspect',
  );
  @override
  late final GeneratedColumn<double> imageAspect = GeneratedColumn<double>(
    'image_aspect',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _featuredMeta = const VerificationMeta(
    'featured',
  );
  @override
  late final GeneratedColumn<bool> featured = GeneratedColumn<bool>(
    'featured',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("featured" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBookmarkedMeta = const VerificationMeta(
    'isBookmarked',
  );
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
    'is_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookmarkedAtMeta = const VerificationMeta(
    'bookmarkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> bookmarkedAt = GeneratedColumn<DateTime>(
    'bookmarked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedId,
    guid,
    link,
    title,
    author,
    summary,
    contentHtml,
    contentText,
    imageUrl,
    mediaType,
    enclosureUrl,
    enclosureMime,
    enclosureLength,
    durationSeconds,
    imageAspect,
    featured,
    tagsJson,
    publishedAt,
    fetchedAt,
    isRead,
    isBookmarked,
    readAt,
    bookmarkedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('content_html')) {
      context.handle(
        _contentHtmlMeta,
        contentHtml.isAcceptableOrUnknown(
          data['content_html']!,
          _contentHtmlMeta,
        ),
      );
    }
    if (data.containsKey('content_text')) {
      context.handle(
        _contentTextMeta,
        contentText.isAcceptableOrUnknown(
          data['content_text']!,
          _contentTextMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('enclosure_url')) {
      context.handle(
        _enclosureUrlMeta,
        enclosureUrl.isAcceptableOrUnknown(
          data['enclosure_url']!,
          _enclosureUrlMeta,
        ),
      );
    }
    if (data.containsKey('enclosure_mime')) {
      context.handle(
        _enclosureMimeMeta,
        enclosureMime.isAcceptableOrUnknown(
          data['enclosure_mime']!,
          _enclosureMimeMeta,
        ),
      );
    }
    if (data.containsKey('enclosure_length')) {
      context.handle(
        _enclosureLengthMeta,
        enclosureLength.isAcceptableOrUnknown(
          data['enclosure_length']!,
          _enclosureLengthMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('image_aspect')) {
      context.handle(
        _imageAspectMeta,
        imageAspect.isAcceptableOrUnknown(
          data['image_aspect']!,
          _imageAspectMeta,
        ),
      );
    }
    if (data.containsKey('featured')) {
      context.handle(
        _featuredMeta,
        featured.isAcceptableOrUnknown(data['featured']!, _featuredMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
        _isBookmarkedMeta,
        isBookmarked.isAcceptableOrUnknown(
          data['is_bookmarked']!,
          _isBookmarkedMeta,
        ),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('bookmarked_at')) {
      context.handle(
        _bookmarkedAtMeta,
        bookmarkedAt.isAcceptableOrUnknown(
          data['bookmarked_at']!,
          _bookmarkedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {feedId, guid},
  ];
  @override
  ArticleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      contentHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_html'],
      ),
      contentText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_text'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      enclosureUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enclosure_url'],
      ),
      enclosureMime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enclosure_mime'],
      ),
      enclosureLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enclosure_length'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      imageAspect: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}image_aspect'],
      )!,
      featured: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}featured'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bookmarked'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      bookmarkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bookmarked_at'],
      ),
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }
}

class ArticleRow extends DataClass implements Insertable<ArticleRow> {
  final String id;
  final String feedId;
  final String guid;
  final String? link;
  final String title;
  final String? author;
  final String summary;
  final String? contentHtml;
  final String contentText;
  final String? imageUrl;
  final String mediaType;
  final String? enclosureUrl;
  final String? enclosureMime;
  final int? enclosureLength;
  final int? durationSeconds;
  final double imageAspect;
  final bool featured;
  final String tagsJson;
  final DateTime publishedAt;
  final DateTime fetchedAt;
  final bool isRead;
  final bool isBookmarked;
  final DateTime? readAt;
  final DateTime? bookmarkedAt;
  const ArticleRow({
    required this.id,
    required this.feedId,
    required this.guid,
    this.link,
    required this.title,
    this.author,
    required this.summary,
    this.contentHtml,
    required this.contentText,
    this.imageUrl,
    required this.mediaType,
    this.enclosureUrl,
    this.enclosureMime,
    this.enclosureLength,
    this.durationSeconds,
    required this.imageAspect,
    required this.featured,
    required this.tagsJson,
    required this.publishedAt,
    required this.fetchedAt,
    required this.isRead,
    required this.isBookmarked,
    this.readAt,
    this.bookmarkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['feed_id'] = Variable<String>(feedId);
    map['guid'] = Variable<String>(guid);
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || contentHtml != null) {
      map['content_html'] = Variable<String>(contentHtml);
    }
    map['content_text'] = Variable<String>(contentText);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['media_type'] = Variable<String>(mediaType);
    if (!nullToAbsent || enclosureUrl != null) {
      map['enclosure_url'] = Variable<String>(enclosureUrl);
    }
    if (!nullToAbsent || enclosureMime != null) {
      map['enclosure_mime'] = Variable<String>(enclosureMime);
    }
    if (!nullToAbsent || enclosureLength != null) {
      map['enclosure_length'] = Variable<int>(enclosureLength);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['image_aspect'] = Variable<double>(imageAspect);
    map['featured'] = Variable<bool>(featured);
    map['tags_json'] = Variable<String>(tagsJson);
    map['published_at'] = Variable<DateTime>(publishedAt);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['is_read'] = Variable<bool>(isRead);
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || bookmarkedAt != null) {
      map['bookmarked_at'] = Variable<DateTime>(bookmarkedAt);
    }
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      feedId: Value(feedId),
      guid: Value(guid),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      summary: Value(summary),
      contentHtml: contentHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHtml),
      contentText: Value(contentText),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      mediaType: Value(mediaType),
      enclosureUrl: enclosureUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(enclosureUrl),
      enclosureMime: enclosureMime == null && nullToAbsent
          ? const Value.absent()
          : Value(enclosureMime),
      enclosureLength: enclosureLength == null && nullToAbsent
          ? const Value.absent()
          : Value(enclosureLength),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      imageAspect: Value(imageAspect),
      featured: Value(featured),
      tagsJson: Value(tagsJson),
      publishedAt: Value(publishedAt),
      fetchedAt: Value(fetchedAt),
      isRead: Value(isRead),
      isBookmarked: Value(isBookmarked),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      bookmarkedAt: bookmarkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bookmarkedAt),
    );
  }

  factory ArticleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleRow(
      id: serializer.fromJson<String>(json['id']),
      feedId: serializer.fromJson<String>(json['feedId']),
      guid: serializer.fromJson<String>(json['guid']),
      link: serializer.fromJson<String?>(json['link']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      summary: serializer.fromJson<String>(json['summary']),
      contentHtml: serializer.fromJson<String?>(json['contentHtml']),
      contentText: serializer.fromJson<String>(json['contentText']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      enclosureUrl: serializer.fromJson<String?>(json['enclosureUrl']),
      enclosureMime: serializer.fromJson<String?>(json['enclosureMime']),
      enclosureLength: serializer.fromJson<int?>(json['enclosureLength']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      imageAspect: serializer.fromJson<double>(json['imageAspect']),
      featured: serializer.fromJson<bool>(json['featured']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      bookmarkedAt: serializer.fromJson<DateTime?>(json['bookmarkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'feedId': serializer.toJson<String>(feedId),
      'guid': serializer.toJson<String>(guid),
      'link': serializer.toJson<String?>(link),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'summary': serializer.toJson<String>(summary),
      'contentHtml': serializer.toJson<String?>(contentHtml),
      'contentText': serializer.toJson<String>(contentText),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'mediaType': serializer.toJson<String>(mediaType),
      'enclosureUrl': serializer.toJson<String?>(enclosureUrl),
      'enclosureMime': serializer.toJson<String?>(enclosureMime),
      'enclosureLength': serializer.toJson<int?>(enclosureLength),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'imageAspect': serializer.toJson<double>(imageAspect),
      'featured': serializer.toJson<bool>(featured),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'isRead': serializer.toJson<bool>(isRead),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'bookmarkedAt': serializer.toJson<DateTime?>(bookmarkedAt),
    };
  }

  ArticleRow copyWith({
    String? id,
    String? feedId,
    String? guid,
    Value<String?> link = const Value.absent(),
    String? title,
    Value<String?> author = const Value.absent(),
    String? summary,
    Value<String?> contentHtml = const Value.absent(),
    String? contentText,
    Value<String?> imageUrl = const Value.absent(),
    String? mediaType,
    Value<String?> enclosureUrl = const Value.absent(),
    Value<String?> enclosureMime = const Value.absent(),
    Value<int?> enclosureLength = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    double? imageAspect,
    bool? featured,
    String? tagsJson,
    DateTime? publishedAt,
    DateTime? fetchedAt,
    bool? isRead,
    bool? isBookmarked,
    Value<DateTime?> readAt = const Value.absent(),
    Value<DateTime?> bookmarkedAt = const Value.absent(),
  }) => ArticleRow(
    id: id ?? this.id,
    feedId: feedId ?? this.feedId,
    guid: guid ?? this.guid,
    link: link.present ? link.value : this.link,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    summary: summary ?? this.summary,
    contentHtml: contentHtml.present ? contentHtml.value : this.contentHtml,
    contentText: contentText ?? this.contentText,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    mediaType: mediaType ?? this.mediaType,
    enclosureUrl: enclosureUrl.present ? enclosureUrl.value : this.enclosureUrl,
    enclosureMime: enclosureMime.present
        ? enclosureMime.value
        : this.enclosureMime,
    enclosureLength: enclosureLength.present
        ? enclosureLength.value
        : this.enclosureLength,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    imageAspect: imageAspect ?? this.imageAspect,
    featured: featured ?? this.featured,
    tagsJson: tagsJson ?? this.tagsJson,
    publishedAt: publishedAt ?? this.publishedAt,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    isRead: isRead ?? this.isRead,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    readAt: readAt.present ? readAt.value : this.readAt,
    bookmarkedAt: bookmarkedAt.present ? bookmarkedAt.value : this.bookmarkedAt,
  );
  ArticleRow copyWithCompanion(ArticlesCompanion data) {
    return ArticleRow(
      id: data.id.present ? data.id.value : this.id,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      guid: data.guid.present ? data.guid.value : this.guid,
      link: data.link.present ? data.link.value : this.link,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      summary: data.summary.present ? data.summary.value : this.summary,
      contentHtml: data.contentHtml.present
          ? data.contentHtml.value
          : this.contentHtml,
      contentText: data.contentText.present
          ? data.contentText.value
          : this.contentText,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      enclosureUrl: data.enclosureUrl.present
          ? data.enclosureUrl.value
          : this.enclosureUrl,
      enclosureMime: data.enclosureMime.present
          ? data.enclosureMime.value
          : this.enclosureMime,
      enclosureLength: data.enclosureLength.present
          ? data.enclosureLength.value
          : this.enclosureLength,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      imageAspect: data.imageAspect.present
          ? data.imageAspect.value
          : this.imageAspect,
      featured: data.featured.present ? data.featured.value : this.featured,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      bookmarkedAt: data.bookmarkedAt.present
          ? data.bookmarkedAt.value
          : this.bookmarkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleRow(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('guid: $guid, ')
          ..write('link: $link, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('contentText: $contentText, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('mediaType: $mediaType, ')
          ..write('enclosureUrl: $enclosureUrl, ')
          ..write('enclosureMime: $enclosureMime, ')
          ..write('enclosureLength: $enclosureLength, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('imageAspect: $imageAspect, ')
          ..write('featured: $featured, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('readAt: $readAt, ')
          ..write('bookmarkedAt: $bookmarkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    feedId,
    guid,
    link,
    title,
    author,
    summary,
    contentHtml,
    contentText,
    imageUrl,
    mediaType,
    enclosureUrl,
    enclosureMime,
    enclosureLength,
    durationSeconds,
    imageAspect,
    featured,
    tagsJson,
    publishedAt,
    fetchedAt,
    isRead,
    isBookmarked,
    readAt,
    bookmarkedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleRow &&
          other.id == this.id &&
          other.feedId == this.feedId &&
          other.guid == this.guid &&
          other.link == this.link &&
          other.title == this.title &&
          other.author == this.author &&
          other.summary == this.summary &&
          other.contentHtml == this.contentHtml &&
          other.contentText == this.contentText &&
          other.imageUrl == this.imageUrl &&
          other.mediaType == this.mediaType &&
          other.enclosureUrl == this.enclosureUrl &&
          other.enclosureMime == this.enclosureMime &&
          other.enclosureLength == this.enclosureLength &&
          other.durationSeconds == this.durationSeconds &&
          other.imageAspect == this.imageAspect &&
          other.featured == this.featured &&
          other.tagsJson == this.tagsJson &&
          other.publishedAt == this.publishedAt &&
          other.fetchedAt == this.fetchedAt &&
          other.isRead == this.isRead &&
          other.isBookmarked == this.isBookmarked &&
          other.readAt == this.readAt &&
          other.bookmarkedAt == this.bookmarkedAt);
}

class ArticlesCompanion extends UpdateCompanion<ArticleRow> {
  final Value<String> id;
  final Value<String> feedId;
  final Value<String> guid;
  final Value<String?> link;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> summary;
  final Value<String?> contentHtml;
  final Value<String> contentText;
  final Value<String?> imageUrl;
  final Value<String> mediaType;
  final Value<String?> enclosureUrl;
  final Value<String?> enclosureMime;
  final Value<int?> enclosureLength;
  final Value<int?> durationSeconds;
  final Value<double> imageAspect;
  final Value<bool> featured;
  final Value<String> tagsJson;
  final Value<DateTime> publishedAt;
  final Value<DateTime> fetchedAt;
  final Value<bool> isRead;
  final Value<bool> isBookmarked;
  final Value<DateTime?> readAt;
  final Value<DateTime?> bookmarkedAt;
  final Value<int> rowid;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    this.guid = const Value.absent(),
    this.link = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.contentText = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.enclosureUrl = const Value.absent(),
    this.enclosureMime = const Value.absent(),
    this.enclosureLength = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.imageAspect = const Value.absent(),
    this.featured = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.readAt = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticlesCompanion.insert({
    required String id,
    required String feedId,
    required String guid,
    this.link = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.contentText = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.enclosureUrl = const Value.absent(),
    this.enclosureMime = const Value.absent(),
    this.enclosureLength = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.imageAspect = const Value.absent(),
    this.featured = const Value.absent(),
    this.tagsJson = const Value.absent(),
    required DateTime publishedAt,
    required DateTime fetchedAt,
    this.isRead = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.readAt = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       feedId = Value(feedId),
       guid = Value(guid),
       title = Value(title),
       publishedAt = Value(publishedAt),
       fetchedAt = Value(fetchedAt);
  static Insertable<ArticleRow> custom({
    Expression<String>? id,
    Expression<String>? feedId,
    Expression<String>? guid,
    Expression<String>? link,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? summary,
    Expression<String>? contentHtml,
    Expression<String>? contentText,
    Expression<String>? imageUrl,
    Expression<String>? mediaType,
    Expression<String>? enclosureUrl,
    Expression<String>? enclosureMime,
    Expression<int>? enclosureLength,
    Expression<int>? durationSeconds,
    Expression<double>? imageAspect,
    Expression<bool>? featured,
    Expression<String>? tagsJson,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? fetchedAt,
    Expression<bool>? isRead,
    Expression<bool>? isBookmarked,
    Expression<DateTime>? readAt,
    Expression<DateTime>? bookmarkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (guid != null) 'guid': guid,
      if (link != null) 'link': link,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (summary != null) 'summary': summary,
      if (contentHtml != null) 'content_html': contentHtml,
      if (contentText != null) 'content_text': contentText,
      if (imageUrl != null) 'image_url': imageUrl,
      if (mediaType != null) 'media_type': mediaType,
      if (enclosureUrl != null) 'enclosure_url': enclosureUrl,
      if (enclosureMime != null) 'enclosure_mime': enclosureMime,
      if (enclosureLength != null) 'enclosure_length': enclosureLength,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (imageAspect != null) 'image_aspect': imageAspect,
      if (featured != null) 'featured': featured,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (publishedAt != null) 'published_at': publishedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (isRead != null) 'is_read': isRead,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (readAt != null) 'read_at': readAt,
      if (bookmarkedAt != null) 'bookmarked_at': bookmarkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticlesCompanion copyWith({
    Value<String>? id,
    Value<String>? feedId,
    Value<String>? guid,
    Value<String?>? link,
    Value<String>? title,
    Value<String?>? author,
    Value<String>? summary,
    Value<String?>? contentHtml,
    Value<String>? contentText,
    Value<String?>? imageUrl,
    Value<String>? mediaType,
    Value<String?>? enclosureUrl,
    Value<String?>? enclosureMime,
    Value<int?>? enclosureLength,
    Value<int?>? durationSeconds,
    Value<double>? imageAspect,
    Value<bool>? featured,
    Value<String>? tagsJson,
    Value<DateTime>? publishedAt,
    Value<DateTime>? fetchedAt,
    Value<bool>? isRead,
    Value<bool>? isBookmarked,
    Value<DateTime?>? readAt,
    Value<DateTime?>? bookmarkedAt,
    Value<int>? rowid,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      guid: guid ?? this.guid,
      link: link ?? this.link,
      title: title ?? this.title,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      contentHtml: contentHtml ?? this.contentHtml,
      contentText: contentText ?? this.contentText,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaType: mediaType ?? this.mediaType,
      enclosureUrl: enclosureUrl ?? this.enclosureUrl,
      enclosureMime: enclosureMime ?? this.enclosureMime,
      enclosureLength: enclosureLength ?? this.enclosureLength,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      imageAspect: imageAspect ?? this.imageAspect,
      featured: featured ?? this.featured,
      tagsJson: tagsJson ?? this.tagsJson,
      publishedAt: publishedAt ?? this.publishedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      readAt: readAt ?? this.readAt,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (contentHtml.present) {
      map['content_html'] = Variable<String>(contentHtml.value);
    }
    if (contentText.present) {
      map['content_text'] = Variable<String>(contentText.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (enclosureUrl.present) {
      map['enclosure_url'] = Variable<String>(enclosureUrl.value);
    }
    if (enclosureMime.present) {
      map['enclosure_mime'] = Variable<String>(enclosureMime.value);
    }
    if (enclosureLength.present) {
      map['enclosure_length'] = Variable<int>(enclosureLength.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (imageAspect.present) {
      map['image_aspect'] = Variable<double>(imageAspect.value);
    }
    if (featured.present) {
      map['featured'] = Variable<bool>(featured.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (bookmarkedAt.present) {
      map['bookmarked_at'] = Variable<DateTime>(bookmarkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('guid: $guid, ')
          ..write('link: $link, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('contentText: $contentText, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('mediaType: $mediaType, ')
          ..write('enclosureUrl: $enclosureUrl, ')
          ..write('enclosureMime: $enclosureMime, ')
          ..write('enclosureLength: $enclosureLength, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('imageAspect: $imageAspect, ')
          ..write('featured: $featured, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('readAt: $readAt, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatSessionsTable extends ChatSessions
    with TableInfo<$ChatSessionsTable, ChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companionSnapshotJsonMeta =
      const VerificationMeta('companionSnapshotJson');
  @override
  late final GeneratedColumn<String> companionSnapshotJson =
      GeneratedColumn<String>(
        'companion_snapshot_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    articleId,
    companionSnapshotJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('companion_snapshot_json')) {
      context.handle(
        _companionSnapshotJsonMeta,
        companionSnapshotJson.isAcceptableOrUnknown(
          data['companion_snapshot_json']!,
          _companionSnapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {articleId},
  ];
  @override
  ChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      companionSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}companion_snapshot_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChatSessionsTable createAlias(String alias) {
    return $ChatSessionsTable(attachedDatabase, alias);
  }
}

class ChatSession extends DataClass implements Insertable<ChatSession> {
  final String id;
  final String articleId;
  final String? companionSnapshotJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ChatSession({
    required this.id,
    required this.articleId,
    this.companionSnapshotJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['article_id'] = Variable<String>(articleId);
    if (!nullToAbsent || companionSnapshotJson != null) {
      map['companion_snapshot_json'] = Variable<String>(companionSnapshotJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return ChatSessionsCompanion(
      id: Value(id),
      articleId: Value(articleId),
      companionSnapshotJson: companionSnapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(companionSnapshotJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChatSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatSession(
      id: serializer.fromJson<String>(json['id']),
      articleId: serializer.fromJson<String>(json['articleId']),
      companionSnapshotJson: serializer.fromJson<String?>(
        json['companionSnapshotJson'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'articleId': serializer.toJson<String>(articleId),
      'companionSnapshotJson': serializer.toJson<String?>(
        companionSnapshotJson,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChatSession copyWith({
    String? id,
    String? articleId,
    Value<String?> companionSnapshotJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ChatSession(
    id: id ?? this.id,
    articleId: articleId ?? this.articleId,
    companionSnapshotJson: companionSnapshotJson.present
        ? companionSnapshotJson.value
        : this.companionSnapshotJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChatSession copyWithCompanion(ChatSessionsCompanion data) {
    return ChatSession(
      id: data.id.present ? data.id.value : this.id,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      companionSnapshotJson: data.companionSnapshotJson.present
          ? data.companionSnapshotJson.value
          : this.companionSnapshotJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatSession(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('companionSnapshotJson: $companionSnapshotJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, articleId, companionSnapshotJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatSession &&
          other.id == this.id &&
          other.articleId == this.articleId &&
          other.companionSnapshotJson == this.companionSnapshotJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChatSessionsCompanion extends UpdateCompanion<ChatSession> {
  final Value<String> id;
  final Value<String> articleId;
  final Value<String?> companionSnapshotJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChatSessionsCompanion({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
    this.companionSnapshotJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatSessionsCompanion.insert({
    required String id,
    required String articleId,
    this.companionSnapshotJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       articleId = Value(articleId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatSession> custom({
    Expression<String>? id,
    Expression<String>? articleId,
    Expression<String>? companionSnapshotJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (articleId != null) 'article_id': articleId,
      if (companionSnapshotJson != null)
        'companion_snapshot_json': companionSnapshotJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? articleId,
    Value<String?>? companionSnapshotJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChatSessionsCompanion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      companionSnapshotJson:
          companionSnapshotJson ?? this.companionSnapshotJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (companionSnapshotJson.present) {
      map['companion_snapshot_json'] = Variable<String>(
        companionSnapshotJson.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('companionSnapshotJson: $companionSnapshotJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_sessions (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    role,
    content,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, role, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String sessionId,
    required String role,
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaChatMessagesTable extends MediaChatMessages
    with TableInfo<$MediaChatMessagesTable, MediaChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    articleId,
    role,
    content,
    status,
    error,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaChatMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaChatMessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MediaChatMessagesTable createAlias(String alias) {
    return $MediaChatMessagesTable(attachedDatabase, alias);
  }
}

class MediaChatMessageRow extends DataClass
    implements Insertable<MediaChatMessageRow> {
  final String id;
  final String articleId;

  /// user | assistant
  final String role;
  final String content;

  /// pending | completed | failed
  final String status;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MediaChatMessageRow({
    required this.id,
    required this.articleId,
    required this.role,
    required this.content,
    required this.status,
    this.error,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['article_id'] = Variable<String>(articleId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MediaChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return MediaChatMessagesCompanion(
      id: Value(id),
      articleId: Value(articleId),
      role: Value(role),
      content: Value(content),
      status: Value(status),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MediaChatMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaChatMessageRow(
      id: serializer.fromJson<String>(json['id']),
      articleId: serializer.fromJson<String>(json['articleId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      status: serializer.fromJson<String>(json['status']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'articleId': serializer.toJson<String>(articleId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'status': serializer.toJson<String>(status),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MediaChatMessageRow copyWith({
    String? id,
    String? articleId,
    String? role,
    String? content,
    String? status,
    Value<String?> error = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MediaChatMessageRow(
    id: id ?? this.id,
    articleId: articleId ?? this.articleId,
    role: role ?? this.role,
    content: content ?? this.content,
    status: status ?? this.status,
    error: error.present ? error.value : this.error,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MediaChatMessageRow copyWithCompanion(MediaChatMessagesCompanion data) {
    return MediaChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaChatMessageRow(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    articleId,
    role,
    content,
    status,
    error,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaChatMessageRow &&
          other.id == this.id &&
          other.articleId == this.articleId &&
          other.role == this.role &&
          other.content == this.content &&
          other.status == this.status &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MediaChatMessagesCompanion extends UpdateCompanion<MediaChatMessageRow> {
  final Value<String> id;
  final Value<String> articleId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> status;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MediaChatMessagesCompanion({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaChatMessagesCompanion.insert({
    required String id,
    required String articleId,
    required String role,
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       articleId = Value(articleId),
       role = Value(role),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MediaChatMessageRow> custom({
    Expression<String>? id,
    Expression<String>? articleId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? status,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (articleId != null) 'article_id': articleId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? articleId,
    Value<String>? role,
    Value<String>? content,
    Value<String>? status,
    Value<String?>? error,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MediaChatMessagesCompanion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      role: role ?? this.role,
      content: content ?? this.content,
      status: status ?? this.status,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompanionsTable extends Companions
    with TableInfo<$CompanionsTable, CompanionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleLabelMeta = const VerificationMeta(
    'styleLabel',
  );
  @override
  late final GeneratedColumn<String> styleLabel = GeneratedColumn<String>(
    'style_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemHintMeta = const VerificationMeta(
    'systemHint',
  );
  @override
  late final GeneratedColumn<String> systemHint = GeneratedColumn<String>(
    'system_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    styleLabel,
    systemHint,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('style_label')) {
      context.handle(
        _styleLabelMeta,
        styleLabel.isAcceptableOrUnknown(data['style_label']!, _styleLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_styleLabelMeta);
    }
    if (data.containsKey('system_hint')) {
      context.handle(
        _systemHintMeta,
        systemHint.isAcceptableOrUnknown(data['system_hint']!, _systemHintMeta),
      );
    } else if (isInserting) {
      context.missing(_systemHintMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompanionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      styleLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_label'],
      )!,
      systemHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_hint'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CompanionsTable createAlias(String alias) {
    return $CompanionsTable(attachedDatabase, alias);
  }
}

class CompanionRow extends DataClass implements Insertable<CompanionRow> {
  final String id;
  final String name;
  final String styleLabel;
  final String systemHint;
  final DateTime updatedAt;
  const CompanionRow({
    required this.id,
    required this.name,
    required this.styleLabel,
    required this.systemHint,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['style_label'] = Variable<String>(styleLabel);
    map['system_hint'] = Variable<String>(systemHint);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CompanionsCompanion toCompanion(bool nullToAbsent) {
    return CompanionsCompanion(
      id: Value(id),
      name: Value(name),
      styleLabel: Value(styleLabel),
      systemHint: Value(systemHint),
      updatedAt: Value(updatedAt),
    );
  }

  factory CompanionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      styleLabel: serializer.fromJson<String>(json['styleLabel']),
      systemHint: serializer.fromJson<String>(json['systemHint']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'styleLabel': serializer.toJson<String>(styleLabel),
      'systemHint': serializer.toJson<String>(systemHint),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CompanionRow copyWith({
    String? id,
    String? name,
    String? styleLabel,
    String? systemHint,
    DateTime? updatedAt,
  }) => CompanionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    styleLabel: styleLabel ?? this.styleLabel,
    systemHint: systemHint ?? this.systemHint,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CompanionRow copyWithCompanion(CompanionsCompanion data) {
    return CompanionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      styleLabel: data.styleLabel.present
          ? data.styleLabel.value
          : this.styleLabel,
      systemHint: data.systemHint.present
          ? data.systemHint.value
          : this.systemHint,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('styleLabel: $styleLabel, ')
          ..write('systemHint: $systemHint, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, styleLabel, systemHint, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.styleLabel == this.styleLabel &&
          other.systemHint == this.systemHint &&
          other.updatedAt == this.updatedAt);
}

class CompanionsCompanion extends UpdateCompanion<CompanionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> styleLabel;
  final Value<String> systemHint;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CompanionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.styleLabel = const Value.absent(),
    this.systemHint = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanionsCompanion.insert({
    required String id,
    required String name,
    required String styleLabel,
    required String systemHint,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       styleLabel = Value(styleLabel),
       systemHint = Value(systemHint),
       updatedAt = Value(updatedAt);
  static Insertable<CompanionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? styleLabel,
    Expression<String>? systemHint,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (styleLabel != null) 'style_label': styleLabel,
      if (systemHint != null) 'system_hint': systemHint,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? styleLabel,
    Value<String>? systemHint,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CompanionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      styleLabel: styleLabel ?? this.styleLabel,
      systemHint: systemHint ?? this.systemHint,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (styleLabel.present) {
      map['style_label'] = Variable<String>(styleLabel.value);
    }
    if (systemHint.present) {
      map['system_hint'] = Variable<String>(systemHint.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('styleLabel: $styleLabel, ')
          ..write('systemHint: $systemHint, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, displayName, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final String id;
  final String displayName;
  final DateTime updatedAt;
  const UserProfileRow({
    required this.id,
    required this.displayName,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileRow copyWith({
    String? id,
    String? displayName,
    DateTime? updatedAt,
  }) => UserProfileRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String displayName,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfileRow> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarmEventsTable extends WarmEvents
    with TableInfo<$WarmEventsTable, WarmEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarmEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    subtitle,
    articleId,
    payloadJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warm_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<WarmEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WarmEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WarmEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WarmEventsTable createAlias(String alias) {
    return $WarmEventsTable(attachedDatabase, alias);
  }
}

class WarmEvent extends DataClass implements Insertable<WarmEvent> {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String? articleId;
  final String? payloadJson;
  final DateTime createdAt;
  const WarmEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.articleId,
    this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    if (!nullToAbsent || articleId != null) {
      map['article_id'] = Variable<String>(articleId);
    }
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WarmEventsCompanion toCompanion(bool nullToAbsent) {
    return WarmEventsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      subtitle: Value(subtitle),
      articleId: articleId == null && nullToAbsent
          ? const Value.absent()
          : Value(articleId),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory WarmEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WarmEvent(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      articleId: serializer.fromJson<String?>(json['articleId']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'articleId': serializer.toJson<String?>(articleId),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WarmEvent copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    Value<String?> articleId = const Value.absent(),
    Value<String?> payloadJson = const Value.absent(),
    DateTime? createdAt,
  }) => WarmEvent(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    articleId: articleId.present ? articleId.value : this.articleId,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
  );
  WarmEvent copyWithCompanion(WarmEventsCompanion data) {
    return WarmEvent(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WarmEvent(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('articleId: $articleId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, title, subtitle, articleId, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WarmEvent &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.articleId == this.articleId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class WarmEventsCompanion extends UpdateCompanion<WarmEvent> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String?> articleId;
  final Value<String?> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WarmEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.articleId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarmEventsCompanion.insert({
    required String id,
    required String type,
    required String title,
    required String subtitle,
    this.articleId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       subtitle = Value(subtitle),
       createdAt = Value(createdAt);
  static Insertable<WarmEvent> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? articleId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (articleId != null) 'article_id': articleId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarmEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String>? subtitle,
    Value<String?>? articleId,
    Value<String?>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WarmEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      articleId: articleId ?? this.articleId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarmEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('articleId: $articleId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsRowsTable extends AppSettingsRows
    with TableInfo<$AppSettingsRowsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _fontScaleMeta = const VerificationMeta(
    'fontScale',
  );
  @override
  late final GeneratedColumn<double> fontScale = GeneratedColumn<double>(
    'font_scale',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _refreshMinutesMeta = const VerificationMeta(
    'refreshMinutes',
  );
  @override
  late final GeneratedColumn<int> refreshMinutes = GeneratedColumn<int>(
    'refresh_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _wifiOnlyMeta = const VerificationMeta(
    'wifiOnly',
  );
  @override
  late final GeneratedColumn<bool> wifiOnly = GeneratedColumn<bool>(
    'wifi_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _llmBaseUrlMeta = const VerificationMeta(
    'llmBaseUrl',
  );
  @override
  late final GeneratedColumn<String> llmBaseUrl = GeneratedColumn<String>(
    'llm_base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('https://api.openai.com/v1'),
  );
  static const VerificationMeta _llmModelMeta = const VerificationMeta(
    'llmModel',
  );
  @override
  late final GeneratedColumn<String> llmModel = GeneratedColumn<String>(
    'llm_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gpt-4o-mini'),
  );
  static const VerificationMeta _useMockFeedMeta = const VerificationMeta(
    'useMockFeed',
  );
  @override
  late final GeneratedColumn<bool> useMockFeed = GeneratedColumn<bool>(
    'use_mock_feed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_mock_feed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _commentTriggerMeta = const VerificationMeta(
    'commentTrigger',
  );
  @override
  late final GeneratedColumn<String> commentTrigger = GeneratedColumn<String>(
    'comment_trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('onOpenComments'),
  );
  static const VerificationMeta _feedFilterJsonMeta = const VerificationMeta(
    'feedFilterJson',
  );
  @override
  late final GeneratedColumn<String> feedFilterJson = GeneratedColumn<String>(
    'feed_filter_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    fontScale,
    refreshMinutes,
    wifiOnly,
    notificationsEnabled,
    llmBaseUrl,
    llmModel,
    useMockFeed,
    commentTrigger,
    feedFilterJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('font_scale')) {
      context.handle(
        _fontScaleMeta,
        fontScale.isAcceptableOrUnknown(data['font_scale']!, _fontScaleMeta),
      );
    }
    if (data.containsKey('refresh_minutes')) {
      context.handle(
        _refreshMinutesMeta,
        refreshMinutes.isAcceptableOrUnknown(
          data['refresh_minutes']!,
          _refreshMinutesMeta,
        ),
      );
    }
    if (data.containsKey('wifi_only')) {
      context.handle(
        _wifiOnlyMeta,
        wifiOnly.isAcceptableOrUnknown(data['wifi_only']!, _wifiOnlyMeta),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('llm_base_url')) {
      context.handle(
        _llmBaseUrlMeta,
        llmBaseUrl.isAcceptableOrUnknown(
          data['llm_base_url']!,
          _llmBaseUrlMeta,
        ),
      );
    }
    if (data.containsKey('llm_model')) {
      context.handle(
        _llmModelMeta,
        llmModel.isAcceptableOrUnknown(data['llm_model']!, _llmModelMeta),
      );
    }
    if (data.containsKey('use_mock_feed')) {
      context.handle(
        _useMockFeedMeta,
        useMockFeed.isAcceptableOrUnknown(
          data['use_mock_feed']!,
          _useMockFeedMeta,
        ),
      );
    }
    if (data.containsKey('comment_trigger')) {
      context.handle(
        _commentTriggerMeta,
        commentTrigger.isAcceptableOrUnknown(
          data['comment_trigger']!,
          _commentTriggerMeta,
        ),
      );
    }
    if (data.containsKey('feed_filter_json')) {
      context.handle(
        _feedFilterJsonMeta,
        feedFilterJson.isAcceptableOrUnknown(
          data['feed_filter_json']!,
          _feedFilterJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      fontScale: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}font_scale'],
      )!,
      refreshMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refresh_minutes'],
      )!,
      wifiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      llmBaseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_base_url'],
      )!,
      llmModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_model'],
      )!,
      useMockFeed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_mock_feed'],
      )!,
      commentTrigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment_trigger'],
      )!,
      feedFilterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_filter_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsRowsTable createAlias(String alias) {
    return $AppSettingsRowsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final String id;
  final String themeMode;
  final double fontScale;
  final int refreshMinutes;
  final bool wifiOnly;
  final bool notificationsEnabled;
  final String llmBaseUrl;
  final String llmModel;
  final bool useMockFeed;
  final String commentTrigger;

  /// New-page stream filter JSON: {onlyToday, onlyUnread, feedIds}.
  final String feedFilterJson;
  final DateTime updatedAt;
  const AppSettingsRow({
    required this.id,
    required this.themeMode,
    required this.fontScale,
    required this.refreshMinutes,
    required this.wifiOnly,
    required this.notificationsEnabled,
    required this.llmBaseUrl,
    required this.llmModel,
    required this.useMockFeed,
    required this.commentTrigger,
    required this.feedFilterJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['font_scale'] = Variable<double>(fontScale);
    map['refresh_minutes'] = Variable<int>(refreshMinutes);
    map['wifi_only'] = Variable<bool>(wifiOnly);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['llm_base_url'] = Variable<String>(llmBaseUrl);
    map['llm_model'] = Variable<String>(llmModel);
    map['use_mock_feed'] = Variable<bool>(useMockFeed);
    map['comment_trigger'] = Variable<String>(commentTrigger);
    map['feed_filter_json'] = Variable<String>(feedFilterJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsRowsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      fontScale: Value(fontScale),
      refreshMinutes: Value(refreshMinutes),
      wifiOnly: Value(wifiOnly),
      notificationsEnabled: Value(notificationsEnabled),
      llmBaseUrl: Value(llmBaseUrl),
      llmModel: Value(llmModel),
      useMockFeed: Value(useMockFeed),
      commentTrigger: Value(commentTrigger),
      feedFilterJson: Value(feedFilterJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      fontScale: serializer.fromJson<double>(json['fontScale']),
      refreshMinutes: serializer.fromJson<int>(json['refreshMinutes']),
      wifiOnly: serializer.fromJson<bool>(json['wifiOnly']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      llmBaseUrl: serializer.fromJson<String>(json['llmBaseUrl']),
      llmModel: serializer.fromJson<String>(json['llmModel']),
      useMockFeed: serializer.fromJson<bool>(json['useMockFeed']),
      commentTrigger: serializer.fromJson<String>(json['commentTrigger']),
      feedFilterJson: serializer.fromJson<String>(json['feedFilterJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'fontScale': serializer.toJson<double>(fontScale),
      'refreshMinutes': serializer.toJson<int>(refreshMinutes),
      'wifiOnly': serializer.toJson<bool>(wifiOnly),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'llmBaseUrl': serializer.toJson<String>(llmBaseUrl),
      'llmModel': serializer.toJson<String>(llmModel),
      'useMockFeed': serializer.toJson<bool>(useMockFeed),
      'commentTrigger': serializer.toJson<String>(commentTrigger),
      'feedFilterJson': serializer.toJson<String>(feedFilterJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsRow copyWith({
    String? id,
    String? themeMode,
    double? fontScale,
    int? refreshMinutes,
    bool? wifiOnly,
    bool? notificationsEnabled,
    String? llmBaseUrl,
    String? llmModel,
    bool? useMockFeed,
    String? commentTrigger,
    String? feedFilterJson,
    DateTime? updatedAt,
  }) => AppSettingsRow(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    fontScale: fontScale ?? this.fontScale,
    refreshMinutes: refreshMinutes ?? this.refreshMinutes,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    llmBaseUrl: llmBaseUrl ?? this.llmBaseUrl,
    llmModel: llmModel ?? this.llmModel,
    useMockFeed: useMockFeed ?? this.useMockFeed,
    commentTrigger: commentTrigger ?? this.commentTrigger,
    feedFilterJson: feedFilterJson ?? this.feedFilterJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsRowsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      fontScale: data.fontScale.present ? data.fontScale.value : this.fontScale,
      refreshMinutes: data.refreshMinutes.present
          ? data.refreshMinutes.value
          : this.refreshMinutes,
      wifiOnly: data.wifiOnly.present ? data.wifiOnly.value : this.wifiOnly,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      llmBaseUrl: data.llmBaseUrl.present
          ? data.llmBaseUrl.value
          : this.llmBaseUrl,
      llmModel: data.llmModel.present ? data.llmModel.value : this.llmModel,
      useMockFeed: data.useMockFeed.present
          ? data.useMockFeed.value
          : this.useMockFeed,
      commentTrigger: data.commentTrigger.present
          ? data.commentTrigger.value
          : this.commentTrigger,
      feedFilterJson: data.feedFilterJson.present
          ? data.feedFilterJson.value
          : this.feedFilterJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('fontScale: $fontScale, ')
          ..write('refreshMinutes: $refreshMinutes, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('llmBaseUrl: $llmBaseUrl, ')
          ..write('llmModel: $llmModel, ')
          ..write('useMockFeed: $useMockFeed, ')
          ..write('commentTrigger: $commentTrigger, ')
          ..write('feedFilterJson: $feedFilterJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    fontScale,
    refreshMinutes,
    wifiOnly,
    notificationsEnabled,
    llmBaseUrl,
    llmModel,
    useMockFeed,
    commentTrigger,
    feedFilterJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.fontScale == this.fontScale &&
          other.refreshMinutes == this.refreshMinutes &&
          other.wifiOnly == this.wifiOnly &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.llmBaseUrl == this.llmBaseUrl &&
          other.llmModel == this.llmModel &&
          other.useMockFeed == this.useMockFeed &&
          other.commentTrigger == this.commentTrigger &&
          other.feedFilterJson == this.feedFilterJson &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsRowsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<String> id;
  final Value<String> themeMode;
  final Value<double> fontScale;
  final Value<int> refreshMinutes;
  final Value<bool> wifiOnly;
  final Value<bool> notificationsEnabled;
  final Value<String> llmBaseUrl;
  final Value<String> llmModel;
  final Value<bool> useMockFeed;
  final Value<String> commentTrigger;
  final Value<String> feedFilterJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsRowsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.fontScale = const Value.absent(),
    this.refreshMinutes = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.llmBaseUrl = const Value.absent(),
    this.llmModel = const Value.absent(),
    this.useMockFeed = const Value.absent(),
    this.commentTrigger = const Value.absent(),
    this.feedFilterJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsRowsCompanion.insert({
    required String id,
    this.themeMode = const Value.absent(),
    this.fontScale = const Value.absent(),
    this.refreshMinutes = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.llmBaseUrl = const Value.absent(),
    this.llmModel = const Value.absent(),
    this.useMockFeed = const Value.absent(),
    this.commentTrigger = const Value.absent(),
    this.feedFilterJson = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<String>? id,
    Expression<String>? themeMode,
    Expression<double>? fontScale,
    Expression<int>? refreshMinutes,
    Expression<bool>? wifiOnly,
    Expression<bool>? notificationsEnabled,
    Expression<String>? llmBaseUrl,
    Expression<String>? llmModel,
    Expression<bool>? useMockFeed,
    Expression<String>? commentTrigger,
    Expression<String>? feedFilterJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (fontScale != null) 'font_scale': fontScale,
      if (refreshMinutes != null) 'refresh_minutes': refreshMinutes,
      if (wifiOnly != null) 'wifi_only': wifiOnly,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (llmBaseUrl != null) 'llm_base_url': llmBaseUrl,
      if (llmModel != null) 'llm_model': llmModel,
      if (useMockFeed != null) 'use_mock_feed': useMockFeed,
      if (commentTrigger != null) 'comment_trigger': commentTrigger,
      if (feedFilterJson != null) 'feed_filter_json': feedFilterJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? themeMode,
    Value<double>? fontScale,
    Value<int>? refreshMinutes,
    Value<bool>? wifiOnly,
    Value<bool>? notificationsEnabled,
    Value<String>? llmBaseUrl,
    Value<String>? llmModel,
    Value<bool>? useMockFeed,
    Value<String>? commentTrigger,
    Value<String>? feedFilterJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsRowsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      refreshMinutes: refreshMinutes ?? this.refreshMinutes,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      llmBaseUrl: llmBaseUrl ?? this.llmBaseUrl,
      llmModel: llmModel ?? this.llmModel,
      useMockFeed: useMockFeed ?? this.useMockFeed,
      commentTrigger: commentTrigger ?? this.commentTrigger,
      feedFilterJson: feedFilterJson ?? this.feedFilterJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (fontScale.present) {
      map['font_scale'] = Variable<double>(fontScale.value);
    }
    if (refreshMinutes.present) {
      map['refresh_minutes'] = Variable<int>(refreshMinutes.value);
    }
    if (wifiOnly.present) {
      map['wifi_only'] = Variable<bool>(wifiOnly.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (llmBaseUrl.present) {
      map['llm_base_url'] = Variable<String>(llmBaseUrl.value);
    }
    if (llmModel.present) {
      map['llm_model'] = Variable<String>(llmModel.value);
    }
    if (useMockFeed.present) {
      map['use_mock_feed'] = Variable<bool>(useMockFeed.value);
    }
    if (commentTrigger.present) {
      map['comment_trigger'] = Variable<String>(commentTrigger.value);
    }
    if (feedFilterJson.present) {
      map['feed_filter_json'] = Variable<String>(feedFilterJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('fontScale: $fontScale, ')
          ..write('refreshMinutes: $refreshMinutes, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('llmBaseUrl: $llmBaseUrl, ')
          ..write('llmModel: $llmModel, ')
          ..write('useMockFeed: $useMockFeed, ')
          ..write('commentTrigger: $commentTrigger, ')
          ..write('feedFilterJson: $feedFilterJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LlmProvidersTable extends LlmProviders
    with TableInfo<$LlmProvidersTable, LlmProviderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LlmProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolMeta = const VerificationMeta(
    'protocol',
  );
  @override
  late final GeneratedColumn<String> protocol = GeneratedColumn<String>(
    'protocol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _maxConcurrentMeta = const VerificationMeta(
    'maxConcurrent',
  );
  @override
  late final GeneratedColumn<int> maxConcurrent = GeneratedColumn<int>(
    'max_concurrent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _requestsPerMinuteMeta = const VerificationMeta(
    'requestsPerMinute',
  );
  @override
  late final GeneratedColumn<int> requestsPerMinute = GeneratedColumn<int>(
    'requests_per_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    protocol,
    baseUrl,
    isEnabled,
    maxConcurrent,
    requestsPerMinute,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'llm_providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LlmProviderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('protocol')) {
      context.handle(
        _protocolMeta,
        protocol.isAcceptableOrUnknown(data['protocol']!, _protocolMeta),
      );
    } else if (isInserting) {
      context.missing(_protocolMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('max_concurrent')) {
      context.handle(
        _maxConcurrentMeta,
        maxConcurrent.isAcceptableOrUnknown(
          data['max_concurrent']!,
          _maxConcurrentMeta,
        ),
      );
    }
    if (data.containsKey('requests_per_minute')) {
      context.handle(
        _requestsPerMinuteMeta,
        requestsPerMinute.isAcceptableOrUnknown(
          data['requests_per_minute']!,
          _requestsPerMinuteMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LlmProviderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LlmProviderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      protocol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      maxConcurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_concurrent'],
      )!,
      requestsPerMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requests_per_minute'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LlmProvidersTable createAlias(String alias) {
    return $LlmProvidersTable(attachedDatabase, alias);
  }
}

class LlmProviderRow extends DataClass implements Insertable<LlmProviderRow> {
  final String id;
  final String name;
  final String protocol;
  final String baseUrl;
  final bool isEnabled;
  final int maxConcurrent;
  final int requestsPerMinute;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LlmProviderRow({
    required this.id,
    required this.name,
    required this.protocol,
    required this.baseUrl,
    required this.isEnabled,
    required this.maxConcurrent,
    required this.requestsPerMinute,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['protocol'] = Variable<String>(protocol);
    map['base_url'] = Variable<String>(baseUrl);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['max_concurrent'] = Variable<int>(maxConcurrent);
    map['requests_per_minute'] = Variable<int>(requestsPerMinute);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LlmProvidersCompanion toCompanion(bool nullToAbsent) {
    return LlmProvidersCompanion(
      id: Value(id),
      name: Value(name),
      protocol: Value(protocol),
      baseUrl: Value(baseUrl),
      isEnabled: Value(isEnabled),
      maxConcurrent: Value(maxConcurrent),
      requestsPerMinute: Value(requestsPerMinute),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LlmProviderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LlmProviderRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      protocol: serializer.fromJson<String>(json['protocol']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      maxConcurrent: serializer.fromJson<int>(json['maxConcurrent']),
      requestsPerMinute: serializer.fromJson<int>(json['requestsPerMinute']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'protocol': serializer.toJson<String>(protocol),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'maxConcurrent': serializer.toJson<int>(maxConcurrent),
      'requestsPerMinute': serializer.toJson<int>(requestsPerMinute),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LlmProviderRow copyWith({
    String? id,
    String? name,
    String? protocol,
    String? baseUrl,
    bool? isEnabled,
    int? maxConcurrent,
    int? requestsPerMinute,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LlmProviderRow(
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
  LlmProviderRow copyWithCompanion(LlmProvidersCompanion data) {
    return LlmProviderRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      maxConcurrent: data.maxConcurrent.present
          ? data.maxConcurrent.value
          : this.maxConcurrent,
      requestsPerMinute: data.requestsPerMinute.present
          ? data.requestsPerMinute.value
          : this.requestsPerMinute,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LlmProviderRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('protocol: $protocol, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('maxConcurrent: $maxConcurrent, ')
          ..write('requestsPerMinute: $requestsPerMinute, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    protocol,
    baseUrl,
    isEnabled,
    maxConcurrent,
    requestsPerMinute,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LlmProviderRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.protocol == this.protocol &&
          other.baseUrl == this.baseUrl &&
          other.isEnabled == this.isEnabled &&
          other.maxConcurrent == this.maxConcurrent &&
          other.requestsPerMinute == this.requestsPerMinute &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LlmProvidersCompanion extends UpdateCompanion<LlmProviderRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> protocol;
  final Value<String> baseUrl;
  final Value<bool> isEnabled;
  final Value<int> maxConcurrent;
  final Value<int> requestsPerMinute;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LlmProvidersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.protocol = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.maxConcurrent = const Value.absent(),
    this.requestsPerMinute = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LlmProvidersCompanion.insert({
    required String id,
    required String name,
    required String protocol,
    required String baseUrl,
    this.isEnabled = const Value.absent(),
    this.maxConcurrent = const Value.absent(),
    this.requestsPerMinute = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       protocol = Value(protocol),
       baseUrl = Value(baseUrl),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LlmProviderRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? protocol,
    Expression<String>? baseUrl,
    Expression<bool>? isEnabled,
    Expression<int>? maxConcurrent,
    Expression<int>? requestsPerMinute,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (protocol != null) 'protocol': protocol,
      if (baseUrl != null) 'base_url': baseUrl,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (maxConcurrent != null) 'max_concurrent': maxConcurrent,
      if (requestsPerMinute != null) 'requests_per_minute': requestsPerMinute,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LlmProvidersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? protocol,
    Value<String>? baseUrl,
    Value<bool>? isEnabled,
    Value<int>? maxConcurrent,
    Value<int>? requestsPerMinute,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LlmProvidersCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (protocol.present) {
      map['protocol'] = Variable<String>(protocol.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (maxConcurrent.present) {
      map['max_concurrent'] = Variable<int>(maxConcurrent.value);
    }
    if (requestsPerMinute.present) {
      map['requests_per_minute'] = Variable<int>(requestsPerMinute.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LlmProvidersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('protocol: $protocol, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('maxConcurrent: $maxConcurrent, ')
          ..write('requestsPerMinute: $requestsPerMinute, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LlmModelsTable extends LlmModels
    with TableInfo<$LlmModelsTable, LlmModelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LlmModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES llm_providers (id)',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    modelId,
    displayName,
    isDefault,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'llm_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<LlmModelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LlmModelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LlmModelRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LlmModelsTable createAlias(String alias) {
    return $LlmModelsTable(attachedDatabase, alias);
  }
}

class LlmModelRow extends DataClass implements Insertable<LlmModelRow> {
  final String id;
  final String providerId;
  final String modelId;
  final String displayName;
  final bool isDefault;
  final int sortOrder;
  const LlmModelRow({
    required this.id,
    required this.providerId,
    required this.modelId,
    required this.displayName,
    required this.isDefault,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['model_id'] = Variable<String>(modelId);
    map['display_name'] = Variable<String>(displayName);
    map['is_default'] = Variable<bool>(isDefault);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LlmModelsCompanion toCompanion(bool nullToAbsent) {
    return LlmModelsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      modelId: Value(modelId),
      displayName: Value(displayName),
      isDefault: Value(isDefault),
      sortOrder: Value(sortOrder),
    );
  }

  factory LlmModelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LlmModelRow(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'modelId': serializer.toJson<String>(modelId),
      'displayName': serializer.toJson<String>(displayName),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LlmModelRow copyWith({
    String? id,
    String? providerId,
    String? modelId,
    String? displayName,
    bool? isDefault,
    int? sortOrder,
  }) => LlmModelRow(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    modelId: modelId ?? this.modelId,
    displayName: displayName ?? this.displayName,
    isDefault: isDefault ?? this.isDefault,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LlmModelRow copyWithCompanion(LlmModelsCompanion data) {
    return LlmModelRow(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LlmModelRow(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('displayName: $displayName, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, providerId, modelId, displayName, isDefault, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LlmModelRow &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.modelId == this.modelId &&
          other.displayName == this.displayName &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder);
}

class LlmModelsCompanion extends UpdateCompanion<LlmModelRow> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> modelId;
  final Value<String> displayName;
  final Value<bool> isDefault;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LlmModelsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LlmModelsCompanion.insert({
    required String id,
    required String providerId,
    required String modelId,
    required String displayName,
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       modelId = Value(modelId),
       displayName = Value(displayName);
  static Insertable<LlmModelRow> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<String>? displayName,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (displayName != null) 'display_name': displayName,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LlmModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? modelId,
    Value<String>? displayName,
    Value<bool>? isDefault,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LlmModelsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      displayName: displayName ?? this.displayName,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LlmModelsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('displayName: $displayName, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetizensTable extends Netizens
    with TableInfo<$NetizensTable, NetizenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetizensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleLabelMeta = const VerificationMeta(
    'styleLabel',
  );
  @override
  late final GeneratedColumn<String> styleLabel = GeneratedColumn<String>(
    'style_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemHintMeta = const VerificationMeta(
    'systemHint',
  );
  @override
  late final GeneratedColumn<String> systemHint = GeneratedColumn<String>(
    'system_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.6),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    styleLabel,
    systemHint,
    avatarPath,
    weight,
    providerId,
    modelId,
    isEnabled,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'netizens';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetizenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('style_label')) {
      context.handle(
        _styleLabelMeta,
        styleLabel.isAcceptableOrUnknown(data['style_label']!, _styleLabelMeta),
      );
    }
    if (data.containsKey('system_hint')) {
      context.handle(
        _systemHintMeta,
        systemHint.isAcceptableOrUnknown(data['system_hint']!, _systemHintMeta),
      );
    } else if (isInserting) {
      context.missing(_systemHintMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetizenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetizenRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      styleLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_label'],
      ),
      systemHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_hint'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NetizensTable createAlias(String alias) {
    return $NetizensTable(attachedDatabase, alias);
  }
}

class NetizenRow extends DataClass implements Insertable<NetizenRow> {
  final String id;
  final String name;
  final String? styleLabel;
  final String systemHint;
  final String? avatarPath;
  final double weight;
  final String? providerId;
  final String? modelId;
  final bool isEnabled;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NetizenRow({
    required this.id,
    required this.name,
    this.styleLabel,
    required this.systemHint,
    this.avatarPath,
    required this.weight,
    this.providerId,
    this.modelId,
    required this.isEnabled,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || styleLabel != null) {
      map['style_label'] = Variable<String>(styleLabel);
    }
    map['system_hint'] = Variable<String>(systemHint);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NetizensCompanion toCompanion(bool nullToAbsent) {
    return NetizensCompanion(
      id: Value(id),
      name: Value(name),
      styleLabel: styleLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(styleLabel),
      systemHint: Value(systemHint),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      weight: Value(weight),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      isEnabled: Value(isEnabled),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NetizenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetizenRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      styleLabel: serializer.fromJson<String?>(json['styleLabel']),
      systemHint: serializer.fromJson<String>(json['systemHint']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      weight: serializer.fromJson<double>(json['weight']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'styleLabel': serializer.toJson<String?>(styleLabel),
      'systemHint': serializer.toJson<String>(systemHint),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'weight': serializer.toJson<double>(weight),
      'providerId': serializer.toJson<String?>(providerId),
      'modelId': serializer.toJson<String?>(modelId),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NetizenRow copyWith({
    String? id,
    String? name,
    Value<String?> styleLabel = const Value.absent(),
    String? systemHint,
    Value<String?> avatarPath = const Value.absent(),
    double? weight,
    Value<String?> providerId = const Value.absent(),
    Value<String?> modelId = const Value.absent(),
    bool? isEnabled,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NetizenRow(
    id: id ?? this.id,
    name: name ?? this.name,
    styleLabel: styleLabel.present ? styleLabel.value : this.styleLabel,
    systemHint: systemHint ?? this.systemHint,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    weight: weight ?? this.weight,
    providerId: providerId.present ? providerId.value : this.providerId,
    modelId: modelId.present ? modelId.value : this.modelId,
    isEnabled: isEnabled ?? this.isEnabled,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NetizenRow copyWithCompanion(NetizensCompanion data) {
    return NetizenRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      styleLabel: data.styleLabel.present
          ? data.styleLabel.value
          : this.styleLabel,
      systemHint: data.systemHint.present
          ? data.systemHint.value
          : this.systemHint,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      weight: data.weight.present ? data.weight.value : this.weight,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetizenRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('styleLabel: $styleLabel, ')
          ..write('systemHint: $systemHint, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('weight: $weight, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    styleLabel,
    systemHint,
    avatarPath,
    weight,
    providerId,
    modelId,
    isEnabled,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetizenRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.styleLabel == this.styleLabel &&
          other.systemHint == this.systemHint &&
          other.avatarPath == this.avatarPath &&
          other.weight == this.weight &&
          other.providerId == this.providerId &&
          other.modelId == this.modelId &&
          other.isEnabled == this.isEnabled &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NetizensCompanion extends UpdateCompanion<NetizenRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> styleLabel;
  final Value<String> systemHint;
  final Value<String?> avatarPath;
  final Value<double> weight;
  final Value<String?> providerId;
  final Value<String?> modelId;
  final Value<bool> isEnabled;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NetizensCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.styleLabel = const Value.absent(),
    this.systemHint = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.weight = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetizensCompanion.insert({
    required String id,
    required String name,
    this.styleLabel = const Value.absent(),
    required String systemHint,
    this.avatarPath = const Value.absent(),
    this.weight = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       systemHint = Value(systemHint),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NetizenRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? styleLabel,
    Expression<String>? systemHint,
    Expression<String>? avatarPath,
    Expression<double>? weight,
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<bool>? isEnabled,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (styleLabel != null) 'style_label': styleLabel,
      if (systemHint != null) 'system_hint': systemHint,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (weight != null) 'weight': weight,
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetizensCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? styleLabel,
    Value<String>? systemHint,
    Value<String?>? avatarPath,
    Value<double>? weight,
    Value<String?>? providerId,
    Value<String?>? modelId,
    Value<bool>? isEnabled,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NetizensCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      styleLabel: styleLabel ?? this.styleLabel,
      systemHint: systemHint ?? this.systemHint,
      avatarPath: avatarPath ?? this.avatarPath,
      weight: weight ?? this.weight,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (styleLabel.present) {
      map['style_label'] = Variable<String>(styleLabel.value);
    }
    if (systemHint.present) {
      map['system_hint'] = Variable<String>(systemHint.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetizensCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('styleLabel: $styleLabel, ')
          ..write('systemHint: $systemHint, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('weight: $weight, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentsTable extends Comments
    with TableInfo<$CommentsTable, CommentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorTypeMeta = const VerificationMeta(
    'authorType',
  );
  @override
  late final GeneratedColumn<String> authorType = GeneratedColumn<String>(
    'author_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netizenIdMeta = const VerificationMeta(
    'netizenId',
  );
  @override
  late final GeneratedColumn<String> netizenId = GeneratedColumn<String>(
    'netizen_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    articleId,
    authorType,
    netizenId,
    parentId,
    content,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('author_type')) {
      context.handle(
        _authorTypeMeta,
        authorType.isAcceptableOrUnknown(data['author_type']!, _authorTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_authorTypeMeta);
    }
    if (data.containsKey('netizen_id')) {
      context.handle(
        _netizenIdMeta,
        netizenId.isAcceptableOrUnknown(data['netizen_id']!, _netizenIdMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      authorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_type'],
      )!,
      netizenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}netizen_id'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CommentsTable createAlias(String alias) {
    return $CommentsTable(attachedDatabase, alias);
  }
}

class CommentRow extends DataClass implements Insertable<CommentRow> {
  final String id;
  final String articleId;
  final String authorType;
  final String? netizenId;
  final String? parentId;
  final String content;
  final DateTime createdAt;
  const CommentRow({
    required this.id,
    required this.articleId,
    required this.authorType,
    this.netizenId,
    this.parentId,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['article_id'] = Variable<String>(articleId);
    map['author_type'] = Variable<String>(authorType);
    if (!nullToAbsent || netizenId != null) {
      map['netizen_id'] = Variable<String>(netizenId);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CommentsCompanion toCompanion(bool nullToAbsent) {
    return CommentsCompanion(
      id: Value(id),
      articleId: Value(articleId),
      authorType: Value(authorType),
      netizenId: netizenId == null && nullToAbsent
          ? const Value.absent()
          : Value(netizenId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory CommentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentRow(
      id: serializer.fromJson<String>(json['id']),
      articleId: serializer.fromJson<String>(json['articleId']),
      authorType: serializer.fromJson<String>(json['authorType']),
      netizenId: serializer.fromJson<String?>(json['netizenId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'articleId': serializer.toJson<String>(articleId),
      'authorType': serializer.toJson<String>(authorType),
      'netizenId': serializer.toJson<String?>(netizenId),
      'parentId': serializer.toJson<String?>(parentId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CommentRow copyWith({
    String? id,
    String? articleId,
    String? authorType,
    Value<String?> netizenId = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    String? content,
    DateTime? createdAt,
  }) => CommentRow(
    id: id ?? this.id,
    articleId: articleId ?? this.articleId,
    authorType: authorType ?? this.authorType,
    netizenId: netizenId.present ? netizenId.value : this.netizenId,
    parentId: parentId.present ? parentId.value : this.parentId,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  CommentRow copyWithCompanion(CommentsCompanion data) {
    return CommentRow(
      id: data.id.present ? data.id.value : this.id,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      authorType: data.authorType.present
          ? data.authorType.value
          : this.authorType,
      netizenId: data.netizenId.present ? data.netizenId.value : this.netizenId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentRow(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('authorType: $authorType, ')
          ..write('netizenId: $netizenId, ')
          ..write('parentId: $parentId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    articleId,
    authorType,
    netizenId,
    parentId,
    content,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentRow &&
          other.id == this.id &&
          other.articleId == this.articleId &&
          other.authorType == this.authorType &&
          other.netizenId == this.netizenId &&
          other.parentId == this.parentId &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class CommentsCompanion extends UpdateCompanion<CommentRow> {
  final Value<String> id;
  final Value<String> articleId;
  final Value<String> authorType;
  final Value<String?> netizenId;
  final Value<String?> parentId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CommentsCompanion({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
    this.authorType = const Value.absent(),
    this.netizenId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentsCompanion.insert({
    required String id,
    required String articleId,
    required String authorType,
    this.netizenId = const Value.absent(),
    this.parentId = const Value.absent(),
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       articleId = Value(articleId),
       authorType = Value(authorType),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<CommentRow> custom({
    Expression<String>? id,
    Expression<String>? articleId,
    Expression<String>? authorType,
    Expression<String>? netizenId,
    Expression<String>? parentId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (articleId != null) 'article_id': articleId,
      if (authorType != null) 'author_type': authorType,
      if (netizenId != null) 'netizen_id': netizenId,
      if (parentId != null) 'parent_id': parentId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentsCompanion copyWith({
    Value<String>? id,
    Value<String>? articleId,
    Value<String>? authorType,
    Value<String?>? netizenId,
    Value<String?>? parentId,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CommentsCompanion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      authorType: authorType ?? this.authorType,
      netizenId: netizenId ?? this.netizenId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (authorType.present) {
      map['author_type'] = Variable<String>(authorType.value);
    }
    if (netizenId.present) {
      map['netizen_id'] = Variable<String>(netizenId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentsCompanion(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('authorType: $authorType, ')
          ..write('netizenId: $netizenId, ')
          ..write('parentId: $parentId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentJobsTable extends CommentJobs
    with TableInfo<$CommentJobsTable, CommentJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pickedNetizenIdsJsonMeta =
      const VerificationMeta('pickedNetizenIdsJson');
  @override
  late final GeneratedColumn<String> pickedNetizenIdsJson =
      GeneratedColumn<String>(
        'picked_netizen_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxAttemptsMeta = const VerificationMeta(
    'maxAttempts',
  );
  @override
  late final GeneratedColumn<int> maxAttempts = GeneratedColumn<int>(
    'max_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leaseOwnerMeta = const VerificationMeta(
    'leaseOwner',
  );
  @override
  late final GeneratedColumn<String> leaseOwner = GeneratedColumn<String>(
    'lease_owner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leaseUntilMeta = const VerificationMeta(
    'leaseUntil',
  );
  @override
  late final GeneratedColumn<DateTime> leaseUntil = GeneratedColumn<DateTime>(
    'lease_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    articleId,
    status,
    trigger,
    pickedNetizenIdsJson,
    attempt,
    maxAttempts,
    lastError,
    leaseOwner,
    leaseUntil,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comment_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    if (data.containsKey('picked_netizen_ids_json')) {
      context.handle(
        _pickedNetizenIdsJsonMeta,
        pickedNetizenIdsJson.isAcceptableOrUnknown(
          data['picked_netizen_ids_json']!,
          _pickedNetizenIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('max_attempts')) {
      context.handle(
        _maxAttemptsMeta,
        maxAttempts.isAcceptableOrUnknown(
          data['max_attempts']!,
          _maxAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('lease_owner')) {
      context.handle(
        _leaseOwnerMeta,
        leaseOwner.isAcceptableOrUnknown(data['lease_owner']!, _leaseOwnerMeta),
      );
    }
    if (data.containsKey('lease_until')) {
      context.handle(
        _leaseUntilMeta,
        leaseUntil.isAcceptableOrUnknown(data['lease_until']!, _leaseUntilMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentJobRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      pickedNetizenIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}picked_netizen_ids_json'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      maxAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      leaseOwner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lease_owner'],
      ),
      leaseUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lease_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CommentJobsTable createAlias(String alias) {
    return $CommentJobsTable(attachedDatabase, alias);
  }
}

class CommentJobRow extends DataClass implements Insertable<CommentJobRow> {
  final String id;
  final String articleId;

  /// pending | running | completed | failed | cancelled
  final String status;

  /// off | onBrowse | onOpenComments
  final String trigger;

  /// JSON array of netizen ids sampled once for this job.
  final String pickedNetizenIdsJson;
  final int attempt;
  final int maxAttempts;
  final String? lastError;
  final String? leaseOwner;
  final DateTime? leaseUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CommentJobRow({
    required this.id,
    required this.articleId,
    required this.status,
    required this.trigger,
    required this.pickedNetizenIdsJson,
    required this.attempt,
    required this.maxAttempts,
    this.lastError,
    this.leaseOwner,
    this.leaseUntil,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['article_id'] = Variable<String>(articleId);
    map['status'] = Variable<String>(status);
    map['trigger'] = Variable<String>(trigger);
    map['picked_netizen_ids_json'] = Variable<String>(pickedNetizenIdsJson);
    map['attempt'] = Variable<int>(attempt);
    map['max_attempts'] = Variable<int>(maxAttempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || leaseOwner != null) {
      map['lease_owner'] = Variable<String>(leaseOwner);
    }
    if (!nullToAbsent || leaseUntil != null) {
      map['lease_until'] = Variable<DateTime>(leaseUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CommentJobsCompanion toCompanion(bool nullToAbsent) {
    return CommentJobsCompanion(
      id: Value(id),
      articleId: Value(articleId),
      status: Value(status),
      trigger: Value(trigger),
      pickedNetizenIdsJson: Value(pickedNetizenIdsJson),
      attempt: Value(attempt),
      maxAttempts: Value(maxAttempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      leaseOwner: leaseOwner == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseOwner),
      leaseUntil: leaseUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CommentJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentJobRow(
      id: serializer.fromJson<String>(json['id']),
      articleId: serializer.fromJson<String>(json['articleId']),
      status: serializer.fromJson<String>(json['status']),
      trigger: serializer.fromJson<String>(json['trigger']),
      pickedNetizenIdsJson: serializer.fromJson<String>(
        json['pickedNetizenIdsJson'],
      ),
      attempt: serializer.fromJson<int>(json['attempt']),
      maxAttempts: serializer.fromJson<int>(json['maxAttempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      leaseOwner: serializer.fromJson<String?>(json['leaseOwner']),
      leaseUntil: serializer.fromJson<DateTime?>(json['leaseUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'articleId': serializer.toJson<String>(articleId),
      'status': serializer.toJson<String>(status),
      'trigger': serializer.toJson<String>(trigger),
      'pickedNetizenIdsJson': serializer.toJson<String>(pickedNetizenIdsJson),
      'attempt': serializer.toJson<int>(attempt),
      'maxAttempts': serializer.toJson<int>(maxAttempts),
      'lastError': serializer.toJson<String?>(lastError),
      'leaseOwner': serializer.toJson<String?>(leaseOwner),
      'leaseUntil': serializer.toJson<DateTime?>(leaseUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CommentJobRow copyWith({
    String? id,
    String? articleId,
    String? status,
    String? trigger,
    String? pickedNetizenIdsJson,
    int? attempt,
    int? maxAttempts,
    Value<String?> lastError = const Value.absent(),
    Value<String?> leaseOwner = const Value.absent(),
    Value<DateTime?> leaseUntil = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CommentJobRow(
    id: id ?? this.id,
    articleId: articleId ?? this.articleId,
    status: status ?? this.status,
    trigger: trigger ?? this.trigger,
    pickedNetizenIdsJson: pickedNetizenIdsJson ?? this.pickedNetizenIdsJson,
    attempt: attempt ?? this.attempt,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    leaseOwner: leaseOwner.present ? leaseOwner.value : this.leaseOwner,
    leaseUntil: leaseUntil.present ? leaseUntil.value : this.leaseUntil,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CommentJobRow copyWithCompanion(CommentJobsCompanion data) {
    return CommentJobRow(
      id: data.id.present ? data.id.value : this.id,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
      status: data.status.present ? data.status.value : this.status,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      pickedNetizenIdsJson: data.pickedNetizenIdsJson.present
          ? data.pickedNetizenIdsJson.value
          : this.pickedNetizenIdsJson,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      maxAttempts: data.maxAttempts.present
          ? data.maxAttempts.value
          : this.maxAttempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      leaseOwner: data.leaseOwner.present
          ? data.leaseOwner.value
          : this.leaseOwner,
      leaseUntil: data.leaseUntil.present
          ? data.leaseUntil.value
          : this.leaseUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentJobRow(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('status: $status, ')
          ..write('trigger: $trigger, ')
          ..write('pickedNetizenIdsJson: $pickedNetizenIdsJson, ')
          ..write('attempt: $attempt, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('lastError: $lastError, ')
          ..write('leaseOwner: $leaseOwner, ')
          ..write('leaseUntil: $leaseUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    articleId,
    status,
    trigger,
    pickedNetizenIdsJson,
    attempt,
    maxAttempts,
    lastError,
    leaseOwner,
    leaseUntil,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentJobRow &&
          other.id == this.id &&
          other.articleId == this.articleId &&
          other.status == this.status &&
          other.trigger == this.trigger &&
          other.pickedNetizenIdsJson == this.pickedNetizenIdsJson &&
          other.attempt == this.attempt &&
          other.maxAttempts == this.maxAttempts &&
          other.lastError == this.lastError &&
          other.leaseOwner == this.leaseOwner &&
          other.leaseUntil == this.leaseUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CommentJobsCompanion extends UpdateCompanion<CommentJobRow> {
  final Value<String> id;
  final Value<String> articleId;
  final Value<String> status;
  final Value<String> trigger;
  final Value<String> pickedNetizenIdsJson;
  final Value<int> attempt;
  final Value<int> maxAttempts;
  final Value<String?> lastError;
  final Value<String?> leaseOwner;
  final Value<DateTime?> leaseUntil;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CommentJobsCompanion({
    this.id = const Value.absent(),
    this.articleId = const Value.absent(),
    this.status = const Value.absent(),
    this.trigger = const Value.absent(),
    this.pickedNetizenIdsJson = const Value.absent(),
    this.attempt = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentJobsCompanion.insert({
    required String id,
    required String articleId,
    required String status,
    required String trigger,
    this.pickedNetizenIdsJson = const Value.absent(),
    this.attempt = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.leaseOwner = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       articleId = Value(articleId),
       status = Value(status),
       trigger = Value(trigger),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CommentJobRow> custom({
    Expression<String>? id,
    Expression<String>? articleId,
    Expression<String>? status,
    Expression<String>? trigger,
    Expression<String>? pickedNetizenIdsJson,
    Expression<int>? attempt,
    Expression<int>? maxAttempts,
    Expression<String>? lastError,
    Expression<String>? leaseOwner,
    Expression<DateTime>? leaseUntil,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (articleId != null) 'article_id': articleId,
      if (status != null) 'status': status,
      if (trigger != null) 'trigger': trigger,
      if (pickedNetizenIdsJson != null)
        'picked_netizen_ids_json': pickedNetizenIdsJson,
      if (attempt != null) 'attempt': attempt,
      if (maxAttempts != null) 'max_attempts': maxAttempts,
      if (lastError != null) 'last_error': lastError,
      if (leaseOwner != null) 'lease_owner': leaseOwner,
      if (leaseUntil != null) 'lease_until': leaseUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? articleId,
    Value<String>? status,
    Value<String>? trigger,
    Value<String>? pickedNetizenIdsJson,
    Value<int>? attempt,
    Value<int>? maxAttempts,
    Value<String?>? lastError,
    Value<String?>? leaseOwner,
    Value<DateTime?>? leaseUntil,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CommentJobsCompanion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      status: status ?? this.status,
      trigger: trigger ?? this.trigger,
      pickedNetizenIdsJson: pickedNetizenIdsJson ?? this.pickedNetizenIdsJson,
      attempt: attempt ?? this.attempt,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      lastError: lastError ?? this.lastError,
      leaseOwner: leaseOwner ?? this.leaseOwner,
      leaseUntil: leaseUntil ?? this.leaseUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (pickedNetizenIdsJson.present) {
      map['picked_netizen_ids_json'] = Variable<String>(
        pickedNetizenIdsJson.value,
      );
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (maxAttempts.present) {
      map['max_attempts'] = Variable<int>(maxAttempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (leaseOwner.present) {
      map['lease_owner'] = Variable<String>(leaseOwner.value);
    }
    if (leaseUntil.present) {
      map['lease_until'] = Variable<DateTime>(leaseUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentJobsCompanion(')
          ..write('id: $id, ')
          ..write('articleId: $articleId, ')
          ..write('status: $status, ')
          ..write('trigger: $trigger, ')
          ..write('pickedNetizenIdsJson: $pickedNetizenIdsJson, ')
          ..write('attempt: $attempt, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('lastError: $lastError, ')
          ..write('leaseOwner: $leaseOwner, ')
          ..write('leaseUntil: $leaseUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentJobItemsTable extends CommentJobItems
    with TableInfo<$CommentJobItemsTable, CommentJobItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentJobItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES comment_jobs (id)',
    ),
  );
  static const VerificationMeta _netizenIdMeta = const VerificationMeta(
    'netizenId',
  );
  @override
  late final GeneratedColumn<String> netizenId = GeneratedColumn<String>(
    'netizen_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentIdMeta = const VerificationMeta(
    'commentId',
  );
  @override
  late final GeneratedColumn<String> commentId = GeneratedColumn<String>(
    'comment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    netizenId,
    status,
    attempt,
    lastError,
    commentId,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comment_job_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentJobItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('netizen_id')) {
      context.handle(
        _netizenIdMeta,
        netizenId.isAcceptableOrUnknown(data['netizen_id']!, _netizenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_netizenIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('comment_id')) {
      context.handle(
        _commentIdMeta,
        commentId.isAcceptableOrUnknown(data['comment_id']!, _commentIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentJobItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentJobItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      netizenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}netizen_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      commentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CommentJobItemsTable createAlias(String alias) {
    return $CommentJobItemsTable(attachedDatabase, alias);
  }
}

class CommentJobItemRow extends DataClass
    implements Insertable<CommentJobItemRow> {
  final String id;
  final String jobId;
  final String netizenId;

  /// pending | running | succeeded | skipped | failed
  final String status;
  final int attempt;
  final String? lastError;
  final String? commentId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CommentJobItemRow({
    required this.id,
    required this.jobId,
    required this.netizenId,
    required this.status,
    required this.attempt,
    this.lastError,
    this.commentId,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_id'] = Variable<String>(jobId);
    map['netizen_id'] = Variable<String>(netizenId);
    map['status'] = Variable<String>(status);
    map['attempt'] = Variable<int>(attempt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || commentId != null) {
      map['comment_id'] = Variable<String>(commentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CommentJobItemsCompanion toCompanion(bool nullToAbsent) {
    return CommentJobItemsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      netizenId: Value(netizenId),
      status: Value(status),
      attempt: Value(attempt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      commentId: commentId == null && nullToAbsent
          ? const Value.absent()
          : Value(commentId),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CommentJobItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentJobItemRow(
      id: serializer.fromJson<String>(json['id']),
      jobId: serializer.fromJson<String>(json['jobId']),
      netizenId: serializer.fromJson<String>(json['netizenId']),
      status: serializer.fromJson<String>(json['status']),
      attempt: serializer.fromJson<int>(json['attempt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      commentId: serializer.fromJson<String?>(json['commentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobId': serializer.toJson<String>(jobId),
      'netizenId': serializer.toJson<String>(netizenId),
      'status': serializer.toJson<String>(status),
      'attempt': serializer.toJson<int>(attempt),
      'lastError': serializer.toJson<String?>(lastError),
      'commentId': serializer.toJson<String?>(commentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CommentJobItemRow copyWith({
    String? id,
    String? jobId,
    String? netizenId,
    String? status,
    int? attempt,
    Value<String?> lastError = const Value.absent(),
    Value<String?> commentId = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CommentJobItemRow(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    netizenId: netizenId ?? this.netizenId,
    status: status ?? this.status,
    attempt: attempt ?? this.attempt,
    lastError: lastError.present ? lastError.value : this.lastError,
    commentId: commentId.present ? commentId.value : this.commentId,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CommentJobItemRow copyWithCompanion(CommentJobItemsCompanion data) {
    return CommentJobItemRow(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      netizenId: data.netizenId.present ? data.netizenId.value : this.netizenId,
      status: data.status.present ? data.status.value : this.status,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      commentId: data.commentId.present ? data.commentId.value : this.commentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentJobItemRow(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('netizenId: $netizenId, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('lastError: $lastError, ')
          ..write('commentId: $commentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    netizenId,
    status,
    attempt,
    lastError,
    commentId,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentJobItemRow &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.netizenId == this.netizenId &&
          other.status == this.status &&
          other.attempt == this.attempt &&
          other.lastError == this.lastError &&
          other.commentId == this.commentId &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CommentJobItemsCompanion extends UpdateCompanion<CommentJobItemRow> {
  final Value<String> id;
  final Value<String> jobId;
  final Value<String> netizenId;
  final Value<String> status;
  final Value<int> attempt;
  final Value<String?> lastError;
  final Value<String?> commentId;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CommentJobItemsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.netizenId = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.commentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentJobItemsCompanion.insert({
    required String id,
    required String jobId,
    required String netizenId,
    required String status,
    this.attempt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.commentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobId = Value(jobId),
       netizenId = Value(netizenId),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CommentJobItemRow> custom({
    Expression<String>? id,
    Expression<String>? jobId,
    Expression<String>? netizenId,
    Expression<String>? status,
    Expression<int>? attempt,
    Expression<String>? lastError,
    Expression<String>? commentId,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (netizenId != null) 'netizen_id': netizenId,
      if (status != null) 'status': status,
      if (attempt != null) 'attempt': attempt,
      if (lastError != null) 'last_error': lastError,
      if (commentId != null) 'comment_id': commentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentJobItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? jobId,
    Value<String>? netizenId,
    Value<String>? status,
    Value<int>? attempt,
    Value<String?>? lastError,
    Value<String?>? commentId,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CommentJobItemsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      netizenId: netizenId ?? this.netizenId,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      lastError: lastError ?? this.lastError,
      commentId: commentId ?? this.commentId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (netizenId.present) {
      map['netizen_id'] = Variable<String>(netizenId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (commentId.present) {
      map['comment_id'] = Variable<String>(commentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentJobItemsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('netizenId: $netizenId, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('lastError: $lastError, ')
          ..write('commentId: $commentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FeedsTable feeds = $FeedsTable(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $ChatSessionsTable chatSessions = $ChatSessionsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $MediaChatMessagesTable mediaChatMessages =
      $MediaChatMessagesTable(this);
  late final $CompanionsTable companions = $CompanionsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $WarmEventsTable warmEvents = $WarmEventsTable(this);
  late final $AppSettingsRowsTable appSettingsRows = $AppSettingsRowsTable(
    this,
  );
  late final $LlmProvidersTable llmProviders = $LlmProvidersTable(this);
  late final $LlmModelsTable llmModels = $LlmModelsTable(this);
  late final $NetizensTable netizens = $NetizensTable(this);
  late final $CommentsTable comments = $CommentsTable(this);
  late final $CommentJobsTable commentJobs = $CommentJobsTable(this);
  late final $CommentJobItemsTable commentJobItems = $CommentJobItemsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    feeds,
    articles,
    chatSessions,
    chatMessages,
    mediaChatMessages,
    companions,
    userProfiles,
    warmEvents,
    appSettingsRows,
    llmProviders,
    llmModels,
    netizens,
    comments,
    commentJobs,
    commentJobItems,
  ];
}

typedef $$FeedsTableCreateCompanionBuilder =
    FeedsCompanion Function({
      required String id,
      required String title,
      required String url,
      Value<String?> siteUrl,
      Value<String?> iconUrl,
      Value<DateTime?> lastFetchedAt,
      Value<String?> etag,
      Value<String?> lastModified,
      Value<bool> isPaused,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FeedsTableUpdateCompanionBuilder =
    FeedsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> url,
      Value<String?> siteUrl,
      Value<String?> iconUrl,
      Value<DateTime?> lastFetchedAt,
      Value<String?> etag,
      Value<String?> lastModified,
      Value<bool> isPaused,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$FeedsTableReferences
    extends BaseReferences<_$AppDatabase, $FeedsTable, FeedRow> {
  $$FeedsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArticlesTable, List<ArticleRow>>
  _articlesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articles,
    aliasName: 'feeds__id__articles__feed_id',
  );

  $$ArticlesTableProcessedTableManager get articlesRefs {
    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.feedId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_articlesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FeedsTableFilterComposer extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> articlesRefs(
    Expression<bool> Function($$ArticlesTableFilterComposer f) f,
  ) {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get siteUrl =>
      $composableBuilder(column: $table.siteUrl, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> articlesRefs<T extends Object>(
    Expression<T> Function($$ArticlesTableAnnotationComposer a) f,
  ) {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedsTable,
          FeedRow,
          $$FeedsTableFilterComposer,
          $$FeedsTableOrderingComposer,
          $$FeedsTableAnnotationComposer,
          $$FeedsTableCreateCompanionBuilder,
          $$FeedsTableUpdateCompanionBuilder,
          (FeedRow, $$FeedsTableReferences),
          FeedRow,
          PrefetchHooks Function({bool articlesRefs})
        > {
  $$FeedsTableTableManager(_$AppDatabase db, $FeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> siteUrl = const Value.absent(),
                Value<String?> iconUrl = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion(
                id: id,
                title: title,
                url: url,
                siteUrl: siteUrl,
                iconUrl: iconUrl,
                lastFetchedAt: lastFetchedAt,
                etag: etag,
                lastModified: lastModified,
                isPaused: isPaused,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String url,
                Value<String?> siteUrl = const Value.absent(),
                Value<String?> iconUrl = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion.insert(
                id: id,
                title: title,
                url: url,
                siteUrl: siteUrl,
                iconUrl: iconUrl,
                lastFetchedAt: lastFetchedAt,
                etag: etag,
                lastModified: lastModified,
                isPaused: isPaused,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FeedsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({articlesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (articlesRefs) db.articles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (articlesRefs)
                    await $_getPrefetchedData<FeedRow, $FeedsTable, ArticleRow>(
                      currentTable: table,
                      referencedTable: $$FeedsTableReferences
                          ._articlesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FeedsTableReferences(db, table, p0).articlesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.feedId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedsTable,
      FeedRow,
      $$FeedsTableFilterComposer,
      $$FeedsTableOrderingComposer,
      $$FeedsTableAnnotationComposer,
      $$FeedsTableCreateCompanionBuilder,
      $$FeedsTableUpdateCompanionBuilder,
      (FeedRow, $$FeedsTableReferences),
      FeedRow,
      PrefetchHooks Function({bool articlesRefs})
    >;
typedef $$ArticlesTableCreateCompanionBuilder =
    ArticlesCompanion Function({
      required String id,
      required String feedId,
      required String guid,
      Value<String?> link,
      required String title,
      Value<String?> author,
      Value<String> summary,
      Value<String?> contentHtml,
      Value<String> contentText,
      Value<String?> imageUrl,
      Value<String> mediaType,
      Value<String?> enclosureUrl,
      Value<String?> enclosureMime,
      Value<int?> enclosureLength,
      Value<int?> durationSeconds,
      Value<double> imageAspect,
      Value<bool> featured,
      Value<String> tagsJson,
      required DateTime publishedAt,
      required DateTime fetchedAt,
      Value<bool> isRead,
      Value<bool> isBookmarked,
      Value<DateTime?> readAt,
      Value<DateTime?> bookmarkedAt,
      Value<int> rowid,
    });
typedef $$ArticlesTableUpdateCompanionBuilder =
    ArticlesCompanion Function({
      Value<String> id,
      Value<String> feedId,
      Value<String> guid,
      Value<String?> link,
      Value<String> title,
      Value<String?> author,
      Value<String> summary,
      Value<String?> contentHtml,
      Value<String> contentText,
      Value<String?> imageUrl,
      Value<String> mediaType,
      Value<String?> enclosureUrl,
      Value<String?> enclosureMime,
      Value<int?> enclosureLength,
      Value<int?> durationSeconds,
      Value<double> imageAspect,
      Value<bool> featured,
      Value<String> tagsJson,
      Value<DateTime> publishedAt,
      Value<DateTime> fetchedAt,
      Value<bool> isRead,
      Value<bool> isBookmarked,
      Value<DateTime?> readAt,
      Value<DateTime?> bookmarkedAt,
      Value<int> rowid,
    });

final class $$ArticlesTableReferences
    extends BaseReferences<_$AppDatabase, $ArticlesTable, ArticleRow> {
  $$ArticlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FeedsTable _feedIdTable(_$AppDatabase db) =>
      db.feeds.createAlias('articles__feed_id__feeds__id');

  $$FeedsTableProcessedTableManager get feedId {
    final $_column = $_itemColumn<String>('feed_id')!;

    final manager = $$FeedsTableTableManager(
      $_db,
      $_db.feeds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feedIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enclosureUrl => $composableBuilder(
    column: $table.enclosureUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enclosureMime => $composableBuilder(
    column: $table.enclosureMime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enclosureLength => $composableBuilder(
    column: $table.enclosureLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get imageAspect => $composableBuilder(
    column: $table.imageAspect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get featured => $composableBuilder(
    column: $table.featured,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FeedsTableFilterComposer get feedId {
    final $$FeedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableFilterComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enclosureUrl => $composableBuilder(
    column: $table.enclosureUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enclosureMime => $composableBuilder(
    column: $table.enclosureMime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enclosureLength => $composableBuilder(
    column: $table.enclosureLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get imageAspect => $composableBuilder(
    column: $table.imageAspect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get featured => $composableBuilder(
    column: $table.featured,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FeedsTableOrderingComposer get feedId {
    final $$FeedsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableOrderingComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get enclosureUrl => $composableBuilder(
    column: $table.enclosureUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enclosureMime => $composableBuilder(
    column: $table.enclosureMime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enclosureLength => $composableBuilder(
    column: $table.enclosureLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get imageAspect => $composableBuilder(
    column: $table.imageAspect,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get featured =>
      $composableBuilder(column: $table.featured, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => column,
  );

  $$FeedsTableAnnotationComposer get feedId {
    final $$FeedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableAnnotationComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          ArticleRow,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (ArticleRow, $$ArticlesTableReferences),
          ArticleRow,
          PrefetchHooks Function({bool feedId})
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> feedId = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> contentHtml = const Value.absent(),
                Value<String> contentText = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String?> enclosureUrl = const Value.absent(),
                Value<String?> enclosureMime = const Value.absent(),
                Value<int?> enclosureLength = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double> imageAspect = const Value.absent(),
                Value<bool> featured = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> bookmarkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                feedId: feedId,
                guid: guid,
                link: link,
                title: title,
                author: author,
                summary: summary,
                contentHtml: contentHtml,
                contentText: contentText,
                imageUrl: imageUrl,
                mediaType: mediaType,
                enclosureUrl: enclosureUrl,
                enclosureMime: enclosureMime,
                enclosureLength: enclosureLength,
                durationSeconds: durationSeconds,
                imageAspect: imageAspect,
                featured: featured,
                tagsJson: tagsJson,
                publishedAt: publishedAt,
                fetchedAt: fetchedAt,
                isRead: isRead,
                isBookmarked: isBookmarked,
                readAt: readAt,
                bookmarkedAt: bookmarkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String feedId,
                required String guid,
                Value<String?> link = const Value.absent(),
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> contentHtml = const Value.absent(),
                Value<String> contentText = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String?> enclosureUrl = const Value.absent(),
                Value<String?> enclosureMime = const Value.absent(),
                Value<int?> enclosureLength = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double> imageAspect = const Value.absent(),
                Value<bool> featured = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                required DateTime publishedAt,
                required DateTime fetchedAt,
                Value<bool> isRead = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> bookmarkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                feedId: feedId,
                guid: guid,
                link: link,
                title: title,
                author: author,
                summary: summary,
                contentHtml: contentHtml,
                contentText: contentText,
                imageUrl: imageUrl,
                mediaType: mediaType,
                enclosureUrl: enclosureUrl,
                enclosureMime: enclosureMime,
                enclosureLength: enclosureLength,
                durationSeconds: durationSeconds,
                imageAspect: imageAspect,
                featured: featured,
                tagsJson: tagsJson,
                publishedAt: publishedAt,
                fetchedAt: fetchedAt,
                isRead: isRead,
                isBookmarked: isBookmarked,
                readAt: readAt,
                bookmarkedAt: bookmarkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArticlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({feedId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (feedId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.feedId,
                                referencedTable: $$ArticlesTableReferences
                                    ._feedIdTable(db),
                                referencedColumn: $$ArticlesTableReferences
                                    ._feedIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      ArticleRow,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (ArticleRow, $$ArticlesTableReferences),
      ArticleRow,
      PrefetchHooks Function({bool feedId})
    >;
typedef $$ChatSessionsTableCreateCompanionBuilder =
    ChatSessionsCompanion Function({
      required String id,
      required String articleId,
      Value<String?> companionSnapshotJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChatSessionsTableUpdateCompanionBuilder =
    ChatSessionsCompanion Function({
      Value<String> id,
      Value<String> articleId,
      Value<String?> companionSnapshotJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ChatSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatSessionsTable, ChatSession> {
  $$ChatSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: 'chat_sessions__id__chat_messages__session_id',
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companionSnapshotJson => $composableBuilder(
    column: $table.companionSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companionSnapshotJson => $composableBuilder(
    column: $table.companionSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatSessionsTable> {
  $$ChatSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get companionSnapshotJson => $composableBuilder(
    column: $table.companionSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatSessionsTable,
          ChatSession,
          $$ChatSessionsTableFilterComposer,
          $$ChatSessionsTableOrderingComposer,
          $$ChatSessionsTableAnnotationComposer,
          $$ChatSessionsTableCreateCompanionBuilder,
          $$ChatSessionsTableUpdateCompanionBuilder,
          (ChatSession, $$ChatSessionsTableReferences),
          ChatSession,
          PrefetchHooks Function({bool chatMessagesRefs})
        > {
  $$ChatSessionsTableTableManager(_$AppDatabase db, $ChatSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String?> companionSnapshotJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatSessionsCompanion(
                id: id,
                articleId: articleId,
                companionSnapshotJson: companionSnapshotJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String articleId,
                Value<String?> companionSnapshotJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatSessionsCompanion.insert(
                id: id,
                articleId: articleId,
                companionSnapshotJson: companionSnapshotJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatMessagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chatMessagesRefs) db.chatMessages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatMessagesRefs)
                    await $_getPrefetchedData<
                      ChatSession,
                      $ChatSessionsTable,
                      ChatMessage
                    >(
                      currentTable: table,
                      referencedTable: $$ChatSessionsTableReferences
                          ._chatMessagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ChatSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).chatMessagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ChatSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatSessionsTable,
      ChatSession,
      $$ChatSessionsTableFilterComposer,
      $$ChatSessionsTableOrderingComposer,
      $$ChatSessionsTableAnnotationComposer,
      $$ChatSessionsTableCreateCompanionBuilder,
      $$ChatSessionsTableUpdateCompanionBuilder,
      (ChatSession, $$ChatSessionsTableReferences),
      ChatSession,
      PrefetchHooks Function({bool chatMessagesRefs})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String sessionId,
      required String role,
      required String content,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatSessionsTable _sessionIdTable(_$AppDatabase db) => db.chatSessions
      .createAlias('chat_messages__session_id__chat_sessions__id');

  $$ChatSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$ChatSessionsTableTableManager(
      $_db,
      $_db.chatSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatSessionsTableFilterComposer get sessionId {
    final $$ChatSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableFilterComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatSessionsTableOrderingComposer get sessionId {
    final $$ChatSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChatSessionsTableAnnotationComposer get sessionId {
    final $$ChatSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.chatSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String role,
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$MediaChatMessagesTableCreateCompanionBuilder =
    MediaChatMessagesCompanion Function({
      required String id,
      required String articleId,
      required String role,
      Value<String> content,
      Value<String> status,
      Value<String?> error,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MediaChatMessagesTableUpdateCompanionBuilder =
    MediaChatMessagesCompanion Function({
      Value<String> id,
      Value<String> articleId,
      Value<String> role,
      Value<String> content,
      Value<String> status,
      Value<String?> error,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MediaChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaChatMessagesTable> {
  $$MediaChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaChatMessagesTable> {
  $$MediaChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaChatMessagesTable> {
  $$MediaChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MediaChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaChatMessagesTable,
          MediaChatMessageRow,
          $$MediaChatMessagesTableFilterComposer,
          $$MediaChatMessagesTableOrderingComposer,
          $$MediaChatMessagesTableAnnotationComposer,
          $$MediaChatMessagesTableCreateCompanionBuilder,
          $$MediaChatMessagesTableUpdateCompanionBuilder,
          (
            MediaChatMessageRow,
            BaseReferences<
              _$AppDatabase,
              $MediaChatMessagesTable,
              MediaChatMessageRow
            >,
          ),
          MediaChatMessageRow,
          PrefetchHooks Function()
        > {
  $$MediaChatMessagesTableTableManager(
    _$AppDatabase db,
    $MediaChatMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaChatMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaChatMessagesCompanion(
                id: id,
                articleId: articleId,
                role: role,
                content: content,
                status: status,
                error: error,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String articleId,
                required String role,
                Value<String> content = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaChatMessagesCompanion.insert(
                id: id,
                articleId: articleId,
                role: role,
                content: content,
                status: status,
                error: error,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaChatMessagesTable,
      MediaChatMessageRow,
      $$MediaChatMessagesTableFilterComposer,
      $$MediaChatMessagesTableOrderingComposer,
      $$MediaChatMessagesTableAnnotationComposer,
      $$MediaChatMessagesTableCreateCompanionBuilder,
      $$MediaChatMessagesTableUpdateCompanionBuilder,
      (
        MediaChatMessageRow,
        BaseReferences<
          _$AppDatabase,
          $MediaChatMessagesTable,
          MediaChatMessageRow
        >,
      ),
      MediaChatMessageRow,
      PrefetchHooks Function()
    >;
typedef $$CompanionsTableCreateCompanionBuilder =
    CompanionsCompanion Function({
      required String id,
      required String name,
      required String styleLabel,
      required String systemHint,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CompanionsTableUpdateCompanionBuilder =
    CompanionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> styleLabel,
      Value<String> systemHint,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CompanionsTableFilterComposer
    extends Composer<_$AppDatabase, $CompanionsTable> {
  $$CompanionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemHint => $composableBuilder(
    column: $table.systemHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompanionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanionsTable> {
  $$CompanionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemHint => $composableBuilder(
    column: $table.systemHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompanionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanionsTable> {
  $$CompanionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemHint => $composableBuilder(
    column: $table.systemHint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CompanionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanionsTable,
          CompanionRow,
          $$CompanionsTableFilterComposer,
          $$CompanionsTableOrderingComposer,
          $$CompanionsTableAnnotationComposer,
          $$CompanionsTableCreateCompanionBuilder,
          $$CompanionsTableUpdateCompanionBuilder,
          (
            CompanionRow,
            BaseReferences<_$AppDatabase, $CompanionsTable, CompanionRow>,
          ),
          CompanionRow,
          PrefetchHooks Function()
        > {
  $$CompanionsTableTableManager(_$AppDatabase db, $CompanionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> styleLabel = const Value.absent(),
                Value<String> systemHint = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanionsCompanion(
                id: id,
                name: name,
                styleLabel: styleLabel,
                systemHint: systemHint,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String styleLabel,
                required String systemHint,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CompanionsCompanion.insert(
                id: id,
                name: name,
                styleLabel: styleLabel,
                systemHint: systemHint,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompanionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanionsTable,
      CompanionRow,
      $$CompanionsTableFilterComposer,
      $$CompanionsTableOrderingComposer,
      $$CompanionsTableAnnotationComposer,
      $$CompanionsTableCreateCompanionBuilder,
      $$CompanionsTableUpdateCompanionBuilder,
      (
        CompanionRow,
        BaseReferences<_$AppDatabase, $CompanionsTable, CompanionRow>,
      ),
      CompanionRow,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String displayName,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                displayName: displayName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$WarmEventsTableCreateCompanionBuilder =
    WarmEventsCompanion Function({
      required String id,
      required String type,
      required String title,
      required String subtitle,
      Value<String?> articleId,
      Value<String?> payloadJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WarmEventsTableUpdateCompanionBuilder =
    WarmEventsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> title,
      Value<String> subtitle,
      Value<String?> articleId,
      Value<String?> payloadJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WarmEventsTableFilterComposer
    extends Composer<_$AppDatabase, $WarmEventsTable> {
  $$WarmEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WarmEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $WarmEventsTable> {
  $$WarmEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WarmEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarmEventsTable> {
  $$WarmEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WarmEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WarmEventsTable,
          WarmEvent,
          $$WarmEventsTableFilterComposer,
          $$WarmEventsTableOrderingComposer,
          $$WarmEventsTableAnnotationComposer,
          $$WarmEventsTableCreateCompanionBuilder,
          $$WarmEventsTableUpdateCompanionBuilder,
          (
            WarmEvent,
            BaseReferences<_$AppDatabase, $WarmEventsTable, WarmEvent>,
          ),
          WarmEvent,
          PrefetchHooks Function()
        > {
  $$WarmEventsTableTableManager(_$AppDatabase db, $WarmEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarmEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarmEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarmEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String?> articleId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WarmEventsCompanion(
                id: id,
                type: type,
                title: title,
                subtitle: subtitle,
                articleId: articleId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String title,
                required String subtitle,
                Value<String?> articleId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WarmEventsCompanion.insert(
                id: id,
                type: type,
                title: title,
                subtitle: subtitle,
                articleId: articleId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WarmEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WarmEventsTable,
      WarmEvent,
      $$WarmEventsTableFilterComposer,
      $$WarmEventsTableOrderingComposer,
      $$WarmEventsTableAnnotationComposer,
      $$WarmEventsTableCreateCompanionBuilder,
      $$WarmEventsTableUpdateCompanionBuilder,
      (WarmEvent, BaseReferences<_$AppDatabase, $WarmEventsTable, WarmEvent>),
      WarmEvent,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsRowsTableCreateCompanionBuilder =
    AppSettingsRowsCompanion Function({
      required String id,
      Value<String> themeMode,
      Value<double> fontScale,
      Value<int> refreshMinutes,
      Value<bool> wifiOnly,
      Value<bool> notificationsEnabled,
      Value<String> llmBaseUrl,
      Value<String> llmModel,
      Value<bool> useMockFeed,
      Value<String> commentTrigger,
      Value<String> feedFilterJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsRowsTableUpdateCompanionBuilder =
    AppSettingsRowsCompanion Function({
      Value<String> id,
      Value<String> themeMode,
      Value<double> fontScale,
      Value<int> refreshMinutes,
      Value<bool> wifiOnly,
      Value<bool> notificationsEnabled,
      Value<String> llmBaseUrl,
      Value<String> llmModel,
      Value<bool> useMockFeed,
      Value<String> commentTrigger,
      Value<String> feedFilterJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fontScale => $composableBuilder(
    column: $table.fontScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refreshMinutes => $composableBuilder(
    column: $table.refreshMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmBaseUrl => $composableBuilder(
    column: $table.llmBaseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmModel => $composableBuilder(
    column: $table.llmModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useMockFeed => $composableBuilder(
    column: $table.useMockFeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentTrigger => $composableBuilder(
    column: $table.commentTrigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedFilterJson => $composableBuilder(
    column: $table.feedFilterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fontScale => $composableBuilder(
    column: $table.fontScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refreshMinutes => $composableBuilder(
    column: $table.refreshMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmBaseUrl => $composableBuilder(
    column: $table.llmBaseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmModel => $composableBuilder(
    column: $table.llmModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useMockFeed => $composableBuilder(
    column: $table.useMockFeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentTrigger => $composableBuilder(
    column: $table.commentTrigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedFilterJson => $composableBuilder(
    column: $table.feedFilterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<double> get fontScale =>
      $composableBuilder(column: $table.fontScale, builder: (column) => column);

  GeneratedColumn<int> get refreshMinutes => $composableBuilder(
    column: $table.refreshMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wifiOnly =>
      $composableBuilder(column: $table.wifiOnly, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmBaseUrl => $composableBuilder(
    column: $table.llmBaseUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmModel =>
      $composableBuilder(column: $table.llmModel, builder: (column) => column);

  GeneratedColumn<bool> get useMockFeed => $composableBuilder(
    column: $table.useMockFeed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commentTrigger => $composableBuilder(
    column: $table.commentTrigger,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedFilterJson => $composableBuilder(
    column: $table.feedFilterJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsRowsTable,
          AppSettingsRow,
          $$AppSettingsRowsTableFilterComposer,
          $$AppSettingsRowsTableOrderingComposer,
          $$AppSettingsRowsTableAnnotationComposer,
          $$AppSettingsRowsTableCreateCompanionBuilder,
          $$AppSettingsRowsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsRowsTable,
              AppSettingsRow
            >,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsRowsTableTableManager(
    _$AppDatabase db,
    $AppSettingsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<double> fontScale = const Value.absent(),
                Value<int> refreshMinutes = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String> llmBaseUrl = const Value.absent(),
                Value<String> llmModel = const Value.absent(),
                Value<bool> useMockFeed = const Value.absent(),
                Value<String> commentTrigger = const Value.absent(),
                Value<String> feedFilterJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsRowsCompanion(
                id: id,
                themeMode: themeMode,
                fontScale: fontScale,
                refreshMinutes: refreshMinutes,
                wifiOnly: wifiOnly,
                notificationsEnabled: notificationsEnabled,
                llmBaseUrl: llmBaseUrl,
                llmModel: llmModel,
                useMockFeed: useMockFeed,
                commentTrigger: commentTrigger,
                feedFilterJson: feedFilterJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> themeMode = const Value.absent(),
                Value<double> fontScale = const Value.absent(),
                Value<int> refreshMinutes = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String> llmBaseUrl = const Value.absent(),
                Value<String> llmModel = const Value.absent(),
                Value<bool> useMockFeed = const Value.absent(),
                Value<String> commentTrigger = const Value.absent(),
                Value<String> feedFilterJson = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsRowsCompanion.insert(
                id: id,
                themeMode: themeMode,
                fontScale: fontScale,
                refreshMinutes: refreshMinutes,
                wifiOnly: wifiOnly,
                notificationsEnabled: notificationsEnabled,
                llmBaseUrl: llmBaseUrl,
                llmModel: llmModel,
                useMockFeed: useMockFeed,
                commentTrigger: commentTrigger,
                feedFilterJson: feedFilterJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsRowsTable,
      AppSettingsRow,
      $$AppSettingsRowsTableFilterComposer,
      $$AppSettingsRowsTableOrderingComposer,
      $$AppSettingsRowsTableAnnotationComposer,
      $$AppSettingsRowsTableCreateCompanionBuilder,
      $$AppSettingsRowsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsRowsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$LlmProvidersTableCreateCompanionBuilder =
    LlmProvidersCompanion Function({
      required String id,
      required String name,
      required String protocol,
      required String baseUrl,
      Value<bool> isEnabled,
      Value<int> maxConcurrent,
      Value<int> requestsPerMinute,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LlmProvidersTableUpdateCompanionBuilder =
    LlmProvidersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> protocol,
      Value<String> baseUrl,
      Value<bool> isEnabled,
      Value<int> maxConcurrent,
      Value<int> requestsPerMinute,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LlmProvidersTableReferences
    extends BaseReferences<_$AppDatabase, $LlmProvidersTable, LlmProviderRow> {
  $$LlmProvidersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LlmModelsTable, List<LlmModelRow>>
  _llmModelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.llmModels,
    aliasName: 'llm_providers__id__llm_models__provider_id',
  );

  $$LlmModelsTableProcessedTableManager get llmModelsRefs {
    final manager = $$LlmModelsTableTableManager(
      $_db,
      $_db.llmModels,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_llmModelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LlmProvidersTableFilterComposer
    extends Composer<_$AppDatabase, $LlmProvidersTable> {
  $$LlmProvidersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxConcurrent => $composableBuilder(
    column: $table.maxConcurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestsPerMinute => $composableBuilder(
    column: $table.requestsPerMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> llmModelsRefs(
    Expression<bool> Function($$LlmModelsTableFilterComposer f) f,
  ) {
    final $$LlmModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmModels,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmModelsTableFilterComposer(
            $db: $db,
            $table: $db.llmModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LlmProvidersTableOrderingComposer
    extends Composer<_$AppDatabase, $LlmProvidersTable> {
  $$LlmProvidersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get protocol => $composableBuilder(
    column: $table.protocol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxConcurrent => $composableBuilder(
    column: $table.maxConcurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestsPerMinute => $composableBuilder(
    column: $table.requestsPerMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LlmProvidersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LlmProvidersTable> {
  $$LlmProvidersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get maxConcurrent => $composableBuilder(
    column: $table.maxConcurrent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestsPerMinute => $composableBuilder(
    column: $table.requestsPerMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> llmModelsRefs<T extends Object>(
    Expression<T> Function($$LlmModelsTableAnnotationComposer a) f,
  ) {
    final $$LlmModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.llmModels,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.llmModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LlmProvidersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LlmProvidersTable,
          LlmProviderRow,
          $$LlmProvidersTableFilterComposer,
          $$LlmProvidersTableOrderingComposer,
          $$LlmProvidersTableAnnotationComposer,
          $$LlmProvidersTableCreateCompanionBuilder,
          $$LlmProvidersTableUpdateCompanionBuilder,
          (LlmProviderRow, $$LlmProvidersTableReferences),
          LlmProviderRow,
          PrefetchHooks Function({bool llmModelsRefs})
        > {
  $$LlmProvidersTableTableManager(_$AppDatabase db, $LlmProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LlmProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LlmProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LlmProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> protocol = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> maxConcurrent = const Value.absent(),
                Value<int> requestsPerMinute = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LlmProvidersCompanion(
                id: id,
                name: name,
                protocol: protocol,
                baseUrl: baseUrl,
                isEnabled: isEnabled,
                maxConcurrent: maxConcurrent,
                requestsPerMinute: requestsPerMinute,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String protocol,
                required String baseUrl,
                Value<bool> isEnabled = const Value.absent(),
                Value<int> maxConcurrent = const Value.absent(),
                Value<int> requestsPerMinute = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LlmProvidersCompanion.insert(
                id: id,
                name: name,
                protocol: protocol,
                baseUrl: baseUrl,
                isEnabled: isEnabled,
                maxConcurrent: maxConcurrent,
                requestsPerMinute: requestsPerMinute,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LlmProvidersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({llmModelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (llmModelsRefs) db.llmModels],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (llmModelsRefs)
                    await $_getPrefetchedData<
                      LlmProviderRow,
                      $LlmProvidersTable,
                      LlmModelRow
                    >(
                      currentTable: table,
                      referencedTable: $$LlmProvidersTableReferences
                          ._llmModelsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LlmProvidersTableReferences(
                            db,
                            table,
                            p0,
                          ).llmModelsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.providerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LlmProvidersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LlmProvidersTable,
      LlmProviderRow,
      $$LlmProvidersTableFilterComposer,
      $$LlmProvidersTableOrderingComposer,
      $$LlmProvidersTableAnnotationComposer,
      $$LlmProvidersTableCreateCompanionBuilder,
      $$LlmProvidersTableUpdateCompanionBuilder,
      (LlmProviderRow, $$LlmProvidersTableReferences),
      LlmProviderRow,
      PrefetchHooks Function({bool llmModelsRefs})
    >;
typedef $$LlmModelsTableCreateCompanionBuilder =
    LlmModelsCompanion Function({
      required String id,
      required String providerId,
      required String modelId,
      required String displayName,
      Value<bool> isDefault,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$LlmModelsTableUpdateCompanionBuilder =
    LlmModelsCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> modelId,
      Value<String> displayName,
      Value<bool> isDefault,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$LlmModelsTableReferences
    extends BaseReferences<_$AppDatabase, $LlmModelsTable, LlmModelRow> {
  $$LlmModelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LlmProvidersTable _providerIdTable(_$AppDatabase db) =>
      db.llmProviders.createAlias('llm_models__provider_id__llm_providers__id');

  $$LlmProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$LlmProvidersTableTableManager(
      $_db,
      $_db.llmProviders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LlmModelsTableFilterComposer
    extends Composer<_$AppDatabase, $LlmModelsTable> {
  $$LlmModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$LlmProvidersTableFilterComposer get providerId {
    final $$LlmProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.llmProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmProvidersTableFilterComposer(
            $db: $db,
            $table: $db.llmProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LlmModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LlmModelsTable> {
  $$LlmModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$LlmProvidersTableOrderingComposer get providerId {
    final $$LlmProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.llmProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.llmProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LlmModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LlmModelsTable> {
  $$LlmModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$LlmProvidersTableAnnotationComposer get providerId {
    final $$LlmProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.llmProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LlmProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.llmProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LlmModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LlmModelsTable,
          LlmModelRow,
          $$LlmModelsTableFilterComposer,
          $$LlmModelsTableOrderingComposer,
          $$LlmModelsTableAnnotationComposer,
          $$LlmModelsTableCreateCompanionBuilder,
          $$LlmModelsTableUpdateCompanionBuilder,
          (LlmModelRow, $$LlmModelsTableReferences),
          LlmModelRow,
          PrefetchHooks Function({bool providerId})
        > {
  $$LlmModelsTableTableManager(_$AppDatabase db, $LlmModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LlmModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LlmModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LlmModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LlmModelsCompanion(
                id: id,
                providerId: providerId,
                modelId: modelId,
                displayName: displayName,
                isDefault: isDefault,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String modelId,
                required String displayName,
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LlmModelsCompanion.insert(
                id: id,
                providerId: providerId,
                modelId: modelId,
                displayName: displayName,
                isDefault: isDefault,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LlmModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({providerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (providerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.providerId,
                                referencedTable: $$LlmModelsTableReferences
                                    ._providerIdTable(db),
                                referencedColumn: $$LlmModelsTableReferences
                                    ._providerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LlmModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LlmModelsTable,
      LlmModelRow,
      $$LlmModelsTableFilterComposer,
      $$LlmModelsTableOrderingComposer,
      $$LlmModelsTableAnnotationComposer,
      $$LlmModelsTableCreateCompanionBuilder,
      $$LlmModelsTableUpdateCompanionBuilder,
      (LlmModelRow, $$LlmModelsTableReferences),
      LlmModelRow,
      PrefetchHooks Function({bool providerId})
    >;
typedef $$NetizensTableCreateCompanionBuilder =
    NetizensCompanion Function({
      required String id,
      required String name,
      Value<String?> styleLabel,
      required String systemHint,
      Value<String?> avatarPath,
      Value<double> weight,
      Value<String?> providerId,
      Value<String?> modelId,
      Value<bool> isEnabled,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$NetizensTableUpdateCompanionBuilder =
    NetizensCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> styleLabel,
      Value<String> systemHint,
      Value<String?> avatarPath,
      Value<double> weight,
      Value<String?> providerId,
      Value<String?> modelId,
      Value<bool> isEnabled,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$NetizensTableFilterComposer
    extends Composer<_$AppDatabase, $NetizensTable> {
  $$NetizensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemHint => $composableBuilder(
    column: $table.systemHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NetizensTableOrderingComposer
    extends Composer<_$AppDatabase, $NetizensTable> {
  $$NetizensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemHint => $composableBuilder(
    column: $table.systemHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NetizensTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetizensTable> {
  $$NetizensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemHint => $composableBuilder(
    column: $table.systemHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NetizensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NetizensTable,
          NetizenRow,
          $$NetizensTableFilterComposer,
          $$NetizensTableOrderingComposer,
          $$NetizensTableAnnotationComposer,
          $$NetizensTableCreateCompanionBuilder,
          $$NetizensTableUpdateCompanionBuilder,
          (
            NetizenRow,
            BaseReferences<_$AppDatabase, $NetizensTable, NetizenRow>,
          ),
          NetizenRow,
          PrefetchHooks Function()
        > {
  $$NetizensTableTableManager(_$AppDatabase db, $NetizensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetizensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetizensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetizensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> styleLabel = const Value.absent(),
                Value<String> systemHint = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NetizensCompanion(
                id: id,
                name: name,
                styleLabel: styleLabel,
                systemHint: systemHint,
                avatarPath: avatarPath,
                weight: weight,
                providerId: providerId,
                modelId: modelId,
                isEnabled: isEnabled,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> styleLabel = const Value.absent(),
                required String systemHint,
                Value<String?> avatarPath = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NetizensCompanion.insert(
                id: id,
                name: name,
                styleLabel: styleLabel,
                systemHint: systemHint,
                avatarPath: avatarPath,
                weight: weight,
                providerId: providerId,
                modelId: modelId,
                isEnabled: isEnabled,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NetizensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NetizensTable,
      NetizenRow,
      $$NetizensTableFilterComposer,
      $$NetizensTableOrderingComposer,
      $$NetizensTableAnnotationComposer,
      $$NetizensTableCreateCompanionBuilder,
      $$NetizensTableUpdateCompanionBuilder,
      (NetizenRow, BaseReferences<_$AppDatabase, $NetizensTable, NetizenRow>),
      NetizenRow,
      PrefetchHooks Function()
    >;
typedef $$CommentsTableCreateCompanionBuilder =
    CommentsCompanion Function({
      required String id,
      required String articleId,
      required String authorType,
      Value<String?> netizenId,
      Value<String?> parentId,
      required String content,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CommentsTableUpdateCompanionBuilder =
    CommentsCompanion Function({
      Value<String> id,
      Value<String> articleId,
      Value<String> authorType,
      Value<String?> netizenId,
      Value<String?> parentId,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CommentsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorType => $composableBuilder(
    column: $table.authorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get netizenId => $composableBuilder(
    column: $table.netizenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorType => $composableBuilder(
    column: $table.authorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get netizenId => $composableBuilder(
    column: $table.netizenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get authorType => $composableBuilder(
    column: $table.authorType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get netizenId =>
      $composableBuilder(column: $table.netizenId, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommentsTable,
          CommentRow,
          $$CommentsTableFilterComposer,
          $$CommentsTableOrderingComposer,
          $$CommentsTableAnnotationComposer,
          $$CommentsTableCreateCompanionBuilder,
          $$CommentsTableUpdateCompanionBuilder,
          (
            CommentRow,
            BaseReferences<_$AppDatabase, $CommentsTable, CommentRow>,
          ),
          CommentRow,
          PrefetchHooks Function()
        > {
  $$CommentsTableTableManager(_$AppDatabase db, $CommentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> authorType = const Value.absent(),
                Value<String?> netizenId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentsCompanion(
                id: id,
                articleId: articleId,
                authorType: authorType,
                netizenId: netizenId,
                parentId: parentId,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String articleId,
                required String authorType,
                Value<String?> netizenId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CommentsCompanion.insert(
                id: id,
                articleId: articleId,
                authorType: authorType,
                netizenId: netizenId,
                parentId: parentId,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommentsTable,
      CommentRow,
      $$CommentsTableFilterComposer,
      $$CommentsTableOrderingComposer,
      $$CommentsTableAnnotationComposer,
      $$CommentsTableCreateCompanionBuilder,
      $$CommentsTableUpdateCompanionBuilder,
      (CommentRow, BaseReferences<_$AppDatabase, $CommentsTable, CommentRow>),
      CommentRow,
      PrefetchHooks Function()
    >;
typedef $$CommentJobsTableCreateCompanionBuilder =
    CommentJobsCompanion Function({
      required String id,
      required String articleId,
      required String status,
      required String trigger,
      Value<String> pickedNetizenIdsJson,
      Value<int> attempt,
      Value<int> maxAttempts,
      Value<String?> lastError,
      Value<String?> leaseOwner,
      Value<DateTime?> leaseUntil,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CommentJobsTableUpdateCompanionBuilder =
    CommentJobsCompanion Function({
      Value<String> id,
      Value<String> articleId,
      Value<String> status,
      Value<String> trigger,
      Value<String> pickedNetizenIdsJson,
      Value<int> attempt,
      Value<int> maxAttempts,
      Value<String?> lastError,
      Value<String?> leaseOwner,
      Value<DateTime?> leaseUntil,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CommentJobsTableReferences
    extends BaseReferences<_$AppDatabase, $CommentJobsTable, CommentJobRow> {
  $$CommentJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CommentJobItemsTable, List<CommentJobItemRow>>
  _commentJobItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commentJobItems,
    aliasName: 'comment_jobs__id__comment_job_items__job_id',
  );

  $$CommentJobItemsTableProcessedTableManager get commentJobItemsRefs {
    final manager = $$CommentJobItemsTableTableManager(
      $_db,
      $_db.commentJobItems,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _commentJobItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CommentJobsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentJobsTable> {
  $$CommentJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pickedNetizenIdsJson => $composableBuilder(
    column: $table.pickedNetizenIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> commentJobItemsRefs(
    Expression<bool> Function($$CommentJobItemsTableFilterComposer f) f,
  ) {
    final $$CommentJobItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commentJobItems,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentJobItemsTableFilterComposer(
            $db: $db,
            $table: $db.commentJobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommentJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentJobsTable> {
  $$CommentJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleId => $composableBuilder(
    column: $table.articleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pickedNetizenIdsJson => $composableBuilder(
    column: $table.pickedNetizenIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommentJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentJobsTable> {
  $$CommentJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get articleId =>
      $composableBuilder(column: $table.articleId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<String> get pickedNetizenIdsJson => $composableBuilder(
    column: $table.pickedNetizenIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get leaseOwner => $composableBuilder(
    column: $table.leaseOwner,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> commentJobItemsRefs<T extends Object>(
    Expression<T> Function($$CommentJobItemsTableAnnotationComposer a) f,
  ) {
    final $$CommentJobItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commentJobItems,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentJobItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.commentJobItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommentJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommentJobsTable,
          CommentJobRow,
          $$CommentJobsTableFilterComposer,
          $$CommentJobsTableOrderingComposer,
          $$CommentJobsTableAnnotationComposer,
          $$CommentJobsTableCreateCompanionBuilder,
          $$CommentJobsTableUpdateCompanionBuilder,
          (CommentJobRow, $$CommentJobsTableReferences),
          CommentJobRow,
          PrefetchHooks Function({bool commentJobItemsRefs})
        > {
  $$CommentJobsTableTableManager(_$AppDatabase db, $CommentJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> trigger = const Value.absent(),
                Value<String> pickedNetizenIdsJson = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<int> maxAttempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> leaseOwner = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentJobsCompanion(
                id: id,
                articleId: articleId,
                status: status,
                trigger: trigger,
                pickedNetizenIdsJson: pickedNetizenIdsJson,
                attempt: attempt,
                maxAttempts: maxAttempts,
                lastError: lastError,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String articleId,
                required String status,
                required String trigger,
                Value<String> pickedNetizenIdsJson = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<int> maxAttempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> leaseOwner = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CommentJobsCompanion.insert(
                id: id,
                articleId: articleId,
                status: status,
                trigger: trigger,
                pickedNetizenIdsJson: pickedNetizenIdsJson,
                attempt: attempt,
                maxAttempts: maxAttempts,
                lastError: lastError,
                leaseOwner: leaseOwner,
                leaseUntil: leaseUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommentJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({commentJobItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (commentJobItemsRefs) db.commentJobItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (commentJobItemsRefs)
                    await $_getPrefetchedData<
                      CommentJobRow,
                      $CommentJobsTable,
                      CommentJobItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$CommentJobsTableReferences
                          ._commentJobItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CommentJobsTableReferences(
                            db,
                            table,
                            p0,
                          ).commentJobItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.jobId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CommentJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommentJobsTable,
      CommentJobRow,
      $$CommentJobsTableFilterComposer,
      $$CommentJobsTableOrderingComposer,
      $$CommentJobsTableAnnotationComposer,
      $$CommentJobsTableCreateCompanionBuilder,
      $$CommentJobsTableUpdateCompanionBuilder,
      (CommentJobRow, $$CommentJobsTableReferences),
      CommentJobRow,
      PrefetchHooks Function({bool commentJobItemsRefs})
    >;
typedef $$CommentJobItemsTableCreateCompanionBuilder =
    CommentJobItemsCompanion Function({
      required String id,
      required String jobId,
      required String netizenId,
      required String status,
      Value<int> attempt,
      Value<String?> lastError,
      Value<String?> commentId,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CommentJobItemsTableUpdateCompanionBuilder =
    CommentJobItemsCompanion Function({
      Value<String> id,
      Value<String> jobId,
      Value<String> netizenId,
      Value<String> status,
      Value<int> attempt,
      Value<String?> lastError,
      Value<String?> commentId,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CommentJobItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CommentJobItemsTable,
          CommentJobItemRow
        > {
  $$CommentJobItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CommentJobsTable _jobIdTable(_$AppDatabase db) =>
      db.commentJobs.createAlias('comment_job_items__job_id__comment_jobs__id');

  $$CommentJobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<String>('job_id')!;

    final manager = $$CommentJobsTableTableManager(
      $_db,
      $_db.commentJobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommentJobItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentJobItemsTable> {
  $$CommentJobItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get netizenId => $composableBuilder(
    column: $table.netizenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentId => $composableBuilder(
    column: $table.commentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CommentJobsTableFilterComposer get jobId {
    final $$CommentJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.commentJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentJobsTableFilterComposer(
            $db: $db,
            $table: $db.commentJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentJobItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentJobItemsTable> {
  $$CommentJobItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get netizenId => $composableBuilder(
    column: $table.netizenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentId => $composableBuilder(
    column: $table.commentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CommentJobsTableOrderingComposer get jobId {
    final $$CommentJobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.commentJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentJobsTableOrderingComposer(
            $db: $db,
            $table: $db.commentJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentJobItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentJobItemsTable> {
  $$CommentJobItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get netizenId =>
      $composableBuilder(column: $table.netizenId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get commentId =>
      $composableBuilder(column: $table.commentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CommentJobsTableAnnotationComposer get jobId {
    final $$CommentJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.commentJobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.commentJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentJobItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommentJobItemsTable,
          CommentJobItemRow,
          $$CommentJobItemsTableFilterComposer,
          $$CommentJobItemsTableOrderingComposer,
          $$CommentJobItemsTableAnnotationComposer,
          $$CommentJobItemsTableCreateCompanionBuilder,
          $$CommentJobItemsTableUpdateCompanionBuilder,
          (CommentJobItemRow, $$CommentJobItemsTableReferences),
          CommentJobItemRow,
          PrefetchHooks Function({bool jobId})
        > {
  $$CommentJobItemsTableTableManager(
    _$AppDatabase db,
    $CommentJobItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentJobItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentJobItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentJobItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobId = const Value.absent(),
                Value<String> netizenId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> commentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentJobItemsCompanion(
                id: id,
                jobId: jobId,
                netizenId: netizenId,
                status: status,
                attempt: attempt,
                lastError: lastError,
                commentId: commentId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jobId,
                required String netizenId,
                required String status,
                Value<int> attempt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> commentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CommentJobItemsCompanion.insert(
                id: id,
                jobId: jobId,
                netizenId: netizenId,
                status: status,
                attempt: attempt,
                lastError: lastError,
                commentId: commentId,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommentJobItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable:
                                    $$CommentJobItemsTableReferences
                                        ._jobIdTable(db),
                                referencedColumn:
                                    $$CommentJobItemsTableReferences
                                        ._jobIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CommentJobItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommentJobItemsTable,
      CommentJobItemRow,
      $$CommentJobItemsTableFilterComposer,
      $$CommentJobItemsTableOrderingComposer,
      $$CommentJobItemsTableAnnotationComposer,
      $$CommentJobItemsTableCreateCompanionBuilder,
      $$CommentJobItemsTableUpdateCompanionBuilder,
      (CommentJobItemRow, $$CommentJobItemsTableReferences),
      CommentJobItemRow,
      PrefetchHooks Function({bool jobId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db, _db.feeds);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$ChatSessionsTableTableManager get chatSessions =>
      $$ChatSessionsTableTableManager(_db, _db.chatSessions);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$MediaChatMessagesTableTableManager get mediaChatMessages =>
      $$MediaChatMessagesTableTableManager(_db, _db.mediaChatMessages);
  $$CompanionsTableTableManager get companions =>
      $$CompanionsTableTableManager(_db, _db.companions);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$WarmEventsTableTableManager get warmEvents =>
      $$WarmEventsTableTableManager(_db, _db.warmEvents);
  $$AppSettingsRowsTableTableManager get appSettingsRows =>
      $$AppSettingsRowsTableTableManager(_db, _db.appSettingsRows);
  $$LlmProvidersTableTableManager get llmProviders =>
      $$LlmProvidersTableTableManager(_db, _db.llmProviders);
  $$LlmModelsTableTableManager get llmModels =>
      $$LlmModelsTableTableManager(_db, _db.llmModels);
  $$NetizensTableTableManager get netizens =>
      $$NetizensTableTableManager(_db, _db.netizens);
  $$CommentsTableTableManager get comments =>
      $$CommentsTableTableManager(_db, _db.comments);
  $$CommentJobsTableTableManager get commentJobs =>
      $$CommentJobsTableTableManager(_db, _db.commentJobs);
  $$CommentJobItemsTableTableManager get commentJobItems =>
      $$CommentJobItemsTableTableManager(_db, _db.commentJobItems);
}

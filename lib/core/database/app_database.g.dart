// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalWorkAreasTable extends LocalWorkAreas
    with TableInfo<$LocalWorkAreasTable, LocalWorkArea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWorkAreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boundaryMeta =
      const VerificationMeta('boundary');
  @override
  late final GeneratedColumn<String> boundary = GeneratedColumn<String>(
      'boundary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, boundary, syncStatus, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_work_areas';
  @override
  VerificationContext validateIntegrity(Insertable<LocalWorkArea> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('boundary')) {
      context.handle(_boundaryMeta,
          boundary.isAcceptableOrUnknown(data['boundary']!, _boundaryMeta));
    } else if (isInserting) {
      context.missing(_boundaryMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalWorkArea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWorkArea(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      boundary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boundary'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalWorkAreasTable createAlias(String alias) {
    return $LocalWorkAreasTable(attachedDatabase, alias);
  }
}

class LocalWorkArea extends DataClass implements Insertable<LocalWorkArea> {
  final String id;
  final String name;
  final String? description;
  final String boundary;
  final String syncStatus;
  final DateTime updatedAt;
  const LocalWorkArea(
      {required this.id,
      required this.name,
      this.description,
      required this.boundary,
      required this.syncStatus,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['boundary'] = Variable<String>(boundary);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalWorkAreasCompanion toCompanion(bool nullToAbsent) {
    return LocalWorkAreasCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      boundary: Value(boundary),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalWorkArea.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWorkArea(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      boundary: serializer.fromJson<String>(json['boundary']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'boundary': serializer.toJson<String>(boundary),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalWorkArea copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? boundary,
          String? syncStatus,
          DateTime? updatedAt}) =>
      LocalWorkArea(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        boundary: boundary ?? this.boundary,
        syncStatus: syncStatus ?? this.syncStatus,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalWorkArea copyWithCompanion(LocalWorkAreasCompanion data) {
    return LocalWorkArea(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      boundary: data.boundary.present ? data.boundary.value : this.boundary,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWorkArea(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('boundary: $boundary, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, boundary, syncStatus, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWorkArea &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.boundary == this.boundary &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class LocalWorkAreasCompanion extends UpdateCompanion<LocalWorkArea> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> boundary;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalWorkAreasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.boundary = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWorkAreasCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String boundary,
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        boundary = Value(boundary);
  static Insertable<LocalWorkArea> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? boundary,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (boundary != null) 'boundary': boundary,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWorkAreasCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? boundary,
      Value<String>? syncStatus,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalWorkAreasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      boundary: boundary ?? this.boundary,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (boundary.present) {
      map['boundary'] = Variable<String>(boundary.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('LocalWorkAreasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('boundary: $boundary, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTreesTable extends LocalTrees
    with TableInfo<$LocalTreesTable, LocalTree> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTreesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
      'height', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _diameterMeta =
      const VerificationMeta('diameter');
  @override
  late final GeneratedColumn<double> diameter = GeneratedColumn<double>(
      'diameter', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _healthStatusMeta =
      const VerificationMeta('healthStatus');
  @override
  late final GeneratedColumn<String> healthStatus = GeneratedColumn<String>(
      'health_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _workAreaIdMeta =
      const VerificationMeta('workAreaId');
  @override
  late final GeneratedColumn<String> workAreaId = GeneratedColumn<String>(
      'work_area_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_work_areas (id)'));
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
      'plot_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
      'volume', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _forestSectionMeta =
      const VerificationMeta('forestSection');
  @override
  late final GeneratedColumn<String> forestSection = GeneratedColumn<String>(
      'forest_section', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subSectionMeta =
      const VerificationMeta('subSection');
  @override
  late final GeneratedColumn<String> subSection = GeneratedColumn<String>(
      'sub_section', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _treeNumberMeta =
      const VerificationMeta('treeNumber');
  @override
  late final GeneratedColumn<String> treeNumber = GeneratedColumn<String>(
      'tree_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vigorMeta = const VerificationMeta('vigor');
  @override
  late final GeneratedColumn<String> vigor = GeneratedColumn<String>(
      'vigor', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pestDiseaseMeta =
      const VerificationMeta('pestDisease');
  @override
  late final GeneratedColumn<String> pestDisease = GeneratedColumn<String>(
      'pest_disease', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _slopeMeta = const VerificationMeta('slope');
  @override
  late final GeneratedColumn<double> slope = GeneratedColumn<double>(
      'slope', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _aspectMeta = const VerificationMeta('aspect');
  @override
  late final GeneratedColumn<String> aspect = GeneratedColumn<String>(
      'aspect', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _markedForThinningMeta =
      const VerificationMeta('markedForThinning');
  @override
  late final GeneratedColumn<bool> markedForThinning = GeneratedColumn<bool>(
      'marked_for_thinning', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("marked_for_thinning" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        species,
        height,
        diameter,
        healthStatus,
        location,
        workAreaId,
        plotId,
        photoUrl,
        photoPath,
        volume,
        age,
        forestSection,
        subSection,
        treeNumber,
        vigor,
        pestDisease,
        slope,
        aspect,
        notes,
        markedForThinning,
        syncStatus,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_trees';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTree> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('diameter')) {
      context.handle(_diameterMeta,
          diameter.isAcceptableOrUnknown(data['diameter']!, _diameterMeta));
    }
    if (data.containsKey('health_status')) {
      context.handle(
          _healthStatusMeta,
          healthStatus.isAcceptableOrUnknown(
              data['health_status']!, _healthStatusMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('work_area_id')) {
      context.handle(
          _workAreaIdMeta,
          workAreaId.isAcceptableOrUnknown(
              data['work_area_id']!, _workAreaIdMeta));
    } else if (isInserting) {
      context.missing(_workAreaIdMeta);
    }
    if (data.containsKey('plot_id')) {
      context.handle(_plotIdMeta,
          plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('forest_section')) {
      context.handle(
          _forestSectionMeta,
          forestSection.isAcceptableOrUnknown(
              data['forest_section']!, _forestSectionMeta));
    }
    if (data.containsKey('sub_section')) {
      context.handle(
          _subSectionMeta,
          subSection.isAcceptableOrUnknown(
              data['sub_section']!, _subSectionMeta));
    }
    if (data.containsKey('tree_number')) {
      context.handle(
          _treeNumberMeta,
          treeNumber.isAcceptableOrUnknown(
              data['tree_number']!, _treeNumberMeta));
    }
    if (data.containsKey('vigor')) {
      context.handle(
          _vigorMeta, vigor.isAcceptableOrUnknown(data['vigor']!, _vigorMeta));
    }
    if (data.containsKey('pest_disease')) {
      context.handle(
          _pestDiseaseMeta,
          pestDisease.isAcceptableOrUnknown(
              data['pest_disease']!, _pestDiseaseMeta));
    }
    if (data.containsKey('slope')) {
      context.handle(
          _slopeMeta, slope.isAcceptableOrUnknown(data['slope']!, _slopeMeta));
    }
    if (data.containsKey('aspect')) {
      context.handle(_aspectMeta,
          aspect.isAcceptableOrUnknown(data['aspect']!, _aspectMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('marked_for_thinning')) {
      context.handle(
          _markedForThinningMeta,
          markedForThinning.isAcceptableOrUnknown(
              data['marked_for_thinning']!, _markedForThinningMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTree map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTree(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height']),
      diameter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}diameter']),
      healthStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}health_status']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      workAreaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}work_area_id'])!,
      plotId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plot_id']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}volume']),
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      forestSection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}forest_section']),
      subSection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_section']),
      treeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tree_number']),
      vigor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vigor']),
      pestDisease: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pest_disease']),
      slope: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}slope']),
      aspect: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aspect']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      markedForThinning: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}marked_for_thinning'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalTreesTable createAlias(String alias) {
    return $LocalTreesTable(attachedDatabase, alias);
  }
}

class LocalTree extends DataClass implements Insertable<LocalTree> {
  final String id;
  final String species;
  final double? height;
  final double? diameter;
  final String? healthStatus;
  final String location;
  final String workAreaId;
  final String? plotId;
  final String? photoUrl;
  final String? photoPath;
  final double? volume;
  final int? age;
  final String? forestSection;
  final String? subSection;
  final String? treeNumber;
  final String? vigor;
  final String? pestDisease;
  final double? slope;
  final String? aspect;
  final String? notes;
  final bool markedForThinning;
  final String syncStatus;
  final DateTime updatedAt;
  const LocalTree(
      {required this.id,
      required this.species,
      this.height,
      this.diameter,
      this.healthStatus,
      required this.location,
      required this.workAreaId,
      this.plotId,
      this.photoUrl,
      this.photoPath,
      this.volume,
      this.age,
      this.forestSection,
      this.subSection,
      this.treeNumber,
      this.vigor,
      this.pestDisease,
      this.slope,
      this.aspect,
      this.notes,
      required this.markedForThinning,
      required this.syncStatus,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    if (!nullToAbsent || diameter != null) {
      map['diameter'] = Variable<double>(diameter);
    }
    if (!nullToAbsent || healthStatus != null) {
      map['health_status'] = Variable<String>(healthStatus);
    }
    map['location'] = Variable<String>(location);
    map['work_area_id'] = Variable<String>(workAreaId);
    if (!nullToAbsent || plotId != null) {
      map['plot_id'] = Variable<String>(plotId);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<double>(volume);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || forestSection != null) {
      map['forest_section'] = Variable<String>(forestSection);
    }
    if (!nullToAbsent || subSection != null) {
      map['sub_section'] = Variable<String>(subSection);
    }
    if (!nullToAbsent || treeNumber != null) {
      map['tree_number'] = Variable<String>(treeNumber);
    }
    if (!nullToAbsent || vigor != null) {
      map['vigor'] = Variable<String>(vigor);
    }
    if (!nullToAbsent || pestDisease != null) {
      map['pest_disease'] = Variable<String>(pestDisease);
    }
    if (!nullToAbsent || slope != null) {
      map['slope'] = Variable<double>(slope);
    }
    if (!nullToAbsent || aspect != null) {
      map['aspect'] = Variable<String>(aspect);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['marked_for_thinning'] = Variable<bool>(markedForThinning);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalTreesCompanion toCompanion(bool nullToAbsent) {
    return LocalTreesCompanion(
      id: Value(id),
      species: Value(species),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      diameter: diameter == null && nullToAbsent
          ? const Value.absent()
          : Value(diameter),
      healthStatus: healthStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(healthStatus),
      location: Value(location),
      workAreaId: Value(workAreaId),
      plotId:
          plotId == null && nullToAbsent ? const Value.absent() : Value(plotId),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      volume:
          volume == null && nullToAbsent ? const Value.absent() : Value(volume),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      forestSection: forestSection == null && nullToAbsent
          ? const Value.absent()
          : Value(forestSection),
      subSection: subSection == null && nullToAbsent
          ? const Value.absent()
          : Value(subSection),
      treeNumber: treeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(treeNumber),
      vigor:
          vigor == null && nullToAbsent ? const Value.absent() : Value(vigor),
      pestDisease: pestDisease == null && nullToAbsent
          ? const Value.absent()
          : Value(pestDisease),
      slope:
          slope == null && nullToAbsent ? const Value.absent() : Value(slope),
      aspect:
          aspect == null && nullToAbsent ? const Value.absent() : Value(aspect),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      markedForThinning: Value(markedForThinning),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalTree.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTree(
      id: serializer.fromJson<String>(json['id']),
      species: serializer.fromJson<String>(json['species']),
      height: serializer.fromJson<double?>(json['height']),
      diameter: serializer.fromJson<double?>(json['diameter']),
      healthStatus: serializer.fromJson<String?>(json['healthStatus']),
      location: serializer.fromJson<String>(json['location']),
      workAreaId: serializer.fromJson<String>(json['workAreaId']),
      plotId: serializer.fromJson<String?>(json['plotId']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      volume: serializer.fromJson<double?>(json['volume']),
      age: serializer.fromJson<int?>(json['age']),
      forestSection: serializer.fromJson<String?>(json['forestSection']),
      subSection: serializer.fromJson<String?>(json['subSection']),
      treeNumber: serializer.fromJson<String?>(json['treeNumber']),
      vigor: serializer.fromJson<String?>(json['vigor']),
      pestDisease: serializer.fromJson<String?>(json['pestDisease']),
      slope: serializer.fromJson<double?>(json['slope']),
      aspect: serializer.fromJson<String?>(json['aspect']),
      notes: serializer.fromJson<String?>(json['notes']),
      markedForThinning: serializer.fromJson<bool>(json['markedForThinning']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'species': serializer.toJson<String>(species),
      'height': serializer.toJson<double?>(height),
      'diameter': serializer.toJson<double?>(diameter),
      'healthStatus': serializer.toJson<String?>(healthStatus),
      'location': serializer.toJson<String>(location),
      'workAreaId': serializer.toJson<String>(workAreaId),
      'plotId': serializer.toJson<String?>(plotId),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'photoPath': serializer.toJson<String?>(photoPath),
      'volume': serializer.toJson<double?>(volume),
      'age': serializer.toJson<int?>(age),
      'forestSection': serializer.toJson<String?>(forestSection),
      'subSection': serializer.toJson<String?>(subSection),
      'treeNumber': serializer.toJson<String?>(treeNumber),
      'vigor': serializer.toJson<String?>(vigor),
      'pestDisease': serializer.toJson<String?>(pestDisease),
      'slope': serializer.toJson<double?>(slope),
      'aspect': serializer.toJson<String?>(aspect),
      'notes': serializer.toJson<String?>(notes),
      'markedForThinning': serializer.toJson<bool>(markedForThinning),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalTree copyWith(
          {String? id,
          String? species,
          Value<double?> height = const Value.absent(),
          Value<double?> diameter = const Value.absent(),
          Value<String?> healthStatus = const Value.absent(),
          String? location,
          String? workAreaId,
          Value<String?> plotId = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          Value<double?> volume = const Value.absent(),
          Value<int?> age = const Value.absent(),
          Value<String?> forestSection = const Value.absent(),
          Value<String?> subSection = const Value.absent(),
          Value<String?> treeNumber = const Value.absent(),
          Value<String?> vigor = const Value.absent(),
          Value<String?> pestDisease = const Value.absent(),
          Value<double?> slope = const Value.absent(),
          Value<String?> aspect = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? markedForThinning,
          String? syncStatus,
          DateTime? updatedAt}) =>
      LocalTree(
        id: id ?? this.id,
        species: species ?? this.species,
        height: height.present ? height.value : this.height,
        diameter: diameter.present ? diameter.value : this.diameter,
        healthStatus:
            healthStatus.present ? healthStatus.value : this.healthStatus,
        location: location ?? this.location,
        workAreaId: workAreaId ?? this.workAreaId,
        plotId: plotId.present ? plotId.value : this.plotId,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        volume: volume.present ? volume.value : this.volume,
        age: age.present ? age.value : this.age,
        forestSection:
            forestSection.present ? forestSection.value : this.forestSection,
        subSection: subSection.present ? subSection.value : this.subSection,
        treeNumber: treeNumber.present ? treeNumber.value : this.treeNumber,
        vigor: vigor.present ? vigor.value : this.vigor,
        pestDisease: pestDisease.present ? pestDisease.value : this.pestDisease,
        slope: slope.present ? slope.value : this.slope,
        aspect: aspect.present ? aspect.value : this.aspect,
        notes: notes.present ? notes.value : this.notes,
        markedForThinning: markedForThinning ?? this.markedForThinning,
        syncStatus: syncStatus ?? this.syncStatus,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalTree copyWithCompanion(LocalTreesCompanion data) {
    return LocalTree(
      id: data.id.present ? data.id.value : this.id,
      species: data.species.present ? data.species.value : this.species,
      height: data.height.present ? data.height.value : this.height,
      diameter: data.diameter.present ? data.diameter.value : this.diameter,
      healthStatus: data.healthStatus.present
          ? data.healthStatus.value
          : this.healthStatus,
      location: data.location.present ? data.location.value : this.location,
      workAreaId:
          data.workAreaId.present ? data.workAreaId.value : this.workAreaId,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      volume: data.volume.present ? data.volume.value : this.volume,
      age: data.age.present ? data.age.value : this.age,
      forestSection: data.forestSection.present
          ? data.forestSection.value
          : this.forestSection,
      subSection:
          data.subSection.present ? data.subSection.value : this.subSection,
      treeNumber:
          data.treeNumber.present ? data.treeNumber.value : this.treeNumber,
      vigor: data.vigor.present ? data.vigor.value : this.vigor,
      pestDisease:
          data.pestDisease.present ? data.pestDisease.value : this.pestDisease,
      slope: data.slope.present ? data.slope.value : this.slope,
      aspect: data.aspect.present ? data.aspect.value : this.aspect,
      notes: data.notes.present ? data.notes.value : this.notes,
      markedForThinning: data.markedForThinning.present
          ? data.markedForThinning.value
          : this.markedForThinning,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTree(')
          ..write('id: $id, ')
          ..write('species: $species, ')
          ..write('height: $height, ')
          ..write('diameter: $diameter, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('location: $location, ')
          ..write('workAreaId: $workAreaId, ')
          ..write('plotId: $plotId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoPath: $photoPath, ')
          ..write('volume: $volume, ')
          ..write('age: $age, ')
          ..write('forestSection: $forestSection, ')
          ..write('subSection: $subSection, ')
          ..write('treeNumber: $treeNumber, ')
          ..write('vigor: $vigor, ')
          ..write('pestDisease: $pestDisease, ')
          ..write('slope: $slope, ')
          ..write('aspect: $aspect, ')
          ..write('notes: $notes, ')
          ..write('markedForThinning: $markedForThinning, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        species,
        height,
        diameter,
        healthStatus,
        location,
        workAreaId,
        plotId,
        photoUrl,
        photoPath,
        volume,
        age,
        forestSection,
        subSection,
        treeNumber,
        vigor,
        pestDisease,
        slope,
        aspect,
        notes,
        markedForThinning,
        syncStatus,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTree &&
          other.id == this.id &&
          other.species == this.species &&
          other.height == this.height &&
          other.diameter == this.diameter &&
          other.healthStatus == this.healthStatus &&
          other.location == this.location &&
          other.workAreaId == this.workAreaId &&
          other.plotId == this.plotId &&
          other.photoUrl == this.photoUrl &&
          other.photoPath == this.photoPath &&
          other.volume == this.volume &&
          other.age == this.age &&
          other.forestSection == this.forestSection &&
          other.subSection == this.subSection &&
          other.treeNumber == this.treeNumber &&
          other.vigor == this.vigor &&
          other.pestDisease == this.pestDisease &&
          other.slope == this.slope &&
          other.aspect == this.aspect &&
          other.notes == this.notes &&
          other.markedForThinning == this.markedForThinning &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class LocalTreesCompanion extends UpdateCompanion<LocalTree> {
  final Value<String> id;
  final Value<String> species;
  final Value<double?> height;
  final Value<double?> diameter;
  final Value<String?> healthStatus;
  final Value<String> location;
  final Value<String> workAreaId;
  final Value<String?> plotId;
  final Value<String?> photoUrl;
  final Value<String?> photoPath;
  final Value<double?> volume;
  final Value<int?> age;
  final Value<String?> forestSection;
  final Value<String?> subSection;
  final Value<String?> treeNumber;
  final Value<String?> vigor;
  final Value<String?> pestDisease;
  final Value<double?> slope;
  final Value<String?> aspect;
  final Value<String?> notes;
  final Value<bool> markedForThinning;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalTreesCompanion({
    this.id = const Value.absent(),
    this.species = const Value.absent(),
    this.height = const Value.absent(),
    this.diameter = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.location = const Value.absent(),
    this.workAreaId = const Value.absent(),
    this.plotId = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.volume = const Value.absent(),
    this.age = const Value.absent(),
    this.forestSection = const Value.absent(),
    this.subSection = const Value.absent(),
    this.treeNumber = const Value.absent(),
    this.vigor = const Value.absent(),
    this.pestDisease = const Value.absent(),
    this.slope = const Value.absent(),
    this.aspect = const Value.absent(),
    this.notes = const Value.absent(),
    this.markedForThinning = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTreesCompanion.insert({
    required String id,
    required String species,
    this.height = const Value.absent(),
    this.diameter = const Value.absent(),
    this.healthStatus = const Value.absent(),
    required String location,
    required String workAreaId,
    this.plotId = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.volume = const Value.absent(),
    this.age = const Value.absent(),
    this.forestSection = const Value.absent(),
    this.subSection = const Value.absent(),
    this.treeNumber = const Value.absent(),
    this.vigor = const Value.absent(),
    this.pestDisease = const Value.absent(),
    this.slope = const Value.absent(),
    this.aspect = const Value.absent(),
    this.notes = const Value.absent(),
    this.markedForThinning = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        species = Value(species),
        location = Value(location),
        workAreaId = Value(workAreaId);
  static Insertable<LocalTree> custom({
    Expression<String>? id,
    Expression<String>? species,
    Expression<double>? height,
    Expression<double>? diameter,
    Expression<String>? healthStatus,
    Expression<String>? location,
    Expression<String>? workAreaId,
    Expression<String>? plotId,
    Expression<String>? photoUrl,
    Expression<String>? photoPath,
    Expression<double>? volume,
    Expression<int>? age,
    Expression<String>? forestSection,
    Expression<String>? subSection,
    Expression<String>? treeNumber,
    Expression<String>? vigor,
    Expression<String>? pestDisease,
    Expression<double>? slope,
    Expression<String>? aspect,
    Expression<String>? notes,
    Expression<bool>? markedForThinning,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (species != null) 'species': species,
      if (height != null) 'height': height,
      if (diameter != null) 'diameter': diameter,
      if (healthStatus != null) 'health_status': healthStatus,
      if (location != null) 'location': location,
      if (workAreaId != null) 'work_area_id': workAreaId,
      if (plotId != null) 'plot_id': plotId,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoPath != null) 'photo_path': photoPath,
      if (volume != null) 'volume': volume,
      if (age != null) 'age': age,
      if (forestSection != null) 'forest_section': forestSection,
      if (subSection != null) 'sub_section': subSection,
      if (treeNumber != null) 'tree_number': treeNumber,
      if (vigor != null) 'vigor': vigor,
      if (pestDisease != null) 'pest_disease': pestDisease,
      if (slope != null) 'slope': slope,
      if (aspect != null) 'aspect': aspect,
      if (notes != null) 'notes': notes,
      if (markedForThinning != null) 'marked_for_thinning': markedForThinning,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTreesCompanion copyWith(
      {Value<String>? id,
      Value<String>? species,
      Value<double?>? height,
      Value<double?>? diameter,
      Value<String?>? healthStatus,
      Value<String>? location,
      Value<String>? workAreaId,
      Value<String?>? plotId,
      Value<String?>? photoUrl,
      Value<String?>? photoPath,
      Value<double?>? volume,
      Value<int?>? age,
      Value<String?>? forestSection,
      Value<String?>? subSection,
      Value<String?>? treeNumber,
      Value<String?>? vigor,
      Value<String?>? pestDisease,
      Value<double?>? slope,
      Value<String?>? aspect,
      Value<String?>? notes,
      Value<bool>? markedForThinning,
      Value<String>? syncStatus,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalTreesCompanion(
      id: id ?? this.id,
      species: species ?? this.species,
      height: height ?? this.height,
      diameter: diameter ?? this.diameter,
      healthStatus: healthStatus ?? this.healthStatus,
      location: location ?? this.location,
      workAreaId: workAreaId ?? this.workAreaId,
      plotId: plotId ?? this.plotId,
      photoUrl: photoUrl ?? this.photoUrl,
      photoPath: photoPath ?? this.photoPath,
      volume: volume ?? this.volume,
      age: age ?? this.age,
      forestSection: forestSection ?? this.forestSection,
      subSection: subSection ?? this.subSection,
      treeNumber: treeNumber ?? this.treeNumber,
      vigor: vigor ?? this.vigor,
      pestDisease: pestDisease ?? this.pestDisease,
      slope: slope ?? this.slope,
      aspect: aspect ?? this.aspect,
      notes: notes ?? this.notes,
      markedForThinning: markedForThinning ?? this.markedForThinning,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (diameter.present) {
      map['diameter'] = Variable<double>(diameter.value);
    }
    if (healthStatus.present) {
      map['health_status'] = Variable<String>(healthStatus.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (workAreaId.present) {
      map['work_area_id'] = Variable<String>(workAreaId.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (forestSection.present) {
      map['forest_section'] = Variable<String>(forestSection.value);
    }
    if (subSection.present) {
      map['sub_section'] = Variable<String>(subSection.value);
    }
    if (treeNumber.present) {
      map['tree_number'] = Variable<String>(treeNumber.value);
    }
    if (vigor.present) {
      map['vigor'] = Variable<String>(vigor.value);
    }
    if (pestDisease.present) {
      map['pest_disease'] = Variable<String>(pestDisease.value);
    }
    if (slope.present) {
      map['slope'] = Variable<double>(slope.value);
    }
    if (aspect.present) {
      map['aspect'] = Variable<String>(aspect.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (markedForThinning.present) {
      map['marked_for_thinning'] = Variable<bool>(markedForThinning.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('LocalTreesCompanion(')
          ..write('id: $id, ')
          ..write('species: $species, ')
          ..write('height: $height, ')
          ..write('diameter: $diameter, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('location: $location, ')
          ..write('workAreaId: $workAreaId, ')
          ..write('plotId: $plotId, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoPath: $photoPath, ')
          ..write('volume: $volume, ')
          ..write('age: $age, ')
          ..write('forestSection: $forestSection, ')
          ..write('subSection: $subSection, ')
          ..write('treeNumber: $treeNumber, ')
          ..write('vigor: $vigor, ')
          ..write('pestDisease: $pestDisease, ')
          ..write('slope: $slope, ')
          ..write('aspect: $aspect, ')
          ..write('notes: $notes, ')
          ..write('markedForThinning: $markedForThinning, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMapObjectsTable extends LocalMapObjects
    with TableInfo<$LocalMapObjectsTable, LocalMapObject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMapObjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _geometryMeta =
      const VerificationMeta('geometry');
  @override
  late final GeneratedColumn<String> geometry = GeneratedColumn<String>(
      'geometry', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _workAreaIdMeta =
      const VerificationMeta('workAreaId');
  @override
  late final GeneratedColumn<String> workAreaId = GeneratedColumn<String>(
      'work_area_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_work_areas (id)'));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attributesMeta =
      const VerificationMeta('attributes');
  @override
  late final GeneratedColumn<String> attributes = GeneratedColumn<String>(
      'attributes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        geometry,
        name,
        description,
        workAreaId,
        photoPath,
        attributes,
        syncStatus,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_map_objects';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMapObject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('geometry')) {
      context.handle(_geometryMeta,
          geometry.isAcceptableOrUnknown(data['geometry']!, _geometryMeta));
    } else if (isInserting) {
      context.missing(_geometryMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('work_area_id')) {
      context.handle(
          _workAreaIdMeta,
          workAreaId.isAcceptableOrUnknown(
              data['work_area_id']!, _workAreaIdMeta));
    } else if (isInserting) {
      context.missing(_workAreaIdMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('attributes')) {
      context.handle(
          _attributesMeta,
          attributes.isAcceptableOrUnknown(
              data['attributes']!, _attributesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMapObject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMapObject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      geometry: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}geometry'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      workAreaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}work_area_id'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      attributes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attributes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalMapObjectsTable createAlias(String alias) {
    return $LocalMapObjectsTable(attachedDatabase, alias);
  }
}

class LocalMapObject extends DataClass implements Insertable<LocalMapObject> {
  final String id;
  final String type;
  final String geometry;
  final String? name;
  final String? description;
  final String workAreaId;
  final String? photoPath;
  final String? attributes;
  final String syncStatus;
  final DateTime updatedAt;
  const LocalMapObject(
      {required this.id,
      required this.type,
      required this.geometry,
      this.name,
      this.description,
      required this.workAreaId,
      this.photoPath,
      this.attributes,
      required this.syncStatus,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['geometry'] = Variable<String>(geometry);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['work_area_id'] = Variable<String>(workAreaId);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || attributes != null) {
      map['attributes'] = Variable<String>(attributes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalMapObjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalMapObjectsCompanion(
      id: Value(id),
      type: Value(type),
      geometry: Value(geometry),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      workAreaId: Value(workAreaId),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      attributes: attributes == null && nullToAbsent
          ? const Value.absent()
          : Value(attributes),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalMapObject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMapObject(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      geometry: serializer.fromJson<String>(json['geometry']),
      name: serializer.fromJson<String?>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      workAreaId: serializer.fromJson<String>(json['workAreaId']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      attributes: serializer.fromJson<String?>(json['attributes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'geometry': serializer.toJson<String>(geometry),
      'name': serializer.toJson<String?>(name),
      'description': serializer.toJson<String?>(description),
      'workAreaId': serializer.toJson<String>(workAreaId),
      'photoPath': serializer.toJson<String?>(photoPath),
      'attributes': serializer.toJson<String?>(attributes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalMapObject copyWith(
          {String? id,
          String? type,
          String? geometry,
          Value<String?> name = const Value.absent(),
          Value<String?> description = const Value.absent(),
          String? workAreaId,
          Value<String?> photoPath = const Value.absent(),
          Value<String?> attributes = const Value.absent(),
          String? syncStatus,
          DateTime? updatedAt}) =>
      LocalMapObject(
        id: id ?? this.id,
        type: type ?? this.type,
        geometry: geometry ?? this.geometry,
        name: name.present ? name.value : this.name,
        description: description.present ? description.value : this.description,
        workAreaId: workAreaId ?? this.workAreaId,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        attributes: attributes.present ? attributes.value : this.attributes,
        syncStatus: syncStatus ?? this.syncStatus,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalMapObject copyWithCompanion(LocalMapObjectsCompanion data) {
    return LocalMapObject(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      geometry: data.geometry.present ? data.geometry.value : this.geometry,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      workAreaId:
          data.workAreaId.present ? data.workAreaId.value : this.workAreaId,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      attributes:
          data.attributes.present ? data.attributes.value : this.attributes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMapObject(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('geometry: $geometry, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('workAreaId: $workAreaId, ')
          ..write('photoPath: $photoPath, ')
          ..write('attributes: $attributes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, geometry, name, description,
      workAreaId, photoPath, attributes, syncStatus, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMapObject &&
          other.id == this.id &&
          other.type == this.type &&
          other.geometry == this.geometry &&
          other.name == this.name &&
          other.description == this.description &&
          other.workAreaId == this.workAreaId &&
          other.photoPath == this.photoPath &&
          other.attributes == this.attributes &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class LocalMapObjectsCompanion extends UpdateCompanion<LocalMapObject> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> geometry;
  final Value<String?> name;
  final Value<String?> description;
  final Value<String> workAreaId;
  final Value<String?> photoPath;
  final Value<String?> attributes;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalMapObjectsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.geometry = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.workAreaId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.attributes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMapObjectsCompanion.insert({
    required String id,
    required String type,
    required String geometry,
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    required String workAreaId,
    this.photoPath = const Value.absent(),
    this.attributes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        geometry = Value(geometry),
        workAreaId = Value(workAreaId);
  static Insertable<LocalMapObject> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? geometry,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? workAreaId,
    Expression<String>? photoPath,
    Expression<String>? attributes,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (geometry != null) 'geometry': geometry,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (workAreaId != null) 'work_area_id': workAreaId,
      if (photoPath != null) 'photo_path': photoPath,
      if (attributes != null) 'attributes': attributes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMapObjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? geometry,
      Value<String?>? name,
      Value<String?>? description,
      Value<String>? workAreaId,
      Value<String?>? photoPath,
      Value<String?>? attributes,
      Value<String>? syncStatus,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalMapObjectsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      geometry: geometry ?? this.geometry,
      name: name ?? this.name,
      description: description ?? this.description,
      workAreaId: workAreaId ?? this.workAreaId,
      photoPath: photoPath ?? this.photoPath,
      attributes: attributes ?? this.attributes,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (geometry.present) {
      map['geometry'] = Variable<String>(geometry.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (workAreaId.present) {
      map['work_area_id'] = Variable<String>(workAreaId.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (attributes.present) {
      map['attributes'] = Variable<String>(attributes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('LocalMapObjectsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('geometry: $geometry, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('workAreaId: $workAreaId, ')
          ..write('photoPath: $photoPath, ')
          ..write('attributes: $attributes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPlotsTable extends LocalPlots
    with TableInfo<$LocalPlotsTable, LocalPlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shapeMeta = const VerificationMeta('shape');
  @override
  late final GeneratedColumn<String> shape = GeneratedColumn<String>(
      'shape', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _centerLatMeta =
      const VerificationMeta('centerLat');
  @override
  late final GeneratedColumn<double> centerLat = GeneratedColumn<double>(
      'center_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _centerLngMeta =
      const VerificationMeta('centerLng');
  @override
  late final GeneratedColumn<double> centerLng = GeneratedColumn<double>(
      'center_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<double> size = GeneratedColumn<double>(
      'size', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _workAreaIdMeta =
      const VerificationMeta('workAreaId');
  @override
  late final GeneratedColumn<String> workAreaId = GeneratedColumn<String>(
      'work_area_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_work_areas (id)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        shape,
        centerLat,
        centerLng,
        size,
        workAreaId,
        description,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_plots';
  @override
  VerificationContext validateIntegrity(Insertable<LocalPlot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('shape')) {
      context.handle(
          _shapeMeta, shape.isAcceptableOrUnknown(data['shape']!, _shapeMeta));
    } else if (isInserting) {
      context.missing(_shapeMeta);
    }
    if (data.containsKey('center_lat')) {
      context.handle(_centerLatMeta,
          centerLat.isAcceptableOrUnknown(data['center_lat']!, _centerLatMeta));
    } else if (isInserting) {
      context.missing(_centerLatMeta);
    }
    if (data.containsKey('center_lng')) {
      context.handle(_centerLngMeta,
          centerLng.isAcceptableOrUnknown(data['center_lng']!, _centerLngMeta));
    } else if (isInserting) {
      context.missing(_centerLngMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('work_area_id')) {
      context.handle(
          _workAreaIdMeta,
          workAreaId.isAcceptableOrUnknown(
              data['work_area_id']!, _workAreaIdMeta));
    } else if (isInserting) {
      context.missing(_workAreaIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shape: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shape'])!,
      centerLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}center_lat'])!,
      centerLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}center_lng'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}size'])!,
      workAreaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}work_area_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalPlotsTable createAlias(String alias) {
    return $LocalPlotsTable(attachedDatabase, alias);
  }
}

class LocalPlot extends DataClass implements Insertable<LocalPlot> {
  final String id;
  final String name;
  final String shape;
  final double centerLat;
  final double centerLng;
  final double size;
  final String workAreaId;
  final String? description;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalPlot(
      {required this.id,
      required this.name,
      required this.shape,
      required this.centerLat,
      required this.centerLng,
      required this.size,
      required this.workAreaId,
      this.description,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['shape'] = Variable<String>(shape);
    map['center_lat'] = Variable<double>(centerLat);
    map['center_lng'] = Variable<double>(centerLng);
    map['size'] = Variable<double>(size);
    map['work_area_id'] = Variable<String>(workAreaId);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPlotsCompanion toCompanion(bool nullToAbsent) {
    return LocalPlotsCompanion(
      id: Value(id),
      name: Value(name),
      shape: Value(shape),
      centerLat: Value(centerLat),
      centerLng: Value(centerLng),
      size: Value(size),
      workAreaId: Value(workAreaId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPlot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlot(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shape: serializer.fromJson<String>(json['shape']),
      centerLat: serializer.fromJson<double>(json['centerLat']),
      centerLng: serializer.fromJson<double>(json['centerLng']),
      size: serializer.fromJson<double>(json['size']),
      workAreaId: serializer.fromJson<String>(json['workAreaId']),
      description: serializer.fromJson<String?>(json['description']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
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
      'shape': serializer.toJson<String>(shape),
      'centerLat': serializer.toJson<double>(centerLat),
      'centerLng': serializer.toJson<double>(centerLng),
      'size': serializer.toJson<double>(size),
      'workAreaId': serializer.toJson<String>(workAreaId),
      'description': serializer.toJson<String?>(description),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPlot copyWith(
          {String? id,
          String? name,
          String? shape,
          double? centerLat,
          double? centerLng,
          double? size,
          String? workAreaId,
          Value<String?> description = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LocalPlot(
        id: id ?? this.id,
        name: name ?? this.name,
        shape: shape ?? this.shape,
        centerLat: centerLat ?? this.centerLat,
        centerLng: centerLng ?? this.centerLng,
        size: size ?? this.size,
        workAreaId: workAreaId ?? this.workAreaId,
        description: description.present ? description.value : this.description,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalPlot copyWithCompanion(LocalPlotsCompanion data) {
    return LocalPlot(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shape: data.shape.present ? data.shape.value : this.shape,
      centerLat: data.centerLat.present ? data.centerLat.value : this.centerLat,
      centerLng: data.centerLng.present ? data.centerLng.value : this.centerLng,
      size: data.size.present ? data.size.value : this.size,
      workAreaId:
          data.workAreaId.present ? data.workAreaId.value : this.workAreaId,
      description:
          data.description.present ? data.description.value : this.description,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlot(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shape: $shape, ')
          ..write('centerLat: $centerLat, ')
          ..write('centerLng: $centerLng, ')
          ..write('size: $size, ')
          ..write('workAreaId: $workAreaId, ')
          ..write('description: $description, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, shape, centerLat, centerLng, size,
      workAreaId, description, syncStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlot &&
          other.id == this.id &&
          other.name == this.name &&
          other.shape == this.shape &&
          other.centerLat == this.centerLat &&
          other.centerLng == this.centerLng &&
          other.size == this.size &&
          other.workAreaId == this.workAreaId &&
          other.description == this.description &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPlotsCompanion extends UpdateCompanion<LocalPlot> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> shape;
  final Value<double> centerLat;
  final Value<double> centerLng;
  final Value<double> size;
  final Value<String> workAreaId;
  final Value<String?> description;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPlotsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shape = const Value.absent(),
    this.centerLat = const Value.absent(),
    this.centerLng = const Value.absent(),
    this.size = const Value.absent(),
    this.workAreaId = const Value.absent(),
    this.description = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlotsCompanion.insert({
    required String id,
    required String name,
    required String shape,
    required double centerLat,
    required double centerLng,
    required double size,
    required String workAreaId,
    this.description = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        shape = Value(shape),
        centerLat = Value(centerLat),
        centerLng = Value(centerLng),
        size = Value(size),
        workAreaId = Value(workAreaId);
  static Insertable<LocalPlot> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shape,
    Expression<double>? centerLat,
    Expression<double>? centerLng,
    Expression<double>? size,
    Expression<String>? workAreaId,
    Expression<String>? description,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shape != null) 'shape': shape,
      if (centerLat != null) 'center_lat': centerLat,
      if (centerLng != null) 'center_lng': centerLng,
      if (size != null) 'size': size,
      if (workAreaId != null) 'work_area_id': workAreaId,
      if (description != null) 'description': description,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlotsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? shape,
      Value<double>? centerLat,
      Value<double>? centerLng,
      Value<double>? size,
      Value<String>? workAreaId,
      Value<String?>? description,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalPlotsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shape: shape ?? this.shape,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      size: size ?? this.size,
      workAreaId: workAreaId ?? this.workAreaId,
      description: description ?? this.description,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (shape.present) {
      map['shape'] = Variable<String>(shape.value);
    }
    if (centerLat.present) {
      map['center_lat'] = Variable<double>(centerLat.value);
    }
    if (centerLng.present) {
      map['center_lng'] = Variable<double>(centerLng.value);
    }
    if (size.present) {
      map['size'] = Variable<double>(size.value);
    }
    if (workAreaId.present) {
      map['work_area_id'] = Variable<String>(workAreaId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('LocalPlotsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shape: $shape, ')
          ..write('centerLat: $centerLat, ')
          ..write('centerLng: $centerLng, ')
          ..write('size: $size, ')
          ..write('workAreaId: $workAreaId, ')
          ..write('description: $description, ')
          ..write('syncStatus: $syncStatus, ')
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
  late final $LocalWorkAreasTable localWorkAreas = $LocalWorkAreasTable(this);
  late final $LocalTreesTable localTrees = $LocalTreesTable(this);
  late final $LocalMapObjectsTable localMapObjects =
      $LocalMapObjectsTable(this);
  late final $LocalPlotsTable localPlots = $LocalPlotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localWorkAreas, localTrees, localMapObjects, localPlots];
}

typedef $$LocalWorkAreasTableCreateCompanionBuilder = LocalWorkAreasCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String boundary,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LocalWorkAreasTableUpdateCompanionBuilder = LocalWorkAreasCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> boundary,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$LocalWorkAreasTableReferences
    extends BaseReferences<_$AppDatabase, $LocalWorkAreasTable, LocalWorkArea> {
  $$LocalWorkAreasTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalTreesTable, List<LocalTree>>
      _localTreesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.localTrees,
              aliasName: $_aliasNameGenerator(
                  db.localWorkAreas.id, db.localTrees.workAreaId));

  $$LocalTreesTableProcessedTableManager get localTreesRefs {
    final manager = $$LocalTreesTableTableManager($_db, $_db.localTrees)
        .filter((f) => f.workAreaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localTreesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LocalMapObjectsTable, List<LocalMapObject>>
      _localMapObjectsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.localMapObjects,
              aliasName: $_aliasNameGenerator(
                  db.localWorkAreas.id, db.localMapObjects.workAreaId));

  $$LocalMapObjectsTableProcessedTableManager get localMapObjectsRefs {
    final manager = $$LocalMapObjectsTableTableManager(
            $_db, $_db.localMapObjects)
        .filter((f) => f.workAreaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_localMapObjectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LocalPlotsTable, List<LocalPlot>>
      _localPlotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.localPlots,
              aliasName: $_aliasNameGenerator(
                  db.localWorkAreas.id, db.localPlots.workAreaId));

  $$LocalPlotsTableProcessedTableManager get localPlotsRefs {
    final manager = $$LocalPlotsTableTableManager($_db, $_db.localPlots)
        .filter((f) => f.workAreaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localPlotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocalWorkAreasTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWorkAreasTable> {
  $$LocalWorkAreasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boundary => $composableBuilder(
      column: $table.boundary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> localTreesRefs(
      Expression<bool> Function($$LocalTreesTableFilterComposer f) f) {
    final $$LocalTreesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localTrees,
        getReferencedColumn: (t) => t.workAreaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalTreesTableFilterComposer(
              $db: $db,
              $table: $db.localTrees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> localMapObjectsRefs(
      Expression<bool> Function($$LocalMapObjectsTableFilterComposer f) f) {
    final $$LocalMapObjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localMapObjects,
        getReferencedColumn: (t) => t.workAreaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalMapObjectsTableFilterComposer(
              $db: $db,
              $table: $db.localMapObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> localPlotsRefs(
      Expression<bool> Function($$LocalPlotsTableFilterComposer f) f) {
    final $$LocalPlotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localPlots,
        getReferencedColumn: (t) => t.workAreaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalPlotsTableFilterComposer(
              $db: $db,
              $table: $db.localPlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalWorkAreasTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWorkAreasTable> {
  $$LocalWorkAreasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boundary => $composableBuilder(
      column: $table.boundary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalWorkAreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWorkAreasTable> {
  $$LocalWorkAreasTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get boundary =>
      $composableBuilder(column: $table.boundary, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> localTreesRefs<T extends Object>(
      Expression<T> Function($$LocalTreesTableAnnotationComposer a) f) {
    final $$LocalTreesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localTrees,
        getReferencedColumn: (t) => t.workAreaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalTreesTableAnnotationComposer(
              $db: $db,
              $table: $db.localTrees,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> localMapObjectsRefs<T extends Object>(
      Expression<T> Function($$LocalMapObjectsTableAnnotationComposer a) f) {
    final $$LocalMapObjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localMapObjects,
        getReferencedColumn: (t) => t.workAreaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalMapObjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.localMapObjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> localPlotsRefs<T extends Object>(
      Expression<T> Function($$LocalPlotsTableAnnotationComposer a) f) {
    final $$LocalPlotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localPlots,
        getReferencedColumn: (t) => t.workAreaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalPlotsTableAnnotationComposer(
              $db: $db,
              $table: $db.localPlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalWorkAreasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalWorkAreasTable,
    LocalWorkArea,
    $$LocalWorkAreasTableFilterComposer,
    $$LocalWorkAreasTableOrderingComposer,
    $$LocalWorkAreasTableAnnotationComposer,
    $$LocalWorkAreasTableCreateCompanionBuilder,
    $$LocalWorkAreasTableUpdateCompanionBuilder,
    (LocalWorkArea, $$LocalWorkAreasTableReferences),
    LocalWorkArea,
    PrefetchHooks Function(
        {bool localTreesRefs, bool localMapObjectsRefs, bool localPlotsRefs})> {
  $$LocalWorkAreasTableTableManager(
      _$AppDatabase db, $LocalWorkAreasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWorkAreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWorkAreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalWorkAreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> boundary = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalWorkAreasCompanion(
            id: id,
            name: name,
            description: description,
            boundary: boundary,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String boundary,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalWorkAreasCompanion.insert(
            id: id,
            name: name,
            description: description,
            boundary: boundary,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalWorkAreasTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {localTreesRefs = false,
              localMapObjectsRefs = false,
              localPlotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localTreesRefs) db.localTrees,
                if (localMapObjectsRefs) db.localMapObjects,
                if (localPlotsRefs) db.localPlots
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localTreesRefs)
                    await $_getPrefetchedData<LocalWorkArea,
                            $LocalWorkAreasTable, LocalTree>(
                        currentTable: table,
                        referencedTable: $$LocalWorkAreasTableReferences
                            ._localTreesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalWorkAreasTableReferences(db, table, p0)
                                .localTreesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workAreaId == item.id),
                        typedResults: items),
                  if (localMapObjectsRefs)
                    await $_getPrefetchedData<LocalWorkArea,
                            $LocalWorkAreasTable, LocalMapObject>(
                        currentTable: table,
                        referencedTable: $$LocalWorkAreasTableReferences
                            ._localMapObjectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalWorkAreasTableReferences(db, table, p0)
                                .localMapObjectsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workAreaId == item.id),
                        typedResults: items),
                  if (localPlotsRefs)
                    await $_getPrefetchedData<LocalWorkArea,
                            $LocalWorkAreasTable, LocalPlot>(
                        currentTable: table,
                        referencedTable: $$LocalWorkAreasTableReferences
                            ._localPlotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalWorkAreasTableReferences(db, table, p0)
                                .localPlotsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workAreaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocalWorkAreasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalWorkAreasTable,
    LocalWorkArea,
    $$LocalWorkAreasTableFilterComposer,
    $$LocalWorkAreasTableOrderingComposer,
    $$LocalWorkAreasTableAnnotationComposer,
    $$LocalWorkAreasTableCreateCompanionBuilder,
    $$LocalWorkAreasTableUpdateCompanionBuilder,
    (LocalWorkArea, $$LocalWorkAreasTableReferences),
    LocalWorkArea,
    PrefetchHooks Function(
        {bool localTreesRefs, bool localMapObjectsRefs, bool localPlotsRefs})>;
typedef $$LocalTreesTableCreateCompanionBuilder = LocalTreesCompanion Function({
  required String id,
  required String species,
  Value<double?> height,
  Value<double?> diameter,
  Value<String?> healthStatus,
  required String location,
  required String workAreaId,
  Value<String?> plotId,
  Value<String?> photoUrl,
  Value<String?> photoPath,
  Value<double?> volume,
  Value<int?> age,
  Value<String?> forestSection,
  Value<String?> subSection,
  Value<String?> treeNumber,
  Value<String?> vigor,
  Value<String?> pestDisease,
  Value<double?> slope,
  Value<String?> aspect,
  Value<String?> notes,
  Value<bool> markedForThinning,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LocalTreesTableUpdateCompanionBuilder = LocalTreesCompanion Function({
  Value<String> id,
  Value<String> species,
  Value<double?> height,
  Value<double?> diameter,
  Value<String?> healthStatus,
  Value<String> location,
  Value<String> workAreaId,
  Value<String?> plotId,
  Value<String?> photoUrl,
  Value<String?> photoPath,
  Value<double?> volume,
  Value<int?> age,
  Value<String?> forestSection,
  Value<String?> subSection,
  Value<String?> treeNumber,
  Value<String?> vigor,
  Value<String?> pestDisease,
  Value<double?> slope,
  Value<String?> aspect,
  Value<String?> notes,
  Value<bool> markedForThinning,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$LocalTreesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalTreesTable, LocalTree> {
  $$LocalTreesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalWorkAreasTable _workAreaIdTable(_$AppDatabase db) =>
      db.localWorkAreas.createAlias(
          $_aliasNameGenerator(db.localTrees.workAreaId, db.localWorkAreas.id));

  $$LocalWorkAreasTableProcessedTableManager get workAreaId {
    final $_column = $_itemColumn<String>('work_area_id')!;

    final manager = $$LocalWorkAreasTableTableManager($_db, $_db.localWorkAreas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workAreaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalTreesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTreesTable> {
  $$LocalTreesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get diameter => $composableBuilder(
      column: $table.diameter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plotId => $composableBuilder(
      column: $table.plotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get forestSection => $composableBuilder(
      column: $table.forestSection, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subSection => $composableBuilder(
      column: $table.subSection, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treeNumber => $composableBuilder(
      column: $table.treeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vigor => $composableBuilder(
      column: $table.vigor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pestDisease => $composableBuilder(
      column: $table.pestDisease, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get slope => $composableBuilder(
      column: $table.slope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aspect => $composableBuilder(
      column: $table.aspect, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get markedForThinning => $composableBuilder(
      column: $table.markedForThinning,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$LocalWorkAreasTableFilterComposer get workAreaId {
    final $$LocalWorkAreasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableFilterComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalTreesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTreesTable> {
  $$LocalTreesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get diameter => $composableBuilder(
      column: $table.diameter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get healthStatus => $composableBuilder(
      column: $table.healthStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plotId => $composableBuilder(
      column: $table.plotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get forestSection => $composableBuilder(
      column: $table.forestSection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subSection => $composableBuilder(
      column: $table.subSection, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treeNumber => $composableBuilder(
      column: $table.treeNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vigor => $composableBuilder(
      column: $table.vigor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pestDisease => $composableBuilder(
      column: $table.pestDisease, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get slope => $composableBuilder(
      column: $table.slope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aspect => $composableBuilder(
      column: $table.aspect, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get markedForThinning => $composableBuilder(
      column: $table.markedForThinning,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$LocalWorkAreasTableOrderingComposer get workAreaId {
    final $$LocalWorkAreasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableOrderingComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalTreesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTreesTable> {
  $$LocalTreesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get diameter =>
      $composableBuilder(column: $table.diameter, builder: (column) => column);

  GeneratedColumn<String> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get forestSection => $composableBuilder(
      column: $table.forestSection, builder: (column) => column);

  GeneratedColumn<String> get subSection => $composableBuilder(
      column: $table.subSection, builder: (column) => column);

  GeneratedColumn<String> get treeNumber => $composableBuilder(
      column: $table.treeNumber, builder: (column) => column);

  GeneratedColumn<String> get vigor =>
      $composableBuilder(column: $table.vigor, builder: (column) => column);

  GeneratedColumn<String> get pestDisease => $composableBuilder(
      column: $table.pestDisease, builder: (column) => column);

  GeneratedColumn<double> get slope =>
      $composableBuilder(column: $table.slope, builder: (column) => column);

  GeneratedColumn<String> get aspect =>
      $composableBuilder(column: $table.aspect, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get markedForThinning => $composableBuilder(
      column: $table.markedForThinning, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalWorkAreasTableAnnotationComposer get workAreaId {
    final $$LocalWorkAreasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableAnnotationComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalTreesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalTreesTable,
    LocalTree,
    $$LocalTreesTableFilterComposer,
    $$LocalTreesTableOrderingComposer,
    $$LocalTreesTableAnnotationComposer,
    $$LocalTreesTableCreateCompanionBuilder,
    $$LocalTreesTableUpdateCompanionBuilder,
    (LocalTree, $$LocalTreesTableReferences),
    LocalTree,
    PrefetchHooks Function({bool workAreaId})> {
  $$LocalTreesTableTableManager(_$AppDatabase db, $LocalTreesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTreesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTreesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTreesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<double?> height = const Value.absent(),
            Value<double?> diameter = const Value.absent(),
            Value<String?> healthStatus = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String> workAreaId = const Value.absent(),
            Value<String?> plotId = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<double?> volume = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<String?> forestSection = const Value.absent(),
            Value<String?> subSection = const Value.absent(),
            Value<String?> treeNumber = const Value.absent(),
            Value<String?> vigor = const Value.absent(),
            Value<String?> pestDisease = const Value.absent(),
            Value<double?> slope = const Value.absent(),
            Value<String?> aspect = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> markedForThinning = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTreesCompanion(
            id: id,
            species: species,
            height: height,
            diameter: diameter,
            healthStatus: healthStatus,
            location: location,
            workAreaId: workAreaId,
            plotId: plotId,
            photoUrl: photoUrl,
            photoPath: photoPath,
            volume: volume,
            age: age,
            forestSection: forestSection,
            subSection: subSection,
            treeNumber: treeNumber,
            vigor: vigor,
            pestDisease: pestDisease,
            slope: slope,
            aspect: aspect,
            notes: notes,
            markedForThinning: markedForThinning,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String species,
            Value<double?> height = const Value.absent(),
            Value<double?> diameter = const Value.absent(),
            Value<String?> healthStatus = const Value.absent(),
            required String location,
            required String workAreaId,
            Value<String?> plotId = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<double?> volume = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<String?> forestSection = const Value.absent(),
            Value<String?> subSection = const Value.absent(),
            Value<String?> treeNumber = const Value.absent(),
            Value<String?> vigor = const Value.absent(),
            Value<String?> pestDisease = const Value.absent(),
            Value<double?> slope = const Value.absent(),
            Value<String?> aspect = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> markedForThinning = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTreesCompanion.insert(
            id: id,
            species: species,
            height: height,
            diameter: diameter,
            healthStatus: healthStatus,
            location: location,
            workAreaId: workAreaId,
            plotId: plotId,
            photoUrl: photoUrl,
            photoPath: photoPath,
            volume: volume,
            age: age,
            forestSection: forestSection,
            subSection: subSection,
            treeNumber: treeNumber,
            vigor: vigor,
            pestDisease: pestDisease,
            slope: slope,
            aspect: aspect,
            notes: notes,
            markedForThinning: markedForThinning,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalTreesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workAreaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (workAreaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workAreaId,
                    referencedTable:
                        $$LocalTreesTableReferences._workAreaIdTable(db),
                    referencedColumn:
                        $$LocalTreesTableReferences._workAreaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LocalTreesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalTreesTable,
    LocalTree,
    $$LocalTreesTableFilterComposer,
    $$LocalTreesTableOrderingComposer,
    $$LocalTreesTableAnnotationComposer,
    $$LocalTreesTableCreateCompanionBuilder,
    $$LocalTreesTableUpdateCompanionBuilder,
    (LocalTree, $$LocalTreesTableReferences),
    LocalTree,
    PrefetchHooks Function({bool workAreaId})>;
typedef $$LocalMapObjectsTableCreateCompanionBuilder = LocalMapObjectsCompanion
    Function({
  required String id,
  required String type,
  required String geometry,
  Value<String?> name,
  Value<String?> description,
  required String workAreaId,
  Value<String?> photoPath,
  Value<String?> attributes,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LocalMapObjectsTableUpdateCompanionBuilder = LocalMapObjectsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> geometry,
  Value<String?> name,
  Value<String?> description,
  Value<String> workAreaId,
  Value<String?> photoPath,
  Value<String?> attributes,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$LocalMapObjectsTableReferences extends BaseReferences<
    _$AppDatabase, $LocalMapObjectsTable, LocalMapObject> {
  $$LocalMapObjectsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LocalWorkAreasTable _workAreaIdTable(_$AppDatabase db) =>
      db.localWorkAreas.createAlias($_aliasNameGenerator(
          db.localMapObjects.workAreaId, db.localWorkAreas.id));

  $$LocalWorkAreasTableProcessedTableManager get workAreaId {
    final $_column = $_itemColumn<String>('work_area_id')!;

    final manager = $$LocalWorkAreasTableTableManager($_db, $_db.localWorkAreas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workAreaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalMapObjectsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMapObjectsTable> {
  $$LocalMapObjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geometry => $composableBuilder(
      column: $table.geometry, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributes => $composableBuilder(
      column: $table.attributes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$LocalWorkAreasTableFilterComposer get workAreaId {
    final $$LocalWorkAreasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableFilterComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalMapObjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMapObjectsTable> {
  $$LocalMapObjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geometry => $composableBuilder(
      column: $table.geometry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributes => $composableBuilder(
      column: $table.attributes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$LocalWorkAreasTableOrderingComposer get workAreaId {
    final $$LocalWorkAreasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableOrderingComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalMapObjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMapObjectsTable> {
  $$LocalMapObjectsTableAnnotationComposer({
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

  GeneratedColumn<String> get geometry =>
      $composableBuilder(column: $table.geometry, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get attributes => $composableBuilder(
      column: $table.attributes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalWorkAreasTableAnnotationComposer get workAreaId {
    final $$LocalWorkAreasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableAnnotationComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalMapObjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMapObjectsTable,
    LocalMapObject,
    $$LocalMapObjectsTableFilterComposer,
    $$LocalMapObjectsTableOrderingComposer,
    $$LocalMapObjectsTableAnnotationComposer,
    $$LocalMapObjectsTableCreateCompanionBuilder,
    $$LocalMapObjectsTableUpdateCompanionBuilder,
    (LocalMapObject, $$LocalMapObjectsTableReferences),
    LocalMapObject,
    PrefetchHooks Function({bool workAreaId})> {
  $$LocalMapObjectsTableTableManager(
      _$AppDatabase db, $LocalMapObjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMapObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMapObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMapObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> geometry = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> workAreaId = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> attributes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMapObjectsCompanion(
            id: id,
            type: type,
            geometry: geometry,
            name: name,
            description: description,
            workAreaId: workAreaId,
            photoPath: photoPath,
            attributes: attributes,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String geometry,
            Value<String?> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required String workAreaId,
            Value<String?> photoPath = const Value.absent(),
            Value<String?> attributes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMapObjectsCompanion.insert(
            id: id,
            type: type,
            geometry: geometry,
            name: name,
            description: description,
            workAreaId: workAreaId,
            photoPath: photoPath,
            attributes: attributes,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalMapObjectsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workAreaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (workAreaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workAreaId,
                    referencedTable:
                        $$LocalMapObjectsTableReferences._workAreaIdTable(db),
                    referencedColumn: $$LocalMapObjectsTableReferences
                        ._workAreaIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LocalMapObjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalMapObjectsTable,
    LocalMapObject,
    $$LocalMapObjectsTableFilterComposer,
    $$LocalMapObjectsTableOrderingComposer,
    $$LocalMapObjectsTableAnnotationComposer,
    $$LocalMapObjectsTableCreateCompanionBuilder,
    $$LocalMapObjectsTableUpdateCompanionBuilder,
    (LocalMapObject, $$LocalMapObjectsTableReferences),
    LocalMapObject,
    PrefetchHooks Function({bool workAreaId})>;
typedef $$LocalPlotsTableCreateCompanionBuilder = LocalPlotsCompanion Function({
  required String id,
  required String name,
  required String shape,
  required double centerLat,
  required double centerLng,
  required double size,
  required String workAreaId,
  Value<String?> description,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LocalPlotsTableUpdateCompanionBuilder = LocalPlotsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> shape,
  Value<double> centerLat,
  Value<double> centerLng,
  Value<double> size,
  Value<String> workAreaId,
  Value<String?> description,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$LocalPlotsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalPlotsTable, LocalPlot> {
  $$LocalPlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalWorkAreasTable _workAreaIdTable(_$AppDatabase db) =>
      db.localWorkAreas.createAlias(
          $_aliasNameGenerator(db.localPlots.workAreaId, db.localWorkAreas.id));

  $$LocalWorkAreasTableProcessedTableManager get workAreaId {
    final $_column = $_itemColumn<String>('work_area_id')!;

    final manager = $$LocalWorkAreasTableTableManager($_db, $_db.localWorkAreas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workAreaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalPlotsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlotsTable> {
  $$LocalPlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shape => $composableBuilder(
      column: $table.shape, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get centerLat => $composableBuilder(
      column: $table.centerLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get centerLng => $composableBuilder(
      column: $table.centerLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$LocalWorkAreasTableFilterComposer get workAreaId {
    final $$LocalWorkAreasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableFilterComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalPlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlotsTable> {
  $$LocalPlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shape => $composableBuilder(
      column: $table.shape, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get centerLat => $composableBuilder(
      column: $table.centerLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get centerLng => $composableBuilder(
      column: $table.centerLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$LocalWorkAreasTableOrderingComposer get workAreaId {
    final $$LocalWorkAreasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableOrderingComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalPlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlotsTable> {
  $$LocalPlotsTableAnnotationComposer({
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

  GeneratedColumn<String> get shape =>
      $composableBuilder(column: $table.shape, builder: (column) => column);

  GeneratedColumn<double> get centerLat =>
      $composableBuilder(column: $table.centerLat, builder: (column) => column);

  GeneratedColumn<double> get centerLng =>
      $composableBuilder(column: $table.centerLng, builder: (column) => column);

  GeneratedColumn<double> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalWorkAreasTableAnnotationComposer get workAreaId {
    final $$LocalWorkAreasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workAreaId,
        referencedTable: $db.localWorkAreas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalWorkAreasTableAnnotationComposer(
              $db: $db,
              $table: $db.localWorkAreas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalPlotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalPlotsTable,
    LocalPlot,
    $$LocalPlotsTableFilterComposer,
    $$LocalPlotsTableOrderingComposer,
    $$LocalPlotsTableAnnotationComposer,
    $$LocalPlotsTableCreateCompanionBuilder,
    $$LocalPlotsTableUpdateCompanionBuilder,
    (LocalPlot, $$LocalPlotsTableReferences),
    LocalPlot,
    PrefetchHooks Function({bool workAreaId})> {
  $$LocalPlotsTableTableManager(_$AppDatabase db, $LocalPlotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> shape = const Value.absent(),
            Value<double> centerLat = const Value.absent(),
            Value<double> centerLng = const Value.absent(),
            Value<double> size = const Value.absent(),
            Value<String> workAreaId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPlotsCompanion(
            id: id,
            name: name,
            shape: shape,
            centerLat: centerLat,
            centerLng: centerLng,
            size: size,
            workAreaId: workAreaId,
            description: description,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String shape,
            required double centerLat,
            required double centerLng,
            required double size,
            required String workAreaId,
            Value<String?> description = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPlotsCompanion.insert(
            id: id,
            name: name,
            shape: shape,
            centerLat: centerLat,
            centerLng: centerLng,
            size: size,
            workAreaId: workAreaId,
            description: description,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalPlotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workAreaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (workAreaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workAreaId,
                    referencedTable:
                        $$LocalPlotsTableReferences._workAreaIdTable(db),
                    referencedColumn:
                        $$LocalPlotsTableReferences._workAreaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LocalPlotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalPlotsTable,
    LocalPlot,
    $$LocalPlotsTableFilterComposer,
    $$LocalPlotsTableOrderingComposer,
    $$LocalPlotsTableAnnotationComposer,
    $$LocalPlotsTableCreateCompanionBuilder,
    $$LocalPlotsTableUpdateCompanionBuilder,
    (LocalPlot, $$LocalPlotsTableReferences),
    LocalPlot,
    PrefetchHooks Function({bool workAreaId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalWorkAreasTableTableManager get localWorkAreas =>
      $$LocalWorkAreasTableTableManager(_db, _db.localWorkAreas);
  $$LocalTreesTableTableManager get localTrees =>
      $$LocalTreesTableTableManager(_db, _db.localTrees);
  $$LocalMapObjectsTableTableManager get localMapObjects =>
      $$LocalMapObjectsTableTableManager(_db, _db.localMapObjects);
  $$LocalPlotsTableTableManager get localPlots =>
      $$LocalPlotsTableTableManager(_db, _db.localPlots);
}

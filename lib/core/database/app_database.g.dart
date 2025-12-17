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
        photoUrl,
        photoPath,
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
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
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
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
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
  final String? photoUrl;
  final String? photoPath;
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
      this.photoUrl,
      this.photoPath,
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
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
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
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
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
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
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
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'photoPath': serializer.toJson<String?>(photoPath),
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
          Value<String?> photoUrl = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
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
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
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
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
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
          ..write('photoUrl: $photoUrl, ')
          ..write('photoPath: $photoPath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, species, height, diameter, healthStatus,
      location, workAreaId, photoUrl, photoPath, syncStatus, updatedAt);
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
          other.photoUrl == this.photoUrl &&
          other.photoPath == this.photoPath &&
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
  final Value<String?> photoUrl;
  final Value<String?> photoPath;
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
    this.photoUrl = const Value.absent(),
    this.photoPath = const Value.absent(),
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
    this.photoUrl = const Value.absent(),
    this.photoPath = const Value.absent(),
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
    Expression<String>? photoUrl,
    Expression<String>? photoPath,
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
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoPath != null) 'photo_path': photoPath,
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
      Value<String?>? photoUrl,
      Value<String?>? photoPath,
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
      photoUrl: photoUrl ?? this.photoUrl,
      photoPath: photoPath ?? this.photoPath,
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
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
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
          ..write('photoUrl: $photoUrl, ')
          ..write('photoPath: $photoPath, ')
          ..write('syncStatus: $syncStatus, ')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localWorkAreas, localTrees];
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
    PrefetchHooks Function({bool localTreesRefs})> {
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
          prefetchHooksCallback: ({localTreesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (localTreesRefs) db.localTrees],
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
    PrefetchHooks Function({bool localTreesRefs})>;
typedef $$LocalTreesTableCreateCompanionBuilder = LocalTreesCompanion Function({
  required String id,
  required String species,
  Value<double?> height,
  Value<double?> diameter,
  Value<String?> healthStatus,
  required String location,
  required String workAreaId,
  Value<String?> photoUrl,
  Value<String?> photoPath,
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
  Value<String?> photoUrl,
  Value<String?> photoPath,
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

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

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
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
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
            photoUrl: photoUrl,
            photoPath: photoPath,
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
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
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
            photoUrl: photoUrl,
            photoPath: photoPath,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalWorkAreasTableTableManager get localWorkAreas =>
      $$LocalWorkAreasTableTableManager(_db, _db.localWorkAreas);
  $$LocalTreesTableTableManager get localTrees =>
      $$LocalTreesTableTableManager(_db, _db.localTrees);
}

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../domain/models/map_object.dart';
import '../../offline/data/sync_repository.dart';

final mapObjectRepositoryProvider = Provider<MapObjectRepository>((ref) {
  return MapObjectRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncRepositoryProvider),
  );
});

class MapObjectRepository {
  final AppDatabase _db;
  final SyncRepository _sync;

  MapObjectRepository(this._db, this._sync);

  Future<List<MapObject>> getMapObjects(String workAreaId) async {
    final localObjects = await (_db.select(_db.localMapObjects)
          ..where((t) => t.workAreaId.equals(workAreaId))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();

    return localObjects.map((t) => MapObject(
      id: t.id,
      type: MapObjectType.values.firstWhere((e) => e.name == t.type, orElse: () => MapObjectType.point),
      geometry: t.geometry,
      name: t.name,
      description: t.description,
      photoPath: t.photoPath,
      attributes: t.attributes != null ? jsonDecode(t.attributes!) : null,
      workAreaId: t.workAreaId,
      syncStatus: t.syncStatus,
      updatedAt: t.updatedAt,
    )).toList();
  }

  Future<void> createMapObject({
    required MapObjectType type,
    required String geometry,
    String? name,
    String? description,
    String? photoPath,
    Map<String, dynamic>? attributes,
    required String workAreaId,
  }) async {
    final id = const Uuid().v4();

    // Insert to local DB as dirty
    await _db.into(_db.localMapObjects).insert(LocalMapObjectsCompanion.insert(
      id: id,
      type: type.name,
      geometry: geometry,
      name: Value(name),
      description: Value(description),
      photoPath: Value(photoPath),
      attributes: Value(attributes != null ? jsonEncode(attributes) : null),
      workAreaId: workAreaId,
      syncStatus: const Value('dirty'),
      updatedAt: Value(DateTime.now()),
    ));

    // Trigger sync
    _sync.syncPush();
  }

  /// Get a single MapObject by ID
  Future<MapObject?> getMapObjectById(String id) async {
    final local = await (_db.select(_db.localMapObjects)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (local == null) return null;

    return MapObject(
      id: local.id,
      type: MapObjectType.values.firstWhere((e) => e.name == local.type, orElse: () => MapObjectType.point),
      geometry: local.geometry,
      name: local.name,
      description: local.description,
      photoPath: local.photoPath,
      attributes: local.attributes != null ? jsonDecode(local.attributes!) : null,
      workAreaId: local.workAreaId,
      syncStatus: local.syncStatus,
      updatedAt: local.updatedAt,
    );
  }

  /// Update an existing MapObject
  Future<void> updateMapObject({
    required String id,
    String? name,
    String? description,
    String? photoPath,
    Map<String, dynamic>? attributes,
  }) async {
    await (_db.update(_db.localMapObjects)..where((t) => t.id.equals(id))).write(
      LocalMapObjectsCompanion(
        name: Value(name),
        description: Value(description),
        photoPath: Value(photoPath),
        attributes: Value(attributes != null ? jsonEncode(attributes) : null),
        syncStatus: const Value('dirty'),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Trigger sync
    _sync.syncPush();
  }

  /// Delete a MapObject (soft delete for sync)
  Future<void> deleteMapObject(String id) async {
    await (_db.update(_db.localMapObjects)..where((t) => t.id.equals(id))).write(
      LocalMapObjectsCompanion(
        syncStatus: const Value('deleted'),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Trigger sync
    _sync.syncPush();
  }

  /// Hard delete a MapObject (local only, for cleanup)
  Future<void> hardDeleteMapObject(String id) async {
    await (_db.delete(_db.localMapObjects)..where((t) => t.id.equals(id))).go();
  }
}

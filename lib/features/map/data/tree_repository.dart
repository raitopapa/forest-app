import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../offline/data/sync_repository.dart';

final treeRepositoryProvider = Provider<TreeRepository>((ref) {
  return TreeRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncRepositoryProvider),
  );
});

class TreeRepository {
  final AppDatabase _db;
  final SyncRepository _sync;

  TreeRepository(this._db, this._sync);

  Future<List<Map<String, dynamic>>> getTrees(String workAreaId) async {
    // Read from local DB
    final trees = await (_db.select(_db.localTrees)
          ..where((t) => t.workAreaId.equals(workAreaId))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();

    return trees.map((t) => {
      'id': t.id,
      'species': t.species,
      'height': t.height,
      'diameter': t.diameter,
      'health_status': t.healthStatus,
      'location': t.location,
      'work_area_id': t.workAreaId,
      'photo_url': t.photoUrl,
      'photo_path': t.photoPath,
    }).toList();
  }

  Future<void> createTree({
    required String species,
    double? height,
    double? diameter,
    String? healthStatus,
    required double lat,
    required double lng,
    required String workAreaId,
    String? photoPath,
    // 新規フィールド
    double? volume,
    int? age,
    String? forestSection,
    String? subSection,
    String? treeNumber,
    String? vigor,
    String? pestDisease,
    double? slope,
    String? aspect,
    String? notes,
    bool markedForThinning = false,
  }) async {
    // PostGIS format: POINT(lng lat)
    final wkt = 'POINT($lng $lat)';
    final id = const Uuid().v4();

    // 材積の自動計算（指定がない場合）
    double? calculatedVolume = volume;
    if (calculatedVolume == null && height != null && diameter != null) {
      calculatedVolume = 0.000045 * diameter * diameter * height;
    }

    // Insert to local DB as dirty
    await _db.into(_db.localTrees).insert(LocalTreesCompanion.insert(
      id: id,
      species: species,
      height: Value(height),
      diameter: Value(diameter),
      healthStatus: Value(healthStatus),
      location: wkt,
      workAreaId: workAreaId,
      photoPath: Value(photoPath),
      volume: Value(calculatedVolume),
      age: Value(age),
      forestSection: Value(forestSection),
      subSection: Value(subSection),
      treeNumber: Value(treeNumber),
      vigor: Value(vigor),
      pestDisease: Value(pestDisease),
      slope: Value(slope),
      aspect: Value(aspect),
      notes: Value(notes),
      markedForThinning: Value(markedForThinning),
      syncStatus: const Value('dirty'),
      updatedAt: Value(DateTime.now()),
    ));

    // Trigger sync
    _sync.syncPush();
  }

  /// 樹木データを更新
  Future<void> updateTree({
    required String id,
    String? species,
    double? height,
    double? diameter,
    String? healthStatus,
    String? photoPath,
    double? volume,
    int? age,
    String? forestSection,
    String? subSection,
    String? treeNumber,
    String? vigor,
    String? pestDisease,
    double? slope,
    String? aspect,
    String? notes,
    bool? markedForThinning,
  }) async {
    // 材積の自動計算（指定がない場合）
    double? calculatedVolume = volume;
    if (calculatedVolume == null && height != null && diameter != null) {
      calculatedVolume = 0.000045 * diameter * diameter * height;
    }

    await (_db.update(_db.localTrees)..where((t) => t.id.equals(id))).write(
      LocalTreesCompanion(
        species: species != null ? Value(species) : const Value.absent(),
        height: Value(height),
        diameter: Value(diameter),
        healthStatus: Value(healthStatus),
        photoPath: Value(photoPath),
        volume: Value(calculatedVolume),
        age: Value(age),
        forestSection: Value(forestSection),
        subSection: Value(subSection),
        treeNumber: Value(treeNumber),
        vigor: Value(vigor),
        pestDisease: Value(pestDisease),
        slope: Value(slope),
        aspect: Value(aspect),
        notes: Value(notes),
        markedForThinning: markedForThinning != null ? Value(markedForThinning) : const Value.absent(),
        syncStatus: const Value('dirty'),
        updatedAt: Value(DateTime.now()),
      ),
    );

    _sync.syncPush();
  }

  /// 樹木を削除
  Future<void> deleteTree(String id) async {
    await (_db.delete(_db.localTrees)..where((t) => t.id.equals(id))).go();
    _sync.syncPush();
  }
}

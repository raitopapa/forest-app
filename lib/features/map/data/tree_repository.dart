import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../offline/data/sync_repository.dart';

final treeRepositoryProvider = Provider<TreeRepository>((ref) {
  return TreeRepository(
    Supabase.instance.client,
    ref.watch(appDatabaseProvider),
    ref.watch(syncRepositoryProvider),
  );
});

class TreeRepository {
  final SupabaseClient _client;
  final AppDatabase _db;
  final SyncRepository _sync;

  TreeRepository(this._client, this._db, this._sync);

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
  }) async {
    // PostGIS format: POINT(lng lat)
    final wkt = 'POINT($lng $lat)';
    final id = const Uuid().v4();

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
      syncStatus: const Value('dirty'),
      updatedAt: Value(DateTime.now()),
    ));

    // Trigger sync
    _sync.syncPush();
  }
}

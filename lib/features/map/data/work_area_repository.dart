import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../offline/data/sync_repository.dart';

final workAreaRepositoryProvider = Provider<WorkAreaRepository>((ref) {
  return WorkAreaRepository(
    Supabase.instance.client,
    ref.watch(appDatabaseProvider),
    ref.watch(syncRepositoryProvider),
  );
});

class WorkAreaRepository {
  final SupabaseClient _client;
  final AppDatabase _db;
  final SyncRepository _sync;

  WorkAreaRepository(this._client, this._db, this._sync);

  Future<List<Map<String, dynamic>>> getWorkAreas() async {
    // Read from local DB
    final areas = await (_db.select(_db.localWorkAreas)
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();

    return areas.map((a) => {
      'id': a.id,
      'name': a.name,
      'description': a.description,
      'boundary': a.boundary,
    }).toList();
  }

  Future<void> createWorkArea({
    required String name,
    String? description,
    required List<List<double>> points, // [[lat, lng], ...]
  }) async {
    if (points.isEmpty) return;

    // Close the loop if not closed
    final ring = List<List<double>>.from(points);
    if (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1]) {
      ring.add(ring.first);
    }

    final coordinates = ring.map((p) => '${p[1]} ${p[0]}').join(',');
    final wkt = 'POLYGON(($coordinates))';
    final id = const Uuid().v4();

    // Insert to local DB as dirty
    await _db.into(_db.localWorkAreas).insert(LocalWorkAreasCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      boundary: wkt,
      syncStatus: const Value('dirty'),
      updatedAt: Value(DateTime.now()),
    ));

    // Trigger sync
    _sync.syncPush();
  }
}

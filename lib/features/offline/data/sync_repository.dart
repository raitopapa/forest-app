import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../../../core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    Supabase.instance.client,
    ref.watch(appDatabaseProvider),
  );
});

class SyncRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  SyncRepository(this._supabase, this._db);

  Future<void> syncPull() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Pull Work Areas
    final remoteAreas = await _supabase
        .from('work_areas')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    for (final remote in remoteAreas) {
      final id = remote['id'] as String;
      final local = await (_db.select(_db.localWorkAreas)..where((t) => t.id.equals(id))).getSingleOrNull();

      if (local != null && local.syncStatus != 'synced') {
        continue; // Skip if local has unsynced changes
      }

      final companion = LocalWorkAreasCompanion.insert(
        id: id,
        name: remote['name'],
        description: Value(remote['description']),
        boundary: remote['boundary'], // Assuming WKT
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.parse(remote['updated_at'])),
      );

      await _db.into(_db.localWorkAreas).insertOnConflictUpdate(companion);
    }

    // 2. Pull Trees
    final remoteTrees = await _supabase
        .from('trees')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    for (final remote in remoteTrees) {
      final id = remote['id'] as String;
      final local = await (_db.select(_db.localTrees)..where((t) => t.id.equals(id))).getSingleOrNull();

      if (local != null && local.syncStatus != 'synced') {
        continue;
      }

      final companion = LocalTreesCompanion.insert(
        id: id,
        species: remote['species'],
        height: Value(remote['height'] != null ? (remote['height'] as num).toDouble() : null),
        diameter: Value(remote['diameter'] != null ? (remote['diameter'] as num).toDouble() : null),
        healthStatus: Value(remote['health_status']),
        location: remote['location'],
        workAreaId: remote['work_area_id'],
        photoUrl: Value(remote['photo_url']),
        syncStatus: const Value('synced'),
        updatedAt: Value(DateTime.parse(remote['updated_at'])),
      );

      await _db.into(_db.localTrees).insertOnConflictUpdate(companion);
    }
  }



  Future<void> syncPush() async {
    // 1. Push Work Areas
    final dirtyAreas = await (_db.select(_db.localWorkAreas)..where((t) => t.syncStatus.equals('dirty'))).get();
    for (final area in dirtyAreas) {
      await _supabase.from('work_areas').upsert({
        'id': area.id,
        'name': area.name,
        'description': area.description,
        'boundary': area.boundary,
        'updated_at': DateTime.now().toIso8601String(),
        'user_id': _supabase.auth.currentUser!.id,
      });
      
      await (_db.update(_db.localWorkAreas)..where((t) => t.id.equals(area.id))).write(
        const LocalWorkAreasCompanion(syncStatus: Value('synced')),
      );
    }

    // 2. Push Trees
    final dirtyTrees = await (_db.select(_db.localTrees)..where((t) => t.syncStatus.equals('dirty'))).get();
    for (final tree in dirtyTrees) {
      String? photoUrl = tree.photoUrl;

      // Upload photo if exists locally and not yet uploaded (or simple check if path exists)
      if (tree.photoPath != null && photoUrl == null) {
        final file = File(tree.photoPath!);
        if (await file.exists()) {
          final fileName = '${tree.id}_${DateTime.now().millisecondsSinceEpoch}${p.extension(tree.photoPath!)}';
          try {
            await _supabase.storage.from('photos').upload(fileName, file);
            photoUrl = _supabase.storage.from('photos').getPublicUrl(fileName);
            
            // Update local with the new URL
            await (_db.update(_db.localTrees)..where((t) => t.id.equals(tree.id))).write(
              LocalTreesCompanion(photoUrl: Value(photoUrl)),
            );
          } catch (e) {
            print('Photo upload failed: $e');
            // Continue syncing the tree data even if photo fails, or maybe retry later?
            // For now, we continue.
          }
        }
      }

      await _supabase.from('trees').upsert({
        'id': tree.id,
        'species': tree.species,
        'height': tree.height,
        'diameter': tree.diameter,
        'health_status': tree.healthStatus,
        'location': tree.location,
        'work_area_id': tree.workAreaId,
        'photo_url': photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
        'user_id': _supabase.auth.currentUser!.id,
      });

      await (_db.update(_db.localTrees)..where((t) => t.id.equals(tree.id))).write(
        const LocalTreesCompanion(syncStatus: Value('synced')),
      );
    }
  }
}

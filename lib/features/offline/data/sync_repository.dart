import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

/// Represents a sync conflict that was detected.
class SyncConflict {
  final String entityType; // 'work_area', 'tree', 'map_object'
  final String entityId;
  final DateTime localUpdatedAt;
  final DateTime remoteUpdatedAt;
  final String resolution; // 'local_kept', 'remote_accepted'
  final DateTime detectedAt;

  SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    required this.resolution,
    required this.detectedAt,
  });

  Map<String, dynamic> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'localUpdatedAt': localUpdatedAt.toIso8601String(),
    'remoteUpdatedAt': remoteUpdatedAt.toIso8601String(),
    'resolution': resolution,
    'detectedAt': detectedAt.toIso8601String(),
  };

  factory SyncConflict.fromJson(Map<String, dynamic> json) => SyncConflict(
    entityType: json['entityType'],
    entityId: json['entityId'],
    localUpdatedAt: DateTime.parse(json['localUpdatedAt']),
    remoteUpdatedAt: DateTime.parse(json['remoteUpdatedAt']),
    resolution: json['resolution'],
    detectedAt: DateTime.parse(json['detectedAt']),
  );
}


class SyncOverview {
  final int pendingWorkAreas;
  final int pendingTrees;
  final int conflictCount;
  final int retryQueueCount;

  const SyncOverview({
    required this.pendingWorkAreas,
    required this.pendingTrees,
    required this.conflictCount,
    required this.retryQueueCount,
  });

  int get totalPending => pendingWorkAreas + pendingTrees;
}

class SyncRetryTask {
  final String id;
  final String operation;
  final String reason;
  final DateTime createdAt;
  final int attempts;
  final DateTime? lastTriedAt;
  final DateTime? nextRetryAt;

  SyncRetryTask({
    required this.id,
    required this.operation,
    required this.reason,
    required this.createdAt,
    this.attempts = 0,
    this.lastTriedAt,
    this.nextRetryAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'operation': operation,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
    'attempts': attempts,
    'lastTriedAt': lastTriedAt?.toIso8601String(),
    'nextRetryAt': nextRetryAt?.toIso8601String(),
  };

  factory SyncRetryTask.fromJson(Map<String, dynamic> json) => SyncRetryTask(
    id: json['id'],
    operation: json['operation'],
    reason: json['reason'],
    createdAt: DateTime.parse(json['createdAt']),
    attempts: json['attempts'] ?? 0,
    lastTriedAt: json['lastTriedAt'] != null ? DateTime.parse(json['lastTriedAt']) : null,
    nextRetryAt: json['nextRetryAt'] != null ? DateTime.parse(json['nextRetryAt']) : null,
  );
}

class SyncRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;
  static const String _conflictsKey = 'sync_conflicts';
  static const String _lastSyncErrorKey = 'last_sync_error';
  static const String _lastSyncAtKey = 'last_sync_at';
  static const String _retryQueueKey = 'sync_retry_queue';
  static const int _maxRetryAttempts = 5;

  SyncRepository(this._supabase, this._db);

  /// Get logged conflicts.
  Future<List<SyncConflict>> getConflicts() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_conflictsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => SyncConflict.fromJson(e)).toList();
  }

  /// Clear conflict log.
  Future<void> clearConflicts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conflictsKey);
  }

  Future<void> removeConflict({
    required String entityType,
    required String entityId,
    DateTime? detectedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getConflicts();
    existing.removeWhere((c) {
      final sameEntity = c.entityType == entityType && c.entityId == entityId;
      if (!sameEntity) return false;
      if (detectedAt == null) return true;
      return c.detectedAt == detectedAt;
    });
    await prefs.setString(_conflictsKey, jsonEncode(existing.map((e) => e.toJson()).toList()));
  }

  Future<void> updateConflictResolution({
    required String entityType,
    required String entityId,
    required DateTime detectedAt,
    required String resolution,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getConflicts();
    final updated = existing.map((c) {
      if (c.entityType == entityType && c.entityId == entityId && c.detectedAt == detectedAt) {
        return SyncConflict(
          entityType: c.entityType,
          entityId: c.entityId,
          localUpdatedAt: c.localUpdatedAt,
          remoteUpdatedAt: c.remoteUpdatedAt,
          resolution: resolution,
          detectedAt: c.detectedAt,
        );
      }
      return c;
    }).toList();

    await prefs.setString(_conflictsKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  /// Log a conflict.
  Future<void> _logConflict(SyncConflict conflict) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getConflicts();
    existing.add(conflict);
    // Keep only last 50 conflicts
    if (existing.length > 50) {
      existing.removeRange(0, existing.length - 50);
    }
    await prefs.setString(_conflictsKey, jsonEncode(existing.map((e) => e.toJson()).toList()));
  }


  /// Get a quick overview for pending local changes and conflict history.
  Future<SyncOverview> getSyncOverview() async {
    final pendingWorkAreas = await (_db.selectOnly(_db.localWorkAreas)
          ..addColumns([_db.localWorkAreas.id.count()])
          ..where(_db.localWorkAreas.syncStatus.equals('dirty')))
        .map((row) => row.read(_db.localWorkAreas.id.count()) ?? 0)
        .getSingle();

    final pendingTrees = await (_db.selectOnly(_db.localTrees)
          ..addColumns([_db.localTrees.id.count()])
          ..where(_db.localTrees.syncStatus.equals('dirty')))
        .map((row) => row.read(_db.localTrees.id.count()) ?? 0)
        .getSingle();

    final conflicts = await getConflicts();
    final retryQueue = await getRetryQueue();

    return SyncOverview(
      pendingWorkAreas: pendingWorkAreas,
      pendingTrees: pendingTrees,
      conflictCount: conflicts.length,
      retryQueueCount: retryQueue.length,
    );
  }


  Future<String?> getLastSyncError() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncErrorKey);
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_lastSyncAtKey);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  Future<void> syncAll() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await syncPush();
      await syncPull();
      await prefs.remove(_lastSyncErrorKey);
      await prefs.setString(_lastSyncAtKey, DateTime.now().toIso8601String());
    } catch (e) {
      final reason = e.toString();
      await prefs.setString(_lastSyncErrorKey, reason);
      await _enqueueRetryTask(SyncRetryTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        operation: 'sync_all',
        reason: reason,
        createdAt: DateTime.now(),
      ));
      rethrow;
    }
  }

  Future<List<SyncRetryTask>> getRetryQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_retryQueueKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => SyncRetryTask.fromJson(e)).toList();
  }

  Future<void> clearRetryQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_retryQueueKey);
  }

  Future<void> removeRetryTask(String id, String operation) async {
    final queue = await getRetryQueue();
    queue.removeWhere((t) => t.id == id && t.operation == operation);
    final prefs = await SharedPreferences.getInstance();
    if (queue.isEmpty) {
      await prefs.remove(_retryQueueKey);
    } else {
      await prefs.setString(_retryQueueKey, jsonEncode(queue.map((e) => e.toJson()).toList()));
    }
  }

  Future<void> _enqueueRetryTask(SyncRetryTask task) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getRetryQueue();
    final index = existing.indexWhere((e) => e.id == task.id && e.operation == task.operation);
    if (index >= 0) {
      final current = existing[index];
      existing[index] = SyncRetryTask(
        id: current.id,
        operation: current.operation,
        reason: task.reason,
        createdAt: current.createdAt,
        attempts: current.attempts,
        lastTriedAt: current.lastTriedAt,
        nextRetryAt: current.nextRetryAt,
      );
    } else {
      existing.add(task);
    }
    if (existing.length > 100) {
      existing.removeRange(0, existing.length - 100);
    }
    await prefs.setString(_retryQueueKey, jsonEncode(existing.map((e) => e.toJson()).toList()));
  }

  Future<void> retryFailedTasks() async {
    final queue = await getRetryQueue();
    if (queue.isEmpty) return;
    final now = DateTime.now();

    final updatedQueue = <SyncRetryTask>[];
    for (final task in queue) {
      if (task.attempts >= _maxRetryAttempts) {
        updatedQueue.add(task);
        continue;
      }
      if (task.nextRetryAt != null && task.nextRetryAt!.isAfter(now)) {
        updatedQueue.add(task);
        continue;
      }
      try {
        await _retryTask(task);
      } catch (e) {
        final nextRetryAt = _nextRetryAt(now, task.attempts + 1);
        updatedQueue.add(SyncRetryTask(
          id: task.id,
          operation: task.operation,
          reason: e.toString(),
          createdAt: task.createdAt,
          attempts: task.attempts + 1,
          lastTriedAt: now,
          nextRetryAt: nextRetryAt,
        ));
      }
    }

    final prefs = await SharedPreferences.getInstance();
    if (updatedQueue.isEmpty) {
      await prefs.remove(_retryQueueKey);
    } else {
      await prefs.setString(
        _retryQueueKey,
        jsonEncode(updatedQueue.map((e) => e.toJson()).toList()),
      );
    }
  }

  DateTime _nextRetryAt(DateTime from, int attempt) {
    final boundedAttempt = attempt.clamp(1, _maxRetryAttempts);
    final minutes = 1 << (boundedAttempt - 1);
    return from.add(Duration(minutes: minutes));
  }

  Future<void> _retryTask(SyncRetryTask task) async {
    switch (task.operation) {
      case 'push_work_area':
        final area = await (_db.select(_db.localWorkAreas)..where((t) => t.id.equals(task.id))).getSingleOrNull();
        if (area == null) return;
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
        return;
      case 'push_tree':
        final tree = await (_db.select(_db.localTrees)..where((t) => t.id.equals(task.id))).getSingleOrNull();
        if (tree == null) return;
        await _supabase.from('trees').upsert({
          'id': tree.id,
          'species': tree.species,
          'height': tree.height,
          'diameter': tree.diameter,
          'health_status': tree.healthStatus,
          'location': tree.location,
          'work_area_id': tree.workAreaId,
          'photo_url': tree.photoUrl,
          'updated_at': DateTime.now().toIso8601String(),
          'user_id': _supabase.auth.currentUser!.id,
        });
        await (_db.update(_db.localTrees)..where((t) => t.id.equals(tree.id))).write(
          const LocalTreesCompanion(syncStatus: Value('synced')),
        );
        return;
      case 'sync_all':
        await syncAll();
        return;
      default:
        throw Exception('Unknown retry operation: ${task.operation}');
    }
  }

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
    final errors = <String>[];
    // 1. Push Work Areas
    final dirtyAreas = await (_db.select(_db.localWorkAreas)..where((t) => t.syncStatus.equals('dirty'))).get();
    for (final area in dirtyAreas) {
      try {
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
      } catch (e) {
        final reason = 'work_area:${area.id} - $e';
        errors.add(reason);
        await _enqueueRetryTask(SyncRetryTask(
          id: area.id,
          operation: 'push_work_area',
          reason: reason,
          createdAt: DateTime.now(),
        ));
      }
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

      try {
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
      } catch (e) {
        final reason = 'tree:${tree.id} - $e';
        errors.add(reason);
        await _enqueueRetryTask(SyncRetryTask(
          id: tree.id,
          operation: 'push_tree',
          reason: reason,
          createdAt: DateTime.now(),
        ));
      }
    }

    if (errors.isNotEmpty) {
      throw Exception('Sync push partial failure: ${errors.join(' | ')}');
    }
  }
}

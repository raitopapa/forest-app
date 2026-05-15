import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final offlineMapCacheServiceProvider = Provider((ref) => OfflineMapCacheService());

class OfflineMapCacheInfo {
  final String workAreaId;
  final int minZoom;
  final int maxZoom;
  final int estimatedTiles;
  final DateTime updatedAt;

  const OfflineMapCacheInfo({
    required this.workAreaId,
    required this.minZoom,
    required this.maxZoom,
    required this.estimatedTiles,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'workAreaId': workAreaId,
        'minZoom': minZoom,
        'maxZoom': maxZoom,
        'estimatedTiles': estimatedTiles,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory OfflineMapCacheInfo.fromJson(Map<String, dynamic> json) {
    return OfflineMapCacheInfo(
      workAreaId: json['workAreaId'] as String,
      minZoom: json['minZoom'] as int,
      maxZoom: json['maxZoom'] as int,
      estimatedTiles: json['estimatedTiles'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get estimatedSizeLabel {
    final estimatedBytes = estimatedTiles * 20 * 1024;
    if (estimatedBytes < 1024 * 1024) {
      return '${(estimatedBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(estimatedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class OfflineTileCacheStats {
  final int fileCount;
  final int totalBytes;

  const OfflineTileCacheStats({
    required this.fileCount,
    required this.totalBytes,
  });

  String get totalSizeLabel {
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class OfflineTileDownloadResult {
  final int downloaded;
  final int failed;
  final int skipped;

  const OfflineTileDownloadResult({
    required this.downloaded,
    required this.failed,
    required this.skipped,
  });

  int get processed => downloaded + failed + skipped;
}

class OfflineMapCacheService {
  static const _key = 'offline_map_cache_info';

  Future<Map<String, OfflineMapCacheInfo>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (k, v) => MapEntry(k, OfflineMapCacheInfo.fromJson(v as Map<String, dynamic>)),
    );
  }

  Future<void> _saveAll(Map<String, OfflineMapCacheInfo> all) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = all.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_key, jsonEncode(jsonMap));
  }

  Future<OfflineMapCacheInfo?> getCacheInfo(String workAreaId) async {
    final all = await _loadAll();
    return all[workAreaId];
  }

  Future<void> saveCachePlan({
    required String workAreaId,
    required int minZoom,
    required int maxZoom,
    int areaComplexity = 12,
  }) async {
    final all = await _loadAll();
    final zoomSpan = (maxZoom - minZoom + 1).clamp(1, 20);
    final estimatedTiles = zoomSpan * areaComplexity * 64;

    all[workAreaId] = OfflineMapCacheInfo(
      workAreaId: workAreaId,
      minZoom: minZoom,
      maxZoom: maxZoom,
      estimatedTiles: estimatedTiles,
      updatedAt: DateTime.now(),
    );

    await _saveAll(all);
  }

  Future<void> saveCachePlanForBounds({
    required String workAreaId,
    required LatLngBounds bounds,
    required int minZoom,
    required int maxZoom,
  }) async {
    final all = await _loadAll();
    final estimatedTiles = estimateTileCountForBounds(
      bounds: bounds,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );

    all[workAreaId] = OfflineMapCacheInfo(
      workAreaId: workAreaId,
      minZoom: minZoom,
      maxZoom: maxZoom,
      estimatedTiles: estimatedTiles,
      updatedAt: DateTime.now(),
    );
    await _saveAll(all);
  }

  Future<void> clearCachePlan(String workAreaId) async {
    final all = await _loadAll();
    all.remove(workAreaId);
    await _saveAll(all);
  }

  Future<Directory> _getCacheDir(String workAreaId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'tile_cache', workAreaId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  int _lonToTileX(double lon, int zoom) => ((lon + 180.0) / 360.0 * (1 << zoom)).floor();

  int _latToTileY(double lat, int zoom) {
    final safeLat = lat.clamp(-85.05112878, 85.05112878);
    final rad = safeLat * pi / 180.0;
    final n = 1 << zoom;
    return ((1 - (log(tan(rad) + 1 / cos(rad)) / pi)) / 2 * n).floor();
  }

  Iterable<int> _xIndexesForBounds(LatLngBounds bounds, int zoom) sync* {
    final maxIndex = (1 << zoom) - 1;
    final west = _lonToTileX(bounds.west, zoom).clamp(0, maxIndex);
    final east = _lonToTileX(bounds.east, zoom).clamp(0, maxIndex);
    if (bounds.west <= bounds.east) {
      final minX = min(west, east);
      final maxX = max(west, east);
      for (int x = minX; x <= maxX; x++) {
        yield x;
      }
      return;
    }

    for (int x = west; x <= maxIndex; x++) {
      yield x;
    }
    for (int x = 0; x <= east; x++) {
      yield x;
    }
  }

  Iterable<int> _yIndexesForBounds(LatLngBounds bounds, int zoom) sync* {
    final maxIndex = (1 << zoom) - 1;
    final yMin = _latToTileY(bounds.north, zoom).clamp(0, maxIndex);
    final yMax = _latToTileY(bounds.south, zoom).clamp(0, maxIndex);
    final minY = min(yMin, yMax);
    final maxY = max(yMin, yMax);
    for (int y = minY; y <= maxY; y++) {
      yield y;
    }
  }

  Future<int> downloadTilesForBounds({
    required String workAreaId,
    required LatLngBounds bounds,
    required int minZoom,
    required int maxZoom,
    String urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final result = await downloadTilesForBoundsDetailed(
      workAreaId: workAreaId,
      bounds: bounds,
      minZoom: minZoom,
      maxZoom: maxZoom,
      urlTemplate: urlTemplate,
      onProgress: onProgress,
    );
    return result.downloaded;
  }

  Future<OfflineTileDownloadResult> downloadTilesForBoundsDetailed({
    required String workAreaId,
    required LatLngBounds bounds,
    required int minZoom,
    required int maxZoom,
    String urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    void Function(int downloaded, int total)? onProgress,
    Duration requestTimeout = const Duration(seconds: 10),
  }) async {
    final cacheDir = await _getCacheDir(workAreaId);
    var downloaded = 0;
    var failed = 0;
    var skipped = 0;
    var processed = 0;
    final total = estimateTileCountForBounds(
      bounds: bounds,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );

    for (int z = minZoom; z <= maxZoom; z++) {
      final yIndexes = _yIndexesForBounds(bounds, z).toList(growable: false);
      for (final x in _xIndexesForBounds(bounds, z)) {
        for (final y in yIndexes) {
          processed++;
          final path = p.join(cacheDir.path, '$z', '$x', '$y.png');
          final file = File(path);
          if (await file.exists()) {
            skipped++;
            onProgress?.call(processed, total);
            continue;
          }

          await file.parent.create(recursive: true);
          final url = urlTemplate.replaceAll('{z}', '$z').replaceAll('{x}', '$x').replaceAll('{y}', '$y');
          try {
            final res = await http
                .get(
                  Uri.parse(url),
                  headers: const {'User-Agent': 'forest-app-offline-cache/1.0'},
                )
                .timeout(requestTimeout);
            if (res.statusCode == 200) {
              await file.writeAsBytes(res.bodyBytes);
              downloaded++;
            } else {
              failed++;
            }
          } catch (_) {
            failed++;
          }
          onProgress?.call(processed, total);
        }
      }
    }

    return OfflineTileDownloadResult(
      downloaded: downloaded,
      failed: failed,
      skipped: skipped,
    );
  }

  Future<void> clearTileCache(String workAreaId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'tile_cache', workAreaId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<bool> hasTileCache(String workAreaId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'tile_cache', workAreaId));
    if (!await dir.exists()) return false;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.png')) return true;
    }
    return false;
  }

  Future<String> localTilePath(String workAreaId, int z, int x, int y) async {
    final dir = await _getCacheDir(workAreaId);
    return p.join(dir.path, '$z', '$x', '$y.png');
  }

  Future<String> getCacheDirectoryPath(String workAreaId) async {
    final dir = await _getCacheDir(workAreaId);
    return dir.path;
  }

  Future<String?> getExistingCacheDirectoryPath(String workAreaId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'tile_cache', workAreaId));
    if (!await dir.exists()) return null;
    return dir.path;
  }

  Future<double?> getCacheCompletionRatio(String workAreaId) async {
    final info = await getCacheInfo(workAreaId);
    if (info == null || info.estimatedTiles <= 0) return null;

    final stats = await getTileCacheStats(workAreaId);
    final ratio = stats.fileCount / info.estimatedTiles;
    return ratio.clamp(0.0, 1.0);
  }

  int estimateTileCountForBounds({
    required LatLngBounds bounds,
    required int minZoom,
    required int maxZoom,
  }) {
    var total = 0;
    for (int z = minZoom; z <= maxZoom; z++) {
      final xCount = _xIndexesForBounds(bounds, z).length;
      final yCount = _yIndexesForBounds(bounds, z).length;
      total += xCount * yCount;
    }
    return total;
  }

  Future<OfflineTileCacheStats> getTileCacheStats(String workAreaId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'tile_cache', workAreaId));
    if (!await dir.exists()) {
      return const OfflineTileCacheStats(fileCount: 0, totalBytes: 0);
    }

    var count = 0;
    var totalBytes = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.png')) continue;
      count++;
      totalBytes += await entity.length();
    }
    return OfflineTileCacheStats(fileCount: count, totalBytes: totalBytes);
  }
}

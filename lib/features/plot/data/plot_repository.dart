import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../offline/data/sync_repository.dart';
import '../domain/models/plot.dart';

final plotRepositoryProvider = Provider<PlotRepository>((ref) {
  return PlotRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncRepositoryProvider),
  );
});

class PlotRepository {
  final AppDatabase _db;
  final SyncRepository _sync;

  PlotRepository(this._db, this._sync);

  /// プロット一覧を取得
  Future<List<Plot>> getPlots(String workAreaId) async {
    final plots = await (_db.select(_db.localPlots)
          ..where((p) => p.workAreaId.equals(workAreaId))
          ..orderBy([(p) => OrderingTerm(expression: p.createdAt, mode: OrderingMode.desc)]))
        .get();

    return plots.map((p) => Plot(
      id: p.id,
      name: p.name,
      shape: PlotShapeExtension.fromDbString(p.shape),
      centerLat: p.centerLat,
      centerLng: p.centerLng,
      size: p.size,
      workAreaId: p.workAreaId,
      description: p.description,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    )).toList();
  }

  /// プロットを作成
  Future<String> createPlot({
    required String name,
    required PlotShape shape,
    required double centerLat,
    required double centerLng,
    required double size,
    required String workAreaId,
    String? description,
  }) async {
    final id = const Uuid().v4();

    await _db.into(_db.localPlots).insert(LocalPlotsCompanion.insert(
      id: id,
      name: name,
      shape: shape.toDbString(),
      centerLat: centerLat,
      centerLng: centerLng,
      size: size,
      workAreaId: workAreaId,
      description: Value(description),
      syncStatus: const Value('dirty'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));

    _sync.syncPush();
    return id;
  }

  /// プロットを更新
  Future<void> updatePlot({
    required String id,
    String? name,
    PlotShape? shape,
    double? size,
    String? description,
  }) async {
    await (_db.update(_db.localPlots)..where((p) => p.id.equals(id))).write(
      LocalPlotsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        shape: shape != null ? Value(shape.toDbString()) : const Value.absent(),
        size: size != null ? Value(size) : const Value.absent(),
        description: Value(description),
        syncStatus: const Value('dirty'),
        updatedAt: Value(DateTime.now()),
      ),
    );

    _sync.syncPush();
  }

  /// プロットを削除
  Future<void> deletePlot(String id) async {
    // プロット内の樹木のplotIdをクリア
    await (_db.update(_db.localTrees)..where((t) => t.plotId.equals(id))).write(
      const LocalTreesCompanion(
        plotId: Value(null),
      ),
    );

    // プロットを削除
    await (_db.delete(_db.localPlots)..where((p) => p.id.equals(id))).go();

    _sync.syncPush();
  }

  /// プロット内の樹木を取得
  Future<List<Map<String, dynamic>>> getTreesInPlot(String plotId) async {
    final trees = await (_db.select(_db.localTrees)
          ..where((t) => t.plotId.equals(plotId))
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
      'plot_id': t.plotId,
      'photo_url': t.photoUrl,
      'photo_path': t.photoPath,
      'volume': t.volume,
      'age': t.age,
      'forest_section': t.forestSection,
      'sub_section': t.subSection,
      'tree_number': t.treeNumber,
      'vigor': t.vigor,
      'pest_disease': t.pestDisease,
      'slope': t.slope,
      'aspect': t.aspect,
      'notes': t.notes,
      'marked_for_thinning': t.markedForThinning,
    }).toList();
  }

  /// プロット統計を計算
  Future<PlotStatistics> getPlotStatistics(Plot plot) async {
    final trees = await getTreesInPlot(plot.id);

    if (trees.isEmpty) {
      return PlotStatistics(
        plot: plot,
        treeCount: 0,
        totalVolume: 0,
        averageHeight: 0,
        averageDiameter: 0,
        speciesCount: {},
        standingVolume: 0,
        treeDensity: 0,
      );
    }

    // 統計計算
    int treeCount = trees.length;
    double totalVolume = 0;
    double totalHeight = 0;
    double totalDiameter = 0;
    int heightCount = 0;
    int diameterCount = 0;
    Map<String, int> speciesCount = {};

    for (var tree in trees) {
      // 材積
      final volume = tree['volume'] as double?;
      if (volume != null) {
        totalVolume += volume;
      }

      // 樹高
      final height = tree['height'] as double?;
      if (height != null) {
        totalHeight += height;
        heightCount++;
      }

      // 胸高直径
      final diameter = tree['diameter'] as double?;
      if (diameter != null) {
        totalDiameter += diameter;
        diameterCount++;
      }

      // 樹種
      final species = tree['species'] as String;
      speciesCount[species] = (speciesCount[species] ?? 0) + 1;
    }

    // 平均値
    double averageHeight = heightCount > 0 ? totalHeight / heightCount : 0;
    double averageDiameter = diameterCount > 0 ? totalDiameter / diameterCount : 0;

    // ヘクタール当たりの値
    double standingVolume = totalVolume / plot.areaInHectares;
    double treeDensity = treeCount / plot.areaInHectares;

    return PlotStatistics(
      plot: plot,
      treeCount: treeCount,
      totalVolume: totalVolume,
      averageHeight: averageHeight,
      averageDiameter: averageDiameter,
      speciesCount: speciesCount,
      standingVolume: standingVolume,
      treeDensity: treeDensity,
    );
  }
}

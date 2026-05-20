import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../map/data/tree_repository.dart';
import '../../offline/data/sync_repository.dart' show appDatabaseProvider;
import '../../plot/data/plot_repository.dart';
import '../domain/models/work_area_statistics.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService(
    ref.watch(appDatabaseProvider),
    ref.watch(treeRepositoryProvider),
    ref.watch(plotRepositoryProvider),
  );
});

class StatisticsService {
  final AppDatabase _db;
  final TreeRepository _treeRepo;
  final PlotRepository _plotRepo;

  StatisticsService(this._db, this._treeRepo, this._plotRepo);

  /// 作業エリア全体の統計を計算
  Future<WorkAreaStatistics> calculateWorkAreaStatistics(
    String workAreaId,
    String workAreaName,
  ) async {
    final trees = await _treeRepo.getTrees(workAreaId);
    final plots = await _plotRepo.getPlots(workAreaId);

    if (trees.isEmpty) {
      return WorkAreaStatistics(
        workAreaId: workAreaId,
        workAreaName: workAreaName,
        totalTreeCount: 0,
        totalVolume: 0,
        averageHeight: 0,
        averageDiameter: 0,
        averageAge: 0,
        speciesBreakdown: {},
        vigorBreakdown: {},
        thinningMarkedCount: 0,
        thinningMarkedVolume: 0,
        thinningRate: 0,
        sectionBreakdown: {},
        pestDiseaseCount: 0,
        pestDiseaseRate: 0,
        plotCount: plots.length,
        averageStandingVolume: 0,
        averageTreeDensity: 0,
      );
    }

    // 基本統計の計算
    int totalTreeCount = trees.length;
    double totalVolume = 0;
    double totalHeight = 0;
    double totalDiameter = 0;
    double totalAge = 0;
    int heightCount = 0;
    int diameterCount = 0;
    int ageCount = 0;

    // 樹種別データ
    Map<String, _SpeciesData> speciesData = {};

    // 樹勢別カウント
    Map<String, int> vigorBreakdown = {};

    // 間伐関連
    int thinningMarkedCount = 0;
    double thinningMarkedVolume = 0;

    // 林班・小班別データ
    Map<String, _SectionData> sectionData = {};

    // 病虫害カウント
    int pestDiseaseCount = 0;

    // 各樹木の集計
    for (var tree in trees) {
      final species = tree['species'] as String;
      final volume = tree['volume'] as double?;
      final height = tree['height'] as double?;
      final diameter = tree['diameter'] as double?;
      final age = tree['age'] as int?;
      final vigor = tree['vigor'] as String?;
      final forestSection = tree['forest_section'] as String?;
      final subSection = tree['sub_section'] as String?;
      final markedForThinning = tree['marked_for_thinning'] as bool? ?? false;
      final pestDisease = tree['pest_disease'] as String?;

      // 材積
      if (volume != null) {
        totalVolume += volume;
        if (markedForThinning) {
          thinningMarkedVolume += volume;
        }
      }

      // 樹高
      if (height != null) {
        totalHeight += height;
        heightCount++;
      }

      // 胸高直径
      if (diameter != null) {
        totalDiameter += diameter;
        diameterCount++;
      }

      // 樹齢
      if (age != null) {
        totalAge += age.toDouble();
        ageCount++;
      }

      // 間伐対象
      if (markedForThinning) {
        thinningMarkedCount++;
      }

      // 病虫害
      if (pestDisease != null && pestDisease.isNotEmpty) {
        pestDiseaseCount++;
      }

      // 樹種別データ
      if (!speciesData.containsKey(species)) {
        speciesData[species] = _SpeciesData();
      }
      speciesData[species]!.addTree(
        volume: volume,
        height: height,
        diameter: diameter,
        age: age,
        markedForThinning: markedForThinning,
      );

      // 樹勢別カウント
      if (vigor != null) {
        vigorBreakdown[vigor] = (vigorBreakdown[vigor] ?? 0) + 1;
      }

      // 林班別データ
      if (forestSection != null && forestSection.isNotEmpty) {
        if (!sectionData.containsKey(forestSection)) {
          sectionData[forestSection] = _SectionData(forestSection);
        }
        sectionData[forestSection]!.addTree(species, volume);
      }

      // 小班別データ
      if (subSection != null && subSection.isNotEmpty) {
        final key = '${forestSection ?? ''}-$subSection';
        if (!sectionData.containsKey(key)) {
          sectionData[key] = _SectionData(key);
        }
        sectionData[key]!.addTree(species, volume);
      }
    }

    // 平均値の計算
    double averageHeight = heightCount > 0 ? totalHeight / heightCount : 0;
    double averageDiameter = diameterCount > 0 ? totalDiameter / diameterCount : 0;
    double averageAge = ageCount > 0 ? totalAge / ageCount : 0;
    double thinningRate = totalTreeCount > 0 ? (thinningMarkedCount / totalTreeCount) * 100 : 0;
    double pestDiseaseRate = totalTreeCount > 0 ? (pestDiseaseCount / totalTreeCount) * 100 : 0;

    // 樹種別統計の構築
    Map<String, SpeciesStatistics> speciesBreakdown = {};
    speciesData.forEach((species, data) {
      speciesBreakdown[species] = SpeciesStatistics(
        species: species,
        count: data.count,
        totalVolume: data.totalVolume,
        averageHeight: data.heightCount > 0 ? data.totalHeight / data.heightCount : 0,
        averageDiameter: data.diameterCount > 0 ? data.totalDiameter / data.diameterCount : 0,
        averageAge: data.ageCount > 0 ? data.totalAge / data.ageCount : 0,
        thinningMarkedCount: data.thinningMarkedCount,
        thinningMarkedVolume: data.thinningMarkedVolume,
      );
    });

    // 林班・小班別統計の構築
    Map<String, SectionStatistics> sectionBreakdown = {};
    sectionData.forEach((key, data) {
      sectionBreakdown[key] = SectionStatistics(
        sectionName: data.sectionName,
        count: data.count,
        totalVolume: data.totalVolume,
        speciesCount: data.speciesCount,
      );
    });

    // プロット統計の計算
    double totalStandingVolume = 0;
    double totalTreeDensity = 0;
    int plotsWithData = 0;

    for (final plot in plots) {
      final stats = await _plotRepo.getPlotStatistics(plot);
      if (stats.treeCount > 0) {
        totalStandingVolume += stats.standingVolume;
        totalTreeDensity += stats.treeDensity;
        plotsWithData++;
      }
    }

    double averageStandingVolume = plotsWithData > 0 ? totalStandingVolume / plotsWithData : 0;
    double averageTreeDensity = plotsWithData > 0 ? totalTreeDensity / plotsWithData : 0;

    return WorkAreaStatistics(
      workAreaId: workAreaId,
      workAreaName: workAreaName,
      totalTreeCount: totalTreeCount,
      totalVolume: totalVolume,
      averageHeight: averageHeight,
      averageDiameter: averageDiameter,
      averageAge: averageAge,
      speciesBreakdown: speciesBreakdown,
      vigorBreakdown: vigorBreakdown,
      thinningMarkedCount: thinningMarkedCount,
      thinningMarkedVolume: thinningMarkedVolume,
      thinningRate: thinningRate,
      sectionBreakdown: sectionBreakdown,
      pestDiseaseCount: pestDiseaseCount,
      pestDiseaseRate: pestDiseaseRate,
      plotCount: plots.length,
      averageStandingVolume: averageStandingVolume,
      averageTreeDensity: averageTreeDensity,
    );
  }

  /// 間伐シミュレーションを実行
  Future<ThinningSimulation> simulateThinning(
    WorkAreaStatistics stats, {
    double? customThinningRate,
    double pricePerCubicMeter = 15000, // 材積単価 (円/m³)
    double costPerTree = 3000, // 伐採費用 (円/本)
  }) async {
    final thinningRate = customThinningRate ?? stats.thinningRate;
    final thinningTargetCount = customThinningRate != null
        ? (stats.totalTreeCount * customThinningRate / 100).round()
        : stats.thinningMarkedCount;
    final thinningTargetVolume = customThinningRate != null
        ? stats.totalVolume * customThinningRate / 100
        : stats.thinningMarkedVolume;

    final afterTreeCount = stats.totalTreeCount - thinningTargetCount;
    final afterVolume = stats.totalVolume - thinningTargetVolume;
    final double afterDensity = stats.averageTreeDensity > 0
        ? stats.averageTreeDensity * (afterTreeCount / stats.totalTreeCount)
        : 0.0;

    // 経済性の計算
    final estimatedRevenue = thinningTargetVolume * pricePerCubicMeter;
    final estimatedCost = thinningTargetCount * costPerTree;
    final estimatedProfit = estimatedRevenue - estimatedCost;

    return ThinningSimulation(
      beforeThinning: stats,
      thinningTargetCount: thinningTargetCount,
      thinningTargetVolume: thinningTargetVolume,
      thinningRate: thinningRate,
      afterTreeCount: afterTreeCount,
      afterVolume: afterVolume,
      afterDensity: afterDensity,
      estimatedRevenue: estimatedRevenue,
      estimatedCost: estimatedCost,
      estimatedProfit: estimatedProfit,
    );
  }

  /// 材積表を使用した材積計算（将来の拡張用）
  Future<double?> calculateVolumeFromTable(
    String species,
    double diameter,
    double height,
  ) async {
    // TODO: 実際の材積表データベースを実装
    // 現在は簡易式を使用
    return 0.000045 * diameter * diameter * height;
  }
}

/// 樹種別データ集計用の内部クラス
class _SpeciesData {
  int count = 0;
  double totalVolume = 0;
  double totalHeight = 0;
  double totalDiameter = 0;
  double totalAge = 0;
  int heightCount = 0;
  int diameterCount = 0;
  int ageCount = 0;
  int thinningMarkedCount = 0;
  double thinningMarkedVolume = 0;

  void addTree({
    double? volume,
    double? height,
    double? diameter,
    int? age,
    bool markedForThinning = false,
  }) {
    count++;
    if (volume != null) {
      totalVolume += volume;
      if (markedForThinning) {
        thinningMarkedVolume += volume;
      }
    }
    if (height != null) {
      totalHeight += height;
      heightCount++;
    }
    if (diameter != null) {
      totalDiameter += diameter;
      diameterCount++;
    }
    if (age != null) {
      totalAge += age.toDouble();
      ageCount++;
    }
    if (markedForThinning) {
      thinningMarkedCount++;
    }
  }
}

/// 林班・小班データ集計用の内部クラス
class _SectionData {
  final String sectionName;
  int count = 0;
  double totalVolume = 0;
  Map<String, int> speciesCount = {};

  _SectionData(this.sectionName);

  void addTree(String species, double? volume) {
    count++;
    if (volume != null) {
      totalVolume += volume;
    }
    speciesCount[species] = (speciesCount[species] ?? 0) + 1;
  }
}

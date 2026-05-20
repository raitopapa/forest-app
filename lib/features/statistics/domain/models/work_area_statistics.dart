/// 作業エリア統計データモデル
class WorkAreaStatistics {
  final String workAreaId;
  final String workAreaName;

  // 基本統計
  final int totalTreeCount; // 総樹木本数
  final double totalVolume; // 総材積 (m³)
  final double averageHeight; // 平均樹高 (m)
  final double averageDiameter; // 平均胸高直径 (cm)
  final double averageAge; // 平均樹齢 (年)

  // 樹種別統計
  final Map<String, SpeciesStatistics> speciesBreakdown;

  // 樹勢別統計
  final Map<String, int> vigorBreakdown; // A/B/C

  // 間伐関連
  final int thinningMarkedCount; // 間伐対象本数
  final double thinningMarkedVolume; // 間伐対象材積 (m³)
  final double thinningRate; // 間伐率 (%)

  // 林班・小班別統計
  final Map<String, SectionStatistics> sectionBreakdown;

  // 病虫害統計
  final int pestDiseaseCount; // 病虫害発生本数
  final double pestDiseaseRate; // 病虫害発生率 (%)

  // プロット統計
  final int plotCount; // プロット数
  final double averageStandingVolume; // 平均蓄積量 (m³/ha)
  final double averageTreeDensity; // 平均立木密度 (本/ha)

  const WorkAreaStatistics({
    required this.workAreaId,
    required this.workAreaName,
    required this.totalTreeCount,
    required this.totalVolume,
    required this.averageHeight,
    required this.averageDiameter,
    required this.averageAge,
    required this.speciesBreakdown,
    required this.vigorBreakdown,
    required this.thinningMarkedCount,
    required this.thinningMarkedVolume,
    required this.thinningRate,
    required this.sectionBreakdown,
    required this.pestDiseaseCount,
    required this.pestDiseaseRate,
    required this.plotCount,
    required this.averageStandingVolume,
    required this.averageTreeDensity,
  });

  /// 優占樹種を取得
  String? get dominantSpecies {
    if (speciesBreakdown.isEmpty) return null;
    return speciesBreakdown.entries
        .reduce((a, b) => a.value.count > b.value.count ? a : b)
        .key;
  }

  /// 間伐後の予測材積
  double get volumeAfterThinning {
    return totalVolume - thinningMarkedVolume;
  }

  /// 間伐後の予測本数
  int get treeCountAfterThinning {
    return totalTreeCount - thinningMarkedCount;
  }
}

/// 樹種別統計
class SpeciesStatistics {
  final String species;
  final int count; // 本数
  final double totalVolume; // 総材積 (m³)
  final double averageHeight; // 平均樹高 (m)
  final double averageDiameter; // 平均胸高直径 (cm)
  final double averageAge; // 平均樹齢 (年)
  final int thinningMarkedCount; // 間伐対象本数
  final double thinningMarkedVolume; // 間伐対象材積 (m³)

  const SpeciesStatistics({
    required this.species,
    required this.count,
    required this.totalVolume,
    required this.averageHeight,
    required this.averageDiameter,
    required this.averageAge,
    required this.thinningMarkedCount,
    required this.thinningMarkedVolume,
  });

  /// 本数割合 (%)
  double getPercentage(int totalCount) {
    if (totalCount == 0) return 0;
    return (count / totalCount) * 100;
  }

  /// 材積割合 (%)
  double getVolumePercentage(double totalVolume) {
    if (totalVolume == 0) return 0;
    return (this.totalVolume / totalVolume) * 100;
  }

  /// 間伐率 (%)
  double get thinningRate {
    if (count == 0) return 0;
    return (thinningMarkedCount / count) * 100;
  }
}

/// 林班・小班別統計
class SectionStatistics {
  final String sectionName; // 林班名 or 小班名
  final int count; // 本数
  final double totalVolume; // 総材積 (m³)
  final Map<String, int> speciesCount; // 樹種別本数

  const SectionStatistics({
    required this.sectionName,
    required this.count,
    required this.totalVolume,
    required this.speciesCount,
  });
}

/// 間伐シミュレーション結果
class ThinningSimulation {
  final WorkAreaStatistics beforeThinning;
  final int thinningTargetCount; // 間伐予定本数
  final double thinningTargetVolume; // 間伐予定材積 (m³)
  final double thinningRate; // 間伐率 (%)

  // 間伐後の予測
  final int afterTreeCount; // 間伐後本数
  final double afterVolume; // 間伐後材積 (m³)
  final double afterDensity; // 間伐後密度

  // 経済性
  final double estimatedRevenue; // 推定収入 (円)
  final double estimatedCost; // 推定費用 (円)
  final double estimatedProfit; // 推定利益 (円)

  const ThinningSimulation({
    required this.beforeThinning,
    required this.thinningTargetCount,
    required this.thinningTargetVolume,
    required this.thinningRate,
    required this.afterTreeCount,
    required this.afterVolume,
    required this.afterDensity,
    required this.estimatedRevenue,
    required this.estimatedCost,
    required this.estimatedProfit,
  });
}

/// 材積表エントリ
class VolumeTableEntry {
  final String species; // 樹種
  final double diameter; // 胸高直径 (cm)
  final double height; // 樹高 (m)
  final double volume; // 材積 (m³)

  const VolumeTableEntry({
    required this.species,
    required this.diameter,
    required this.height,
    required this.volume,
  });
}

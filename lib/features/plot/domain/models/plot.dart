/// プロット(標本区)データモデル
class Plot {
  final String id;
  final String name;
  final PlotShape shape; // 円形 or 方形
  final double centerLat;
  final double centerLng;
  final double size; // 円形: 半径(m), 方形: 一辺の長さ(m)
  final String workAreaId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Plot({
    required this.id,
    required this.name,
    required this.shape,
    required this.centerLat,
    required this.centerLng,
    required this.size,
    required this.workAreaId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// プロットの面積を計算 (m²)
  double get area {
    if (shape == PlotShape.circle) {
      // 円形: πr²
      return 3.14159265359 * size * size;
    } else {
      // 方形: 一辺²
      return size * size;
    }
  }

  /// プロットの面積をヘクタールで取得
  double get areaInHectares {
    return area / 10000;
  }

  Plot copyWith({
    String? id,
    String? name,
    PlotShape? shape,
    double? centerLat,
    double? centerLng,
    double? size,
    String? workAreaId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plot(
      id: id ?? this.id,
      name: name ?? this.name,
      shape: shape ?? this.shape,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      size: size ?? this.size,
      workAreaId: workAreaId ?? this.workAreaId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// プロットの形状
enum PlotShape {
  circle, // 円形
  square, // 方形
}

/// プロット統計情報
class PlotStatistics {
  final Plot plot;
  final int treeCount; // 樹木本数
  final double totalVolume; // 総材積 (m³)
  final double averageHeight; // 平均樹高 (m)
  final double averageDiameter; // 平均胸高直径 (cm)
  final Map<String, int> speciesCount; // 樹種別本数
  final double standingVolume; // 蓄積量 (m³/ha)
  final double treeDensity; // 立木密度 (本/ha)

  const PlotStatistics({
    required this.plot,
    required this.treeCount,
    required this.totalVolume,
    required this.averageHeight,
    required this.averageDiameter,
    required this.speciesCount,
    required this.standingVolume,
    required this.treeDensity,
  });

  /// 優占樹種を取得
  String? get dominantSpecies {
    if (speciesCount.isEmpty) return null;
    return speciesCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

extension PlotShapeExtension on PlotShape {
  String toDbString() {
    switch (this) {
      case PlotShape.circle:
        return 'circle';
      case PlotShape.square:
        return 'square';
    }
  }

  String get displayName {
    switch (this) {
      case PlotShape.circle:
        return '円形';
      case PlotShape.square:
        return '方形';
    }
  }

  static PlotShape fromDbString(String value) {
    switch (value) {
      case 'circle':
        return PlotShape.circle;
      case 'square':
        return PlotShape.square;
      default:
        return PlotShape.circle;
    }
  }
}

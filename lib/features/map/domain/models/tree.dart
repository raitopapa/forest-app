/// 樹木データモデル - 林業実務対応
class Tree {
  final String id;
  final String species; // 樹種
  final double? height; // 樹高 (m)
  final double? diameter; // 胸高直径 (cm)
  final String? healthStatus; // 健康状態
  final String location; // WKT形式の位置情報
  final String workAreaId;
  final String? photoUrl;
  final String? photoPath;

  // 林業実務用フィールド
  final double? volume; // 材積 (m³)
  final int? age; // 樹齢 (年)
  final String? forestSection; // 林班
  final String? subSection; // 小班
  final String? treeNumber; // 立木番号
  final TreeVigor? vigor; // 樹勢
  final String? pestDisease; // 病虫害情報
  final double? slope; // 傾斜角度 (度)
  final Aspect? aspect; // 方位
  final String? notes; // 備考
  final bool markedForThinning; // 間伐対象

  final String syncStatus;
  final DateTime updatedAt;

  const Tree({
    required this.id,
    required this.species,
    this.height,
    this.diameter,
    this.healthStatus,
    required this.location,
    required this.workAreaId,
    this.photoUrl,
    this.photoPath,
    this.volume,
    this.age,
    this.forestSection,
    this.subSection,
    this.treeNumber,
    this.vigor,
    this.pestDisease,
    this.slope,
    this.aspect,
    this.notes,
    this.markedForThinning = false,
    this.syncStatus = 'synced',
    required this.updatedAt,
  });

  /// 材積を自動計算 (簡易式: 二変数材積式)
  /// V = 0.000045 × D^2 × H (スギの場合)
  double? calculateVolume() {
    if (diameter == null || height == null) return null;
    // 簡易二変数材積式 (スギ・ヒノキ・マツ類に適用可能)
    return 0.000045 * diameter! * diameter! * height!;
  }

  /// 樹勢の日本語表示
  String get vigorLabel {
    switch (vigor) {
      case TreeVigor.excellent:
        return 'A級 (優良)';
      case TreeVigor.good:
        return 'B級 (良好)';
      case TreeVigor.poor:
        return 'C級 (不良)';
      default:
        return '未評価';
    }
  }

  /// 方位の日本語表示
  String get aspectLabel {
    switch (aspect) {
      case Aspect.north:
        return '北';
      case Aspect.northEast:
        return '北東';
      case Aspect.east:
        return '東';
      case Aspect.southEast:
        return '南東';
      case Aspect.south:
        return '南';
      case Aspect.southWest:
        return '南西';
      case Aspect.west:
        return '西';
      case Aspect.northWest:
        return '北西';
      default:
        return '不明';
    }
  }

  Tree copyWith({
    String? id,
    String? species,
    double? height,
    double? diameter,
    String? healthStatus,
    String? location,
    String? workAreaId,
    String? photoUrl,
    String? photoPath,
    double? volume,
    int? age,
    String? forestSection,
    String? subSection,
    String? treeNumber,
    TreeVigor? vigor,
    String? pestDisease,
    double? slope,
    Aspect? aspect,
    String? notes,
    bool? markedForThinning,
    String? syncStatus,
    DateTime? updatedAt,
  }) {
    return Tree(
      id: id ?? this.id,
      species: species ?? this.species,
      height: height ?? this.height,
      diameter: diameter ?? this.diameter,
      healthStatus: healthStatus ?? this.healthStatus,
      location: location ?? this.location,
      workAreaId: workAreaId ?? this.workAreaId,
      photoUrl: photoUrl ?? this.photoUrl,
      photoPath: photoPath ?? this.photoPath,
      volume: volume ?? this.volume,
      age: age ?? this.age,
      forestSection: forestSection ?? this.forestSection,
      subSection: subSection ?? this.subSection,
      treeNumber: treeNumber ?? this.treeNumber,
      vigor: vigor ?? this.vigor,
      pestDisease: pestDisease ?? this.pestDisease,
      slope: slope ?? this.slope,
      aspect: aspect ?? this.aspect,
      notes: notes ?? this.notes,
      markedForThinning: markedForThinning ?? this.markedForThinning,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 樹勢評価
enum TreeVigor {
  excellent, // A級: 優良
  good, // B級: 良好
  poor, // C級: 不良
}

/// 方位
enum Aspect {
  north, // 北
  northEast, // 北東
  east, // 東
  southEast, // 南東
  south, // 南
  southWest, // 南西
  west, // 西
  northWest, // 北西
}

/// 樹勢の文字列変換
extension TreeVigorExtension on TreeVigor {
  String toDbString() {
    switch (this) {
      case TreeVigor.excellent:
        return 'A';
      case TreeVigor.good:
        return 'B';
      case TreeVigor.poor:
        return 'C';
    }
  }

  static TreeVigor? fromDbString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'A':
        return TreeVigor.excellent;
      case 'B':
        return TreeVigor.good;
      case 'C':
        return TreeVigor.poor;
      default:
        return null;
    }
  }
}

/// 方位の文字列変換
extension AspectExtension on Aspect {
  String toDbString() {
    switch (this) {
      case Aspect.north:
        return 'N';
      case Aspect.northEast:
        return 'NE';
      case Aspect.east:
        return 'E';
      case Aspect.southEast:
        return 'SE';
      case Aspect.south:
        return 'S';
      case Aspect.southWest:
        return 'SW';
      case Aspect.west:
        return 'W';
      case Aspect.northWest:
        return 'NW';
    }
  }

  static Aspect? fromDbString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'N':
        return Aspect.north;
      case 'NE':
        return Aspect.northEast;
      case 'E':
        return Aspect.east;
      case 'SE':
        return Aspect.southEast;
      case 'S':
        return Aspect.south;
      case 'SW':
        return Aspect.southWest;
      case 'W':
        return Aspect.west;
      case 'NW':
        return Aspect.northWest;
      default:
        return null;
    }
  }
}

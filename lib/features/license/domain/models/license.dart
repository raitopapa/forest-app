/// ライセンスタイプ
enum LicenseType {
  free,      // 無料版
  pro,       // Pro版
  enterprise // Enterprise版
}

/// ライセンス情報
class License {
  final LicenseType type;
  final DateTime? expiryDate; // サブスクリプションの期限
  final bool isActive;
  final Map<String, bool> features; // 機能の有効/無効

  const License({
    required this.type,
    this.expiryDate,
    this.isActive = true,
    required this.features,
  });

  /// 無料版ライセンスを作成
  factory License.free() {
    return const License(
      type: LicenseType.free,
      isActive: true,
      features: {
        // 基本機能
        'basic_tree_registration': true,      // 基本的な樹木登録
        'basic_map': true,                    // 基本地図機能
        'csv_export': true,                   // CSVエクスポート

        // 制限付き機能
        'max_trees_per_area': true,           // 制限: 10本/エリア
        'photo_upload': false,                // 写真アップロード不可

        // Pro機能 (無効)
        'unlimited_trees': false,             // 無制限登録
        'plot_survey': false,                 // プロット調査
        'volume_calculation': false,          // 材積自動計算
        'statistics_report': false,           // 統計レポート
        'pdf_export': false,                  // PDFエクスポート
        'advanced_map_layers': false,         // 高度な地図レイヤー
        'gps_tracking': false,                // GPS軌跡記録
        'custom_attributes': false,           // カスタム属性

        // Enterprise機能 (無効)
        'cloud_sync': false,                  // クラウド同期
        'multi_user': false,                  // 複数ユーザー
        'api_access': false,                  // API アクセス
        'custom_reports': false,              // カスタムレポート
        'priority_support': false,            // 優先サポート
      },
    );
  }

  /// Pro版ライセンスを作成
  factory License.pro({DateTime? expiryDate}) {
    return License(
      type: LicenseType.pro,
      expiryDate: expiryDate,
      isActive: expiryDate == null || expiryDate.isAfter(DateTime.now()),
      features: {
        // 基本機能 (すべて有効)
        'basic_tree_registration': true,
        'basic_map': true,
        'csv_export': true,
        'max_trees_per_area': false,          // 制限解除
        'photo_upload': true,

        // Pro機能 (すべて有効)
        'unlimited_trees': true,
        'plot_survey': true,
        'volume_calculation': true,
        'statistics_report': true,
        'pdf_export': true,
        'advanced_map_layers': true,
        'gps_tracking': true,
        'custom_attributes': true,

        // Enterprise機能 (無効)
        'cloud_sync': false,
        'multi_user': false,
        'api_access': false,
        'custom_reports': false,
        'priority_support': false,
      },
    );
  }

  /// Enterprise版ライセンスを作成
  factory License.enterprise({DateTime? expiryDate}) {
    return License(
      type: LicenseType.enterprise,
      expiryDate: expiryDate,
      isActive: expiryDate == null || expiryDate.isAfter(DateTime.now()),
      features: {
        // すべての機能が有効
        'basic_tree_registration': true,
        'basic_map': true,
        'csv_export': true,
        'max_trees_per_area': false,
        'photo_upload': true,
        'unlimited_trees': true,
        'plot_survey': true,
        'volume_calculation': true,
        'statistics_report': true,
        'pdf_export': true,
        'advanced_map_layers': true,
        'gps_tracking': true,
        'custom_attributes': true,
        'cloud_sync': true,
        'multi_user': true,
        'api_access': true,
        'custom_reports': true,
        'priority_support': true,
      },
    );
  }

  /// 機能が有効かチェック
  bool hasFeature(String featureKey) {
    if (!isActive) return false;
    return features[featureKey] ?? false;
  }

  /// ライセンスが有効期限内かチェック
  bool get isValid {
    if (!isActive) return false;
    if (expiryDate == null) return true;
    return expiryDate!.isAfter(DateTime.now());
  }

  /// 残り日数を取得
  int? get daysRemaining {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// ライセンス名
  String get displayName {
    switch (type) {
      case LicenseType.free:
        return '無料版';
      case LicenseType.pro:
        return 'Pro版';
      case LicenseType.enterprise:
        return 'Enterprise版';
    }
  }

  /// 月額料金
  String get monthlyPrice {
    switch (type) {
      case LicenseType.free:
        return '¥0';
      case LicenseType.pro:
        return '¥980';
      case LicenseType.enterprise:
        return '¥4,980';
    }
  }
}

/// 機能制限の設定
class FeatureLimits {
  static const int freeMaxTreesPerArea = 10;
  static const int freeMaxWorkAreas = 1;
  static const int freeMaxPhotos = 0;

  static const int proMaxTreesPerArea = -1; // 無制限
  static const int proMaxWorkAreas = -1;    // 無制限
  static const int proMaxPhotos = -1;       // 無制限
}

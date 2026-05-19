import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/license.dart';

final licenseManagerProvider = Provider<LicenseManager>((ref) {
  return LicenseManager();
});

final currentLicenseProvider = FutureProvider<License>((ref) async {
  final manager = ref.watch(licenseManagerProvider);
  return await manager.getCurrentLicense();
});

class LicenseManager {
  static const String _licenseTypeKey = 'license_type';
  static const String _expiryDateKey = 'license_expiry_date';

  /// 現在のライセンスを取得
  Future<License> getCurrentLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final typeString = prefs.getString(_licenseTypeKey);
    final expiryString = prefs.getString(_expiryDateKey);

    if (typeString == null) {
      // デフォルトは無料版
      return License.free();
    }

    final type = LicenseType.values.firstWhere(
      (t) => t.toString() == typeString,
      orElse: () => LicenseType.free,
    );

    final expiryDate = expiryString != null ? DateTime.parse(expiryString) : null;

    switch (type) {
      case LicenseType.free:
        return License.free();
      case LicenseType.pro:
        return License.pro(expiryDate: expiryDate);
      case LicenseType.enterprise:
        return License.enterprise(expiryDate: expiryDate);
    }
  }

  /// ライセンスを設定
  Future<void> setLicense(License license) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseTypeKey, license.type.toString());
    if (license.expiryDate != null) {
      await prefs.setString(_expiryDateKey, license.expiryDate!.toIso8601String());
    } else {
      await prefs.remove(_expiryDateKey);
    }
  }

  /// Pro版にアップグレード (デモ用)
  Future<void> upgradeToPro({int months = 1}) async {
    final expiryDate = DateTime.now().add(Duration(days: 30 * months));
    await setLicense(License.pro(expiryDate: expiryDate));
  }

  /// Enterprise版にアップグレード (デモ用)
  Future<void> upgradeToEnterprise({int months = 1}) async {
    final expiryDate = DateTime.now().add(Duration(days: 30 * months));
    await setLicense(License.enterprise(expiryDate: expiryDate));
  }

  /// 無料版にダウングレード
  Future<void> downgradeToFree() async {
    await setLicense(License.free());
  }

  /// 機能が利用可能かチェック
  Future<bool> canUseFeature(String featureKey) async {
    final license = await getCurrentLicense();
    return license.hasFeature(featureKey);
  }

  /// 機能制限チェック (樹木登録数)
  Future<bool> canAddTree(int currentTreeCount) async {
    final license = await getCurrentLicense();

    if (license.hasFeature('unlimited_trees')) {
      return true;
    }

    if (license.hasFeature('max_trees_per_area')) {
      return currentTreeCount < FeatureLimits.freeMaxTreesPerArea;
    }

    return true;
  }

  /// 残り登録可能本数
  Future<int?> getRemainingTrees(int currentTreeCount) async {
    final license = await getCurrentLicense();

    if (license.hasFeature('unlimited_trees')) {
      return null; // 無制限
    }

    if (license.hasFeature('max_trees_per_area')) {
      return (FeatureLimits.freeMaxTreesPerArea - currentTreeCount).clamp(0, 9999);
    }

    return null;
  }
}

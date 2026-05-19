// lib/core/platform/platform_check.dart
//
// プラットフォーム判定を Web 安全に扱うユーティリティ。
//
// 既存コードの `Platform.isAndroid` は Web 環境では
// UnsupportedError を投げる（dart:io を Web で評価した時点で壊れる）。
//
// このラッパーは kIsWeb を先に評価するため、Web でも安全に使える。
//
// 使用例:
//   if (PlatformCheck.isAndroid) { ... }
//   else if (PlatformCheck.isWeb) { ... }

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PlatformCheck {
  PlatformCheck._();

  static bool get isWeb => kIsWeb;

  static bool get isAndroid {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  static bool get isMacOS {
    if (kIsWeb) return false;
    try {
      return Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  static bool get isWindows {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  static bool get isLinux {
    if (kIsWeb) return false;
    try {
      return Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  /// プラットフォーム名を文字列で返す。
  /// フィードバック送信時のメタデータ等に使用。
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  /// モバイル系（Android / iOS）かどうか。
  /// UI のモバイル最適化レイアウト判定などに。
  static bool get isMobile => isAndroid || isIOS;

  /// デスクトップ系（macOS / Windows / Linux）かどうか。
  static bool get isDesktop => isMacOS || isWindows || isLinux;
}

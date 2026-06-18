// lib/core/platform/location_guard.dart
//
// Geolocator のラッパー。
//
// Web では Geolocation API が HTTPS 環境下でしかアクセスできず、
// モバイルとは挙動が異なるため、呼び出し側が毎回場合分けするのを避ける
// 目的で薄くラップしている。

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

/// 位置情報取得の結果。
class LocationPermissionResult {
  /// 許可されているかどうか。
  final bool granted;

  /// 許可されなかった場合の理由。
  /// - 'service_disabled': OS の位置情報サービスが OFF
  /// - 'denied': ユーザーが拒否
  /// - 'denied_forever': 永続的に拒否されている
  /// - 'https_required': Web で HTTPS 環境でない
  /// - 'unsupported': Web でブラウザが Geolocation API 非対応
  /// - null: 許可されている
  final String? reason;

  /// 現在の内部 permission 値（デバッグ用）。
  final LocationPermission? permission;

  const LocationPermissionResult({
    required this.granted,
    this.reason,
    this.permission,
  });

  /// UI 表示向けのメッセージ。
  String get message {
    switch (reason) {
      case 'service_disabled':
        return '端末の位置情報サービスを有効にしてください（設定 → プライバシー → 位置情報）。';
      case 'denied':
        return '位置情報の利用を許可してください。';
      case 'denied_forever':
        return 'アプリの位置情報が永続的に拒否されています。設定画面から許可してください。';
      case 'https_required':
        return 'ブラウザで位置情報を使うには HTTPS 接続が必要です。';
      case 'unsupported':
        return 'このブラウザは位置情報取得に対応していません。';
      default:
        return granted ? '位置情報の利用を許可しました。' : '位置情報が利用できません。';
    }
  }
}

class LocationGuard {
  LocationGuard._();

  /// 位置情報の利用権限を確認し、必要ならユーザーに要求する。
  ///
  /// 使用例:
  /// ```dart
  /// final result = await LocationGuard.ensurePermission();
  /// if (!result.granted) {
  ///   showDialog(...); // result.message を表示
  ///   return;
  /// }
  /// final pos = await Geolocator.getCurrentPosition();
  /// ```
  static Future<LocationPermissionResult> ensurePermission() async {
    // Web では HTTPS 必須。window.location.protocol を見られないので、
    // 失敗時にハンドリングする形で対応する。
    // （実運用では https チェックはサーバー側で担保する）

    try {
      // サービス有効か確認（Web では true を返すことが多い）
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && !kIsWeb) {
        return const LocationPermissionResult(
          granted: false,
          reason: 'service_disabled',
        );
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return LocationPermissionResult(
          granted: false,
          reason: 'denied',
          permission: permission,
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult(
          granted: false,
          reason: 'denied_forever',
          permission: permission,
        );
      }

      return LocationPermissionResult(
        granted: true,
        permission: permission,
      );
    } catch (e) {
      // Web で HTTPS 要件を満たさない場合や、非対応ブラウザの場合ここへ
      final msg = e.toString().toLowerCase();
      if (kIsWeb) {
        if (msg.contains('secure') || msg.contains('https')) {
          return const LocationPermissionResult(
            granted: false,
            reason: 'https_required',
          );
        }
        return const LocationPermissionResult(
          granted: false,
          reason: 'unsupported',
        );
      }
      return const LocationPermissionResult(
        granted: false,
        reason: 'denied',
      );
    }
  }

  /// 現在位置を一度だけ取得する簡便メソッド。
  /// 権限エラー時は null を返す。
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final perm = await ensurePermission();
    if (!perm.granted) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// 位置情報ストリーム。トラック記録用。
  ///
  /// 注意: Web ではタブが非アクティブになると停止する。
  /// 長時間トラッキングが必要な場合はモバイル版の利用を推奨する旨を
  /// ユーザーに伝えるか、wake lock などで補う。
  static Stream<Position> getPositionStream({
    int distanceFilter = 5,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}

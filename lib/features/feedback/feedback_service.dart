import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart'
    show LaunchMode, canLaunchUrl, launchUrl;

import '../../core/platform/platform_check.dart';

/// 問い合わせ先メールアドレス。プライバシーポリシーの連絡先と一致させる。
const String feedbackEmail = 'shinrin.app@gmail.com';

/// ユーザーのフィードバックを送信するためのサービス。
///
/// 1. mailto: でメーラーを起動し、端末情報・アプリバージョンを本文に自動挿入する。
/// 2. メーラーが起動できない端末では、share_plus でテキストを共有シートに流す。
class FeedbackService {
  const FeedbackService();

  /// フィードバック用のメール下書きを起動する。
  ///
  /// 成功時は true、失敗時は false を返す。失敗時は [Share.share] による
  /// フォールバックを自動的に試す。
  Future<bool> sendFeedback({String? subjectPrefix}) async {
    final diagnostics = await _collectDiagnostics();
    final subject = '${subjectPrefix ?? '【森林管理アプリ】お問い合わせ'}';
    final body = _buildBody(diagnostics);

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: feedbackEmail,
      query: _encodeQuery({'subject': subject, 'body': body}),
    );

    try {
      if (await canLaunchUrl(mailtoUri)) {
        return await launchUrl(
          mailtoUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      // フォールバックに進む
    }

    // メーラーが無い／権限が無い場合は共有シートへ
    await SharePlus.instance.share(ShareParams(
      text: '$subject\n\n$body',
      subject: subject,
    ));
    return true;
  }

  String _encodeQuery(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
  }

  String _buildBody(_Diagnostics d) {
    return '''
お問い合わせ内容をこの下にご記入ください。
------------------------------------------

（ここに状況・再現手順・期待する動作をお書きください）

------------------------------------------
以下は不具合調査用の情報です。削除せずそのまま送信いただけると助かります。

アプリ: ${d.appName} ${d.version} (${d.buildNumber})
プラットフォーム: ${d.platform}
OS バージョン: ${d.osVersion}
端末モデル: ${d.deviceModel}
送信日時: ${DateTime.now().toIso8601String()}
''';
  }

  Future<_Diagnostics> _collectDiagnostics() async {
    final pkg = await PackageInfo.fromPlatform();
    String platform = 'unknown';
    String osVersion = 'unknown';
    String deviceModel = 'unknown';

    try {
      final info = DeviceInfoPlugin();
      platform = PlatformCheck.platformName;

      if (PlatformCheck.isWeb) {
        // Web: ブラウザ情報
        try {
          final w = await info.webBrowserInfo;
          osVersion = w.userAgent ?? 'Web (unknown UA)';
          deviceModel = '${w.browserName.name} ${w.platform ?? ''}'.trim();
        } catch (_) {
          // device_info_plus の Web 実装が使えない場合もある
        }
      } else if (PlatformCheck.isAndroid) {
        final a = await info.androidInfo;
        osVersion = 'Android ${a.version.release} (SDK ${a.version.sdkInt})';
        deviceModel = '${a.manufacturer} ${a.model}';
      } else if (PlatformCheck.isIOS) {
        final i = await info.iosInfo;
        osVersion = '${i.systemName} ${i.systemVersion}';
        deviceModel = i.utsname.machine;
      }
    } catch (_) {
      // 情報取得に失敗してもフィードバック自体は送れるようにする
    }

    return _Diagnostics(
      appName: pkg.appName,
      version: pkg.version,
      buildNumber: pkg.buildNumber,
      platform: platform,
      osVersion: osVersion,
      deviceModel: deviceModel,
    );
  }
}

class _Diagnostics {
  const _Diagnostics({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
  });

  final String appName;
  final String version;
  final String buildNumber;
  final String platform;
  final String osVersion;
  final String deviceModel;
}

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../backup/presentation/backup_settings_page.dart';
import '../../feedback/feedback_tile.dart';

/// アプリ全体の設定画面。
///
/// - バックアップ設定へのリンク
/// - フィードバック送信
/// - プライバシーポリシー閲覧
/// - OSS ライセンス表示
/// - アプリバージョン表示
///
/// 新しい設定項目を足す際は、このファイルの `ListView` に `ListTile` を
/// 追加するだけで良い。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String _privacyPolicyUrl =
      'https://raitopapa.github.io/forest-app/privacy-policy.html';

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(_privacyPolicyUrl);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(content: Text('ブラウザを起動できませんでした。')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('プライバシーポリシーを開けませんでした: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const _SectionHeader('データ'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('バックアップ設定'),
            subtitle: const Text('クラウド同期の有効化・手動バックアップ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BackupSettingsPage(),
              ),
            ),
          ),
          const Divider(height: 1),
          const _SectionHeader('サポート'),
          const FeedbackTile(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openPrivacyPolicy(context),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('オープンソースライセンス'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              if (!context.mounted) return;
              showLicensePage(
                context: context,
                applicationName: '森林管理アプリ',
                applicationVersion: 'v${info.version} (${info.buildNumber})',
                applicationLegalese: '© 2026 森林管理アプリ',
              );
            },
          ),
          const Divider(height: 1),
          const _SectionHeader('アプリ情報'),
          const _AppVersionTile(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AppVersionTile extends StatelessWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final versionText = snapshot.hasData
            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '読み込み中...';
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('バージョン'),
          subtitle: Text(versionText),
        );
      },
    );
  }
}

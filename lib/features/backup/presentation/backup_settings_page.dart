import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/backup_service.dart';

/// Settings page for managing database backups.
class BackupSettingsPage extends ConsumerStatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  ConsumerState<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends ConsumerState<BackupSettingsPage> {
  List<BackupInfo> _backups = [];
  DateTime? _lastBackupTime;
  BackupFrequency _frequency = BackupFrequency.manual;
  bool _isLoading = true;
  bool _isOperating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final service = ref.read(backupServiceProvider);
    final backups = await service.getAvailableBackups();
    final lastBackup = await service.getLastBackupTime();
    final frequency = await service.getBackupFrequency();
    
    if (mounted) {
      setState(() {
        _backups = backups;
        _lastBackupTime = lastBackup;
        _frequency = frequency;
        _isLoading = false;
      });
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isOperating = true);
    
    final service = ref.read(backupServiceProvider);
    final result = await service.createBackup();
    
    if (mounted) {
      setState(() => _isOperating = false);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バックアップを作成しました'), backgroundColor: Colors.green),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バックアップの作成に失敗しました'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('バックアップを復元'),
        content: Text(
          'このバックアップ（${backup.formattedDate}）から復元しますか？\n\n'
          '⚠️ 現在のデータは上書きされます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('復元'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isOperating = true);
    
    final service = ref.read(backupServiceProvider);
    final success = await service.restoreFromBackup(backup.file);
    
    if (mounted) {
      setState(() => _isOperating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('復元が完了しました。アプリを再起動してください。'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('復元に失敗しました'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('バックアップを削除'),
        content: Text('${backup.formattedDate} のバックアップを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final service = ref.read(backupServiceProvider);
    await service.deleteBackup(backup.file);
    _loadData();
  }

  Future<void> _setFrequency(BackupFrequency frequency) async {
    final service = ref.read(backupServiceProvider);
    await service.setBackupFrequency(frequency);
    setState(() => _frequency = frequency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('バックアップ設定'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Last backup info
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.blue),
                        title: const Text('最終バックアップ'),
                        subtitle: Text(
                          _lastBackupTime != null
                              ? '${_lastBackupTime!.year}/${_lastBackupTime!.month}/${_lastBackupTime!.day} '
                                '${_lastBackupTime!.hour}:${_lastBackupTime!.minute.toString().padLeft(2, '0')}'
                              : 'まだバックアップがありません',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Manual backup button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isOperating ? null : _createBackup,
                        icon: const Icon(Icons.backup),
                        label: const Text('今すぐバックアップ'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Backup frequency
                    const Text('自動バックアップ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<BackupFrequency>(
                            title: const Text('手動のみ'),
                            subtitle: const Text('自動バックアップを無効にする'),
                            value: BackupFrequency.manual,
                            groupValue: _frequency,
                            onChanged: (v) => v != null ? _setFrequency(v) : null,
                          ),
                          RadioListTile<BackupFrequency>(
                            title: const Text('毎日'),
                            subtitle: const Text('24時間ごとに自動バックアップ'),
                            value: BackupFrequency.daily,
                            groupValue: _frequency,
                            onChanged: (v) => v != null ? _setFrequency(v) : null,
                          ),
                          RadioListTile<BackupFrequency>(
                            title: const Text('毎週'),
                            subtitle: const Text('7日ごとに自動バックアップ'),
                            value: BackupFrequency.weekly,
                            groupValue: _frequency,
                            onChanged: (v) => v != null ? _setFrequency(v) : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Backup list
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('バックアップ履歴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_backups.length}件', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_backups.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.folder_open, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('バックアップがありません', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_backups.length, (index) {
                        final backup = _backups[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.save, color: Colors.green),
                            title: Text(backup.formattedDate),
                            subtitle: Text(backup.formattedSize),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.restore),
                                  tooltip: '復元',
                                  onPressed: () => _restoreBackup(backup),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: '削除',
                                  onPressed: () => _deleteBackup(backup),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    Text(
                      '※ 最大5件のバックアップが保持されます',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                if (_isOperating)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }
}

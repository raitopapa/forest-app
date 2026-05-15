import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync_repository.dart';

class SyncStatusPage extends ConsumerStatefulWidget {
  const SyncStatusPage({super.key});

  @override
  ConsumerState<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends ConsumerState<SyncStatusPage> {
  SyncOverview? _overview;
  List<SyncConflict> _conflicts = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _lastSyncError;
  DateTime? _lastSyncAt;
  List<SyncRetryTask> _retryQueue = [];
  DateTime? _loadedAt;

  int get _cappedRetryCount => _retryQueue.where((t) => t.attempts >= 5).length;
  int get _dueRetryCount {
    final now = DateTime.now();
    return _retryQueue
        .where((t) => t.attempts < 5 && (t.nextRetryAt == null || !t.nextRetryAt!.isAfter(now)))
        .length;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final repo = ref.read(syncRepositoryProvider);
    final overview = await repo.getSyncOverview();
    final conflicts = await repo.getConflicts();
    final lastSyncError = await repo.getLastSyncError();
    final lastSyncAt = await repo.getLastSyncTime();
    final retryQueue = await repo.getRetryQueue();
    if (!mounted) return;
    setState(() {
      _overview = overview;
      _conflicts = conflicts.reversed.toList();
      _lastSyncError = lastSyncError;
      _lastSyncAt = lastSyncAt;
      retryQueue.sort((a, b) {
        final aTime = a.lastTriedAt ?? a.createdAt;
        final bTime = b.lastTriedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      _retryQueue = retryQueue;
      _loadedAt = DateTime.now();
      _isLoading = false;
    });
  }


  Future<void> _runSyncNow() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(syncRepositoryProvider).syncAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('同期が完了しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('同期失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
      _load();
    }
  }

  Future<void> _retryQueuedTasks() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(syncRepositoryProvider).retryFailedTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('再送キューを処理しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('再送失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
      _load();
    }
  }

  Future<void> _clearRetryQueue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('再送キューをクリア'),
        content: const Text('保留中の再送キューを削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('クリア')),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(syncRepositoryProvider).clearRetryQueue();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('再送キューをクリアしました')),
      );
    }
    _load();
  }

  Future<void> _removeRetryTask(SyncRetryTask task) async {
    await ref.read(syncRepositoryProvider).removeRetryTask(task.id, task.operation);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('再送タスクを削除しました')),
      );
    }
    _load();
  }

  Future<void> _clearConflicts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('競合ログをクリア'),
        content: const Text('競合履歴を削除します。よろしいですか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('クリア')),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(syncRepositoryProvider).clearConflicts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('競合ログをクリアしました')));
    }
    _load();
  }

  Future<void> _removeConflict(SyncConflict conflict) async {
    await ref.read(syncRepositoryProvider).removeConflict(
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          detectedAt: conflict.detectedAt,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('競合ログを1件削除しました')),
      );
    }
    _load();
  }

  Future<void> _updateConflictResolution(
    SyncConflict conflict,
    String resolution,
  ) async {
    await ref.read(syncRepositoryProvider).updateConflictResolution(
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          detectedAt: conflict.detectedAt,
          resolution: resolution,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('解決方針を更新: $resolution')),
      );
    }
    _load();
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '未実行';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('同期ステータス詳細'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: '更新'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sync, color: Colors.teal),
                    title: const Text('未同期データ'),
                    subtitle: Text(
                      '合計: ${_overview?.totalPending ?? 0}件\n'
                      '作業エリア: ${_overview?.pendingWorkAreas ?? 0}件 / 樹木: ${_overview?.pendingTrees ?? 0}件\n'
                      '更新: ${_formatDateTime(_loadedAt)}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _runSyncNow,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_isSyncing ? '同期中...' : '今すぐ同期'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('同期履歴'),
                    subtitle: Text(
                      '最終同期: ${_formatDateTime(_lastSyncAt)}\n最終エラー: ${_lastSyncError ?? 'なし'}',
                    ),
                  ),
                ),
                if (_retryQueue.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  if (_cappedRetryCount > 0)
                    Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.info_outline, color: Colors.orange),
                        title: Text('再送上限到達タスク: $_cappedRetryCount件'),
                        subtitle: const Text('タスク削除または内容修正後の再作成を推奨'),
                      ),
                    ),
                  Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.replay_circle_filled, color: Colors.orange),
                      title: Text('再送キュー: ${_retryQueue.length}件'),
                      subtitle: Text('即時再送可能: $_dueRetryCount件 / 最新: ${_retryQueue.first.reason}'),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isSyncing ? null : _clearRetryQueue,
                              child: const Text('キュークリア'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isSyncing ? null : _retryQueuedTasks,
                              child: const Text('再送'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._retryQueue.take(5).map(
                          (task) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.error_outline,
                              size: 18,
                              color: task.attempts >= 3 ? Colors.red : Colors.orange,
                            ),
                            title: Text(task.operation),
                            subtitle: Text(
                              '作成: ${_formatDateTime(task.createdAt)} / 最終試行: ${_formatDateTime(task.lastTriedAt)}\n'
                              '次回再試行: ${_formatDateTime(task.nextRetryAt)} / 再試行: ${task.attempts}回${task.attempts >= 5 ? " (上限到達)" : ""}\n'
                              '${task.reason}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'このタスクを削除',
                              onPressed: _isSyncing ? null : () => _removeRetryTask(task),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('競合ログ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton.icon(
                      onPressed: _conflicts.isEmpty ? null : _clearConflicts,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('クリア'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_conflicts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('競合ログはありません', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ..._conflicts.map(
                    (c) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        title: Text('${c.entityType} / ${c.entityId}'),
                        subtitle: Text(
                          '解決: ${c.resolution}\n'
                          'Local: ${c.localUpdatedAt.toIso8601String()}\n'
                          'Remote: ${c.remoteUpdatedAt.toIso8601String()}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          tooltip: '競合操作',
                          onSelected: (value) {
                            if (value == 'remove') {
                              _removeConflict(c);
                            } else {
                              _updateConflictResolution(c, value);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'local_kept', child: Text('ローカル優先に設定')),
                            PopupMenuItem(value: 'remote_accepted', child: Text('リモート優先に設定')),
                            PopupMenuDivider(),
                            PopupMenuItem(value: 'remove', child: Text('この競合ログを削除')),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ),
    );
  }
}

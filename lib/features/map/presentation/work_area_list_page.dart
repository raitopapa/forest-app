import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../data/tree_repository.dart';
import '../data/work_area_repository.dart';
import 'work_area_create_page.dart';
import 'map_page.dart';
import '../../backup/presentation/backup_settings_page.dart';
import '../../pdf/services/pdf_generator_service.dart';
import '../../plot/data/plot_repository.dart';
import '../../plot/presentation/plot_list_page.dart';
import '../../statistics/presentation/statistics_report_page.dart';

import '../../offline/data/sync_repository.dart';

class WorkAreaListPage extends ConsumerStatefulWidget {
  const WorkAreaListPage({super.key});

  @override
  ConsumerState<WorkAreaListPage> createState() => _WorkAreaListPageState();
}

class _WorkAreaListPageState extends ConsumerState<WorkAreaListPage> {
  late Future<List<Map<String, dynamic>>> _workAreasFuture;

  @override
  void initState() {
    super.initState();
    _refreshWorkAreas();
    _initialSync();
  }

  Future<void> _initialSync() async {
    await ref.read(syncRepositoryProvider).syncPull();
    _refreshWorkAreas();
  }

  void _refreshWorkAreas() {
    setState(() {
      _workAreasFuture = ref.read(workAreaRepositoryProvider).getWorkAreas();
    });
  }

  Future<void> _exportPdf(String workAreaId, String workAreaName) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('PDF を生成中...')));
    try {
      final trees = await ref.read(treeRepositoryProvider).getTrees(workAreaId);
      final plots = await ref.read(plotRepositoryProvider).getPlots(workAreaId);
      await ref.read(pdfGeneratorServiceProvider).generateFieldNotebook(
            workAreaName: workAreaName,
            trees: trees,
            plots: plots,
          );
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('PDF を共有シートで表示しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('PDF 生成に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作業エリア一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            tooltip: 'バックアップ設定',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BackupSettingsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('同期中...')));
              await ref.read(syncRepositoryProvider).syncPush();
              await ref.read(syncRepositoryProvider).syncPull();
              _refreshWorkAreas();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('同期完了')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _workAreasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          final workAreas = snapshot.data ?? [];

          if (workAreas.isEmpty) {
            return const Center(child: Text('作業エリアがまだありません。\n右下のボタンから追加してください。'));
          }

          return ListView.builder(
            itemCount: workAreas.length,
            itemBuilder: (context, index) {
              final area = workAreas[index];
              final areaId = area['id'] as String;
              final areaName = (area['name'] as String?) ?? '名称未設定';
              return ListTile(
                title: Text(areaName),
                subtitle: Text(area['description'] ?? ''),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'メニュー',
                  onSelected: (value) async {
                    switch (value) {
                      case 'plots':
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlotListPage(workAreaId: areaId),
                          ),
                        );
                        break;
                      case 'statistics':
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StatisticsReportPage(
                              workAreaId: areaId,
                              workAreaName: areaName,
                            ),
                          ),
                        );
                        break;
                      case 'pdf':
                        await _exportPdf(areaId, areaName);
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'plots',
                      child: ListTile(
                        leading: Icon(Icons.dashboard_outlined),
                        title: Text('プロット一覧'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'statistics',
                      child: ListTile(
                        leading: Icon(Icons.bar_chart),
                        title: Text('統計レポート'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'pdf',
                      child: ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('PDF 出力'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapPage(workAreaId: areaId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WorkAreaCreatePage()),
          );
          if (result == true) {
            _refreshWorkAreas();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../data/work_area_repository.dart';
import 'work_area_create_page.dart';
import 'map_page.dart';
import '../../backup/presentation/backup_settings_page.dart';

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
              if (mounted) {
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
              return ListTile(
                title: Text(area['name'] ?? '名称未設定'),
                subtitle: Text(area['description'] ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapPage(workAreaId: area['id']),
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

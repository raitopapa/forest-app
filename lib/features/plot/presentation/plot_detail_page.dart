import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plot_repository.dart';
import '../domain/models/plot.dart';
import '../../map/presentation/map_page.dart';

/// プロット詳細ページ
class PlotDetailPage extends ConsumerStatefulWidget {
  final Plot plot;
  final String workAreaId;

  const PlotDetailPage({
    super.key,
    required this.plot,
    required this.workAreaId,
  });

  @override
  ConsumerState<PlotDetailPage> createState() => _PlotDetailPageState();
}

class _PlotDetailPageState extends ConsumerState<PlotDetailPage> {
  PlotStatistics? _statistics;
  List<Map<String, dynamic>> _trees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await ref.read(plotRepositoryProvider).getPlotStatistics(widget.plot);
      final trees = await ref.read(plotRepositoryProvider).getTreesInPlot(widget.plot.id);

      if (mounted) {
        setState(() {
          _statistics = stats;
          _trees = trees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('読み込みエラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plot.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(workAreaId: widget.workAreaId),
                ),
              );
            },
            tooltip: 'マップで表示',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
            tooltip: '削除',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlotInfo(),
                    const SizedBox(height: 24),
                    _buildStatistics(),
                    const SizedBox(height: 24),
                    _buildTreeList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlotInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.plot.shape == PlotShape.circle
                      ? Icons.circle_outlined
                      : Icons.crop_square,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'プロット情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('形状', widget.plot.shape.displayName),
            _buildInfoRow('サイズ', _getSizeText()),
            _buildInfoRow('面積', '${widget.plot.area.toStringAsFixed(1)} m²'),
            _buildInfoRow(
              '中心位置',
              '${widget.plot.centerLat.toStringAsFixed(5)}, ${widget.plot.centerLng.toStringAsFixed(5)}',
            ),
            if (widget.plot.description != null) ...[
              const Divider(height: 24),
              Text(
                widget.plot.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSizeText() {
    if (widget.plot.shape == PlotShape.circle) {
      return '半径 ${widget.plot.size.toStringAsFixed(2)} m';
    } else {
      return '一辺 ${widget.plot.size.toStringAsFixed(2)} m';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    if (_statistics == null) return const SizedBox.shrink();

    final stats = _statistics!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '統計情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 主要統計
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '樹木本数',
                    '${stats.treeCount}本',
                    Icons.park,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '総材積',
                    '${stats.totalVolume.toStringAsFixed(2)} m³',
                    Icons.inventory_2,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ヘクタール当たり
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_graph, size: 20, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'ヘクタール当たり',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSimpleStat(
                          '蓄積量',
                          '${stats.standingVolume.toStringAsFixed(1)} m³/ha',
                        ),
                      ),
                      Expanded(
                        child: _buildSimpleStat(
                          '立木密度',
                          '${stats.treeDensity.toStringAsFixed(0)} 本/ha',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 平均値
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '平均樹高',
                    '${stats.averageHeight.toStringAsFixed(1)} m',
                    Icons.height,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '平均直径',
                    '${stats.averageDiameter.toStringAsFixed(1)} cm',
                    Icons.straighten,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 樹種構成
            if (stats.speciesCount.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '樹種構成',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...stats.speciesCount.entries.map((entry) {
                final percentage = (entry.value / stats.treeCount * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(entry.key),
                      ),
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage / 100,
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.green[400],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${entry.value}本 (${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTreeList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_list_bulleted, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  '樹木リスト',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_trees.length}本',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_trees.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.park, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        '樹木が登録されていません',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trees.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final tree = _trees[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.park, color: Colors.green),
                    title: Text(
                      tree['species'] ?? '不明',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _getTreeSubtitle(tree),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: tree['tree_number'] != null
                        ? Chip(
                            label: Text(
                              tree['tree_number'],
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.green[50],
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getTreeSubtitle(Map<String, dynamic> tree) {
    final parts = <String>[];

    if (tree['height'] != null) {
      parts.add('H: ${tree['height']} m');
    }
    if (tree['diameter'] != null) {
      parts.add('D: ${tree['diameter']} cm');
    }
    if (tree['volume'] != null) {
      parts.add('V: ${(tree['volume'] as double).toStringAsFixed(3)} m³');
    }

    return parts.isEmpty ? '-' : parts.join(' • ');
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('プロットを削除'),
        content: Text('「${widget.plot.name}」を削除しますか?\nプロット内の樹木のプロット関連付けは解除されますが、樹木自体は削除されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(plotRepositoryProvider).deletePlot(widget.plot.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロットを削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除エラー: $e')),
          );
        }
      }
    }
  }
}

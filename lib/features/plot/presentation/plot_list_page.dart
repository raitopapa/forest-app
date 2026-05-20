import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plot_repository.dart';
import '../domain/models/plot.dart';
import 'plot_detail_page.dart';

/// プロット一覧ページ
class PlotListPage extends ConsumerStatefulWidget {
  final String workAreaId;

  const PlotListPage({
    super.key,
    required this.workAreaId,
  });

  @override
  ConsumerState<PlotListPage> createState() => _PlotListPageState();
}

class _PlotListPageState extends ConsumerState<PlotListPage> {
  List<Plot> _plots = [];
  Map<String, PlotStatistics> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final plots = await ref.read(plotRepositoryProvider).getPlots(widget.workAreaId);
      final statistics = <String, PlotStatistics>{};

      for (final plot in plots) {
        final stats = await ref.read(plotRepositoryProvider).getPlotStatistics(plot);
        statistics[plot.id] = stats;
      }

      if (mounted) {
        setState(() {
          _plots = plots;
          _statistics = statistics;
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
        title: const Text('プロット調査'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'プロット調査について',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plots.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _plots.length,
                    itemBuilder: (context, index) {
                      final plot = _plots[index];
                      final stats = _statistics[plot.id];
                      return _buildPlotCard(plot, stats);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.control_camera, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'プロットがありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'マップ画面からプロットを作成してください',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlotCard(Plot plot, PlotStatistics? stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlotDetailPage(
                plot: plot,
                workAreaId: widget.workAreaId,
              ),
            ),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      plot.shape == PlotShape.circle
                          ? Icons.circle_outlined
                          : Icons.crop_square,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${plot.shape.displayName} • ${plot.area.toStringAsFixed(0)} m²',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),

              if (plot.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  plot.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],

              // 統計情報
              if (stats != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '本数',
                        '${stats.treeCount}本',
                        Icons.park,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '蓄積',
                        '${stats.standingVolume.toStringAsFixed(1)} m³/ha',
                        Icons.inventory_2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '平均樹高',
                        '${stats.averageHeight.toStringAsFixed(1)} m',
                        Icons.height,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '平均直径',
                        '${stats.averageDiameter.toStringAsFixed(1)} cm',
                        Icons.straighten,
                      ),
                    ),
                  ],
                ),
                if (stats.dominantSpecies != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '優占: ${stats.dominantSpecies}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('プロット調査について'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'プロット調査とは',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '固定されたエリア(プロット)内の全樹木を測定・記録する森林調査の標準手法です。',
              ),
              SizedBox(height: 16),
              Text(
                '主な用途',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 森林の蓄積量推定\n• 林分密度の把握\n• 樹種構成の分析\n• 成長量の調査'),
              SizedBox(height: 16),
              Text(
                '使い方',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. マップ画面でプロットの中心位置を決定\n'
                '2. プロットを作成（円形or方形）\n'
                '3. プロット内の樹木を登録\n'
                '4. 自動で統計値が計算されます',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

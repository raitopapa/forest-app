import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/statistics_service.dart';
import '../domain/models/work_area_statistics.dart';

/// 統計レポートページ
class StatisticsReportPage extends ConsumerStatefulWidget {
  final String workAreaId;
  final String workAreaName;

  const StatisticsReportPage({
    super.key,
    required this.workAreaId,
    required this.workAreaName,
  });

  @override
  ConsumerState<StatisticsReportPage> createState() => _StatisticsReportPageState();
}

class _StatisticsReportPageState extends ConsumerState<StatisticsReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WorkAreaStatistics? _statistics;
  ThinningSimulation? _thinningSimulation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stats = await ref.read(statisticsServiceProvider).calculateWorkAreaStatistics(
            widget.workAreaId,
            widget.workAreaName,
          );

      ThinningSimulation? simulation;
      if (stats.thinningMarkedCount > 0) {
        simulation = await ref.read(statisticsServiceProvider).simulateThinning(stats);
      }

      if (mounted) {
        setState(() {
          _statistics = stats;
          _thinningSimulation = simulation;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('統計計算エラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('統計レポート'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '概要', icon: Icon(Icons.dashboard)),
            Tab(text: '樹種別', icon: Icon(Icons.eco)),
            Tab(text: '林班別', icon: Icon(Icons.map)),
            Tab(text: '間伐', icon: Icon(Icons.content_cut)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: '再計算',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _statistics != null ? () => _exportReport() : null,
            tooltip: 'エクスポート',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _statistics == null
              ? _buildEmptyState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildSpeciesTab(),
                    _buildSectionTab(),
                    _buildThinningTab(),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'データがありません',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final stats = _statistics!;

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダーカード
            Card(
              color: Colors.green[700],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.workAreaName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '総調査本数: ${stats.totalTreeCount}本',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 主要統計
            const Text(
              '主要統計',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '総材積',
                    '${stats.totalVolume.toStringAsFixed(2)} m³',
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '平均樹高',
                    '${stats.averageHeight.toStringAsFixed(1)} m',
                    Icons.height,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '平均直径',
                    '${stats.averageDiameter.toStringAsFixed(1)} cm',
                    Icons.straighten,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '平均樹齢',
                    stats.averageAge > 0 ? '${stats.averageAge.toStringAsFixed(0)} 年' : '-',
                    Icons.calendar_today,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // プロット統計
            if (stats.plotCount > 0) ...[
              const Text(
                'プロット統計',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('プロット数', '${stats.plotCount}箇所'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        '平均蓄積量',
                        '${stats.averageStandingVolume.toStringAsFixed(1)} m³/ha',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        '平均立木密度',
                        '${stats.averageTreeDensity.toStringAsFixed(0)} 本/ha',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 樹勢分布
            if (stats.vigorBreakdown.isNotEmpty) ...[
              const Text(
                '樹勢分布',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildVigorBar('A級 (優良)', stats.vigorBreakdown['A'] ?? 0, Colors.green),
                      const SizedBox(height: 8),
                      _buildVigorBar('B級 (良好)', stats.vigorBreakdown['B'] ?? 0, Colors.orange),
                      const SizedBox(height: 8),
                      _buildVigorBar('C級 (不良)', stats.vigorBreakdown['C'] ?? 0, Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 病虫害情報
            if (stats.pestDiseaseCount > 0) ...[
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '病虫害発生',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${stats.pestDiseaseCount}本 (${stats.pestDiseaseRate.toStringAsFixed(1)}%)',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesTab() {
    final stats = _statistics!;
    final sortedSpecies = stats.speciesBreakdown.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedSpecies.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '樹種別統計 (${sortedSpecies.length}樹種)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
              ],
            );
          }

          final entry = sortedSpecies[index - 1];
          final speciesStats = entry.value;
          final percentage = speciesStats.getPercentage(stats.totalTreeCount);
          final volumePercentage = speciesStats.getVolumePercentage(stats.totalVolume);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: const Icon(Icons.eco, color: Colors.green),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${speciesStats.count}本 (${percentage.toStringAsFixed(1)}%) • ${speciesStats.totalVolume.toStringAsFixed(2)} m³',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('本数', '${speciesStats.count}本 (${percentage.toStringAsFixed(1)}%)'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        '材積',
                        '${speciesStats.totalVolume.toStringAsFixed(2)} m³ (${volumePercentage.toStringAsFixed(1)}%)',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('平均樹高', '${speciesStats.averageHeight.toStringAsFixed(1)} m'),
                      const SizedBox(height: 8),
                      _buildInfoRow('平均直径', '${speciesStats.averageDiameter.toStringAsFixed(1)} cm'),
                      if (speciesStats.averageAge > 0) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('平均樹齢', '${speciesStats.averageAge.toStringAsFixed(0)} 年'),
                      ],
                      if (speciesStats.thinningMarkedCount > 0) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          '間伐対象',
                          '${speciesStats.thinningMarkedCount}本 (${speciesStats.thinningRate.toStringAsFixed(1)}%)',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          '間伐材積',
                          '${speciesStats.thinningMarkedVolume.toStringAsFixed(2)} m³',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTab() {
    final stats = _statistics!;
    final sortedSections = stats.sectionBreakdown.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));

    if (sortedSections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '林班・小班情報がありません',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedSections.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '林班・小班別統計 (${sortedSections.length}区画)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
              ],
            );
          }

          final entry = sortedSections[index - 1];
          final sectionStats = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: Text(
                sectionStats.sectionName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${sectionStats.count}本 • ${sectionStats.totalVolume.toStringAsFixed(2)} m³',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('本数', '${sectionStats.count}本'),
                      const SizedBox(height: 8),
                      _buildInfoRow('材積', '${sectionStats.totalVolume.toStringAsFixed(2)} m³'),
                      if (sectionStats.speciesCount.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text('樹種構成', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...sectionStats.speciesCount.entries.map((e) {
                          final percentage = (e.value / sectionStats.count * 100);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Expanded(child: Text(e.key)),
                                Text('${e.value}本 (${percentage.toStringAsFixed(1)}%)'),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThinningTab() {
    final stats = _statistics!;

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '間伐計画',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 現状
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('現状', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildInfoRow('総本数', '${stats.totalTreeCount}本'),
                    const SizedBox(height: 8),
                    _buildInfoRow('総材積', '${stats.totalVolume.toStringAsFixed(2)} m³'),
                    const SizedBox(height: 8),
                    _buildInfoRow('間伐対象', '${stats.thinningMarkedCount}本'),
                    const SizedBox(height: 8),
                    _buildInfoRow('間伐材積', '${stats.thinningMarkedVolume.toStringAsFixed(2)} m³'),
                    const SizedBox(height: 8),
                    _buildInfoRow('間伐率', '${stats.thinningRate.toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // シミュレーション結果
            if (_thinningSimulation != null) ...[
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calculate, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('間伐シミュレーション', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('間伐後本数', '${_thinningSimulation!.afterTreeCount}本'),
                      const SizedBox(height: 8),
                      _buildInfoRow('間伐後材積', '${_thinningSimulation!.afterVolume.toStringAsFixed(2)} m³'),
                      const SizedBox(height: 8),
                      _buildInfoRow('間伐後密度', '${_thinningSimulation!.afterDensity.toStringAsFixed(0)} 本/ha'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 経済性
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green),
                          SizedBox(width: 8),
                          Text('経済性分析', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        '推定収入',
                        '¥${_formatCurrency(_thinningSimulation!.estimatedRevenue)}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        '推定費用',
                        '¥${_formatCurrency(_thinningSimulation!.estimatedCost)}',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        '推定利益',
                        '¥${_formatCurrency(_thinningSimulation!.estimatedProfit)}',
                        valueColor: _thinningSimulation!.estimatedProfit >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '間伐対象の樹木がマークされていません',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVigorBar(String label, int count, Color color) {
    final percentage = _statistics!.totalTreeCount > 0
        ? (count / _statistics!.totalTreeCount * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('$count本 (${percentage.toStringAsFixed(1)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}万';
    }
    return amount.toStringAsFixed(0);
  }

  Future<void> _exportReport() async {
    // TODO: レポートのエクスポート機能を実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('エクスポート機能は近日実装予定です')),
    );
  }
}

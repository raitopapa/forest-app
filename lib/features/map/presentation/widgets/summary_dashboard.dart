import 'package:flutter/material.dart';
import '../../domain/models/map_object.dart';

/// Summary dashboard showing statistics for the current work area.
class SummaryDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> trees;
  final List<MapObject> mapObjects;
  final double? trackDistance; // in meters
  final int pendingSyncCount;
  final int retryQueueCount;
  final double? totalAreaM2;
  final DateTime? lastSyncAt;
  final String? lastSyncError;
  final int todayUpdatedCount;
  final int weekUpdatedCount;
  final int monthUpdatedCount;
  final Map<String, int>? speciesCount;

  const SummaryDashboard({
    super.key,
    required this.trees,
    required this.mapObjects,
    this.trackDistance,
    this.pendingSyncCount = 0,
    this.retryQueueCount = 0,
    this.totalAreaM2,
    this.lastSyncAt,
    this.lastSyncError,
    this.todayUpdatedCount = 0,
    this.weekUpdatedCount = 0,
    this.monthUpdatedCount = 0,
    this.speciesCount,
  });

  @override
  Widget build(BuildContext context) {
    final pointCount = mapObjects.where((o) => o.type == MapObjectType.point).length;
    final lineCount = mapObjects.where((o) => o.type == MapObjectType.line).length;
    final polygonCount = mapObjects.where((o) => o.type == MapObjectType.polygon).length;
    final photoCount = mapObjects.where((o) => o.photoPath != null).length +
        trees.where((t) => t['photo_path'] != null || t['photo_url'] != null).length;
    final speciesData = speciesCount ?? _buildSpeciesCountFromTrees();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.dashboard, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                '調査サマリー',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          
          // Stats Grid
          Row(
            children: [
              Expanded(child: _buildStatCard('🌳', '樹木', trees.length)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('📍', 'ポイント', pointCount)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('🔁', '未同期', pendingSyncCount)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('⏳', '再送キュー', retryQueueCount)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('📏', 'ライン', lineCount)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '⬡',
                  '面積',
                  totalAreaM2 != null
                      ? (totalAreaM2! >= 10000
                          ? '${(totalAreaM2! / 10000).toStringAsFixed(2)} ha'
                          : '${totalAreaM2!.toStringAsFixed(0)} m²')
                      : '$polygonCount 件',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('📸', '写真', photoCount)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '🚶',
                  '歩行距離',
                  trackDistance != null 
                      ? '${(trackDistance! / 1000).toStringAsFixed(2)} km'
                      : '-',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('🗓️', '本日の更新', todayUpdatedCount)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('📅', '直近7日', weekUpdatedCount)),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('🗓️', '直近30日', monthUpdatedCount)),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
          
          const SizedBox(height: 16),

          if (lastSyncAt != null || (lastSyncError?.isNotEmpty ?? false))
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '最終同期: ${_formatDateTime(lastSyncAt)}'
                '${(lastSyncError?.isNotEmpty ?? false) ? ' / エラー: $lastSyncError' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),

          const SizedBox(height: 8),

          if (pendingSyncCount > 0 || retryQueueCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                '未同期データがあります。圏外作業後は同期ステータス画面で再送/競合確認を行ってください。',
                style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
              ),
            ),

          const SizedBox(height: 16),

          // Species breakdown
          if (speciesData.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('樹種内訳', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            _buildSpeciesBreakdown(speciesData),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Map<String, int> _buildSpeciesCountFromTrees() {
    final speciesCount = <String, int>{};
    for (final tree in trees) {
      final species = tree['species'] as String? ?? '不明';
      speciesCount[species] = (speciesCount[species] ?? 0) + 1;
    }
    return speciesCount;
  }

  Widget _buildSpeciesBreakdown(Map<String, int> speciesCount) {
    final sortedSpecies = speciesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedSpecies.take(6).map((e) {
        return Chip(
          avatar: const Icon(Icons.park, size: 16, color: Colors.green),
          label: Text('${e.key}: ${e.value}本'),
          backgroundColor: Colors.green[50],
        );
      }).toList(),
    );
  }
}

/// Show summary dashboard as a bottom sheet.
void showSummaryDashboard(
  BuildContext context, {
  required List<Map<String, dynamic>> trees,
  required List<MapObject> mapObjects,
  double? trackDistance,
  int pendingSyncCount = 0,
  int retryQueueCount = 0,
  double? totalAreaM2,
  DateTime? lastSyncAt,
  String? lastSyncError,
  int todayUpdatedCount = 0,
  int weekUpdatedCount = 0,
  int monthUpdatedCount = 0,
  Map<String, int>? speciesCount,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => SummaryDashboard(
      trees: trees,
      mapObjects: mapObjects,
      trackDistance: trackDistance,
      pendingSyncCount: pendingSyncCount,
      retryQueueCount: retryQueueCount,
      totalAreaM2: totalAreaM2,
      lastSyncAt: lastSyncAt,
      lastSyncError: lastSyncError,
      todayUpdatedCount: todayUpdatedCount,
      weekUpdatedCount: weekUpdatedCount,
      monthUpdatedCount: monthUpdatedCount,
      speciesCount: speciesCount,
    ),
  );
}

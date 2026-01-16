import 'package:flutter/material.dart';
import '../domain/models/map_object.dart';

/// Summary dashboard showing statistics for the current work area.
class SummaryDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> trees;
  final List<MapObject> mapObjects;
  final double? trackDistance; // in meters

  const SummaryDashboard({
    super.key,
    required this.trees,
    required this.mapObjects,
    this.trackDistance,
  });

  @override
  Widget build(BuildContext context) {
    final pointCount = mapObjects.where((o) => o.type == MapObjectType.point).length;
    final lineCount = mapObjects.where((o) => o.type == MapObjectType.line).length;
    final polygonCount = mapObjects.where((o) => o.type == MapObjectType.polygon).length;
    final photoCount = mapObjects.where((o) => o.photoPath != null).length + 
                       trees.where((t) => t['photo_path'] != null || t['photo_url'] != null).length;

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
              Expanded(child: _buildStatCard('📏', 'ライン', lineCount)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('⬡', 'ポリゴン', polygonCount)),
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
          
          const SizedBox(height: 16),
          
          // Species breakdown
          if (trees.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('樹種内訳', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            _buildSpeciesBreakdown(),
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

  Widget _buildSpeciesBreakdown() {
    final speciesCount = <String, int>{};
    for (final tree in trees) {
      final species = tree['species'] as String? ?? '不明';
      speciesCount[species] = (speciesCount[species] ?? 0) + 1;
    }

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
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => SummaryDashboard(
      trees: trees,
      mapObjects: mapObjects,
      trackDistance: trackDistance,
    ),
  );
}

import 'package:flutter/material.dart';
import '../../../../core/platform/image_source.dart';
import '../../domain/models/tree.dart';

/// 拡張樹木詳細表示ダイアログ
class TreeDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> tree;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TreeDetailsDialog({
    super.key,
    required this.tree,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final species = tree['species'] ?? '不明な樹種';
    final photoPath = tree['photo_path'] as String?;
    final photoUrl = tree['photo_url'] as String?;

    // 新規フィールド
    final volume = tree['volume'] as double?;
    final age = tree['age'] as int?;
    final forestSection = tree['forest_section'] as String?;
    final subSection = tree['sub_section'] as String?;
    final treeNumber = tree['tree_number'] as String?;
    final vigorStr = tree['vigor'] as String?;
    final vigor = TreeVigorExtension.fromDbString(vigorStr);
    final pestDisease = tree['pest_disease'] as String?;
    final slope = tree['slope'] as double?;
    final aspectStr = tree['aspect'] as String?;
    final aspect = AspectExtension.fromDbString(aspectStr);
    final notes = tree['notes'] as String?;
    final markedForThinning = tree['marked_for_thinning'] as bool? ?? false;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: markedForThinning ? Colors.orange[700] : Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  markedForThinning ? Icons.content_cut : Icons.park,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (treeNumber != null)
                        Text(
                          '立木番号: $treeNumber',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (markedForThinning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '間伐対象',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // コンテンツ
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 写真 (path 優先 -> URL fallback、どちらも無ければ park アイコンを表示)
                  if (photoPath != null || photoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ImageSourceWidget(
                        path: photoPath,
                        url: photoUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.park, size: 64, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // 基本情報セクション
                  _buildSectionTitle('基本情報', Icons.info),
                  const SizedBox(height: 12),
                  _buildInfoGrid([
                    _InfoItem('樹高', tree['height'] != null ? '${tree['height']} m' : '-', Icons.height),
                    _InfoItem('胸高直径', tree['diameter'] != null ? '${tree['diameter']} cm' : '-', Icons.straighten),
                    _InfoItem('材積', volume != null ? '${volume.toStringAsFixed(4)} m³' : '-', Icons.calculate),
                    _InfoItem('樹齢', age != null ? '$age 年' : '-', Icons.calendar_today),
                  ]),
                  if (tree['health_status'] != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoTile(Icons.health_and_safety, '健康状態', tree['health_status']),
                  ],

                  // 位置情報セクション
                  const SizedBox(height: 24),
                  _buildSectionTitle('位置情報', Icons.location_on),
                  const SizedBox(height: 12),
                  _buildInfoGrid([
                    if (forestSection != null) _InfoItem('林班', forestSection, Icons.map),
                    if (subSection != null) _InfoItem('小班', subSection, Icons.location_searching),
                    if (slope != null) _InfoItem('傾斜', '${slope.toStringAsFixed(1)}°', Icons.terrain),
                    if (aspect != null) _InfoItem('方位', _getAspectLabel(aspect), Icons.explore),
                  ]),

                  // 評価・状態セクション
                  if (vigor != null || pestDisease != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('評価・状態', Icons.assessment),
                    const SizedBox(height: 12),
                    if (vigor != null)
                      _buildInfoTile(Icons.star, '樹勢', _getVigorLabel(vigor)),
                    if (pestDisease != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoTile(Icons.bug_report, '病虫害', pestDisease),
                    ],
                  ],

                  // 備考
                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('備考', Icons.note),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(notes),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // フッター
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                if (onDelete != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete!();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('削除', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                if (onDelete != null && onEdit != null) const SizedBox(width: 16),
                if (onEdit != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit!();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('編集'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return Container(
          width: (items.length == 1) ? double.infinity : null,
          constraints: BoxConstraints(
            minWidth: items.length == 1 ? double.infinity : 140,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 16, color: Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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

  String _getVigorLabel(TreeVigor vigor) {
    switch (vigor) {
      case TreeVigor.excellent:
        return 'A級 (優良)';
      case TreeVigor.good:
        return 'B級 (良好)';
      case TreeVigor.poor:
        return 'C級 (不良)';
    }
  }

  String _getAspectLabel(Aspect aspect) {
    switch (aspect) {
      case Aspect.north:
        return '北';
      case Aspect.northEast:
        return '北東';
      case Aspect.east:
        return '東';
      case Aspect.southEast:
        return '南東';
      case Aspect.south:
        return '南';
      case Aspect.southWest:
        return '南西';
      case Aspect.west:
        return '西';
      case Aspect.northWest:
        return '北西';
    }
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  _InfoItem(this.label, this.value, this.icon);
}

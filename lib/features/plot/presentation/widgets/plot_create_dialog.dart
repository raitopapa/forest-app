import 'package:flutter/material.dart';
import '../../domain/models/plot.dart';

/// プロット作成ダイアログ
class PlotCreateDialog extends StatefulWidget {
  final String locationText;
  final Function({
    required String name,
    required PlotShape shape,
    required double size,
    String? description,
  }) onSubmit;

  const PlotCreateDialog({
    super.key,
    required this.locationText,
    required this.onSubmit,
  });

  @override
  State<PlotCreateDialog> createState() => _PlotCreateDialogState();
}

class _PlotCreateDialogState extends State<PlotCreateDialog> {
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  PlotShape _selectedShape = PlotShape.circle;

  // 標準プロットサイズ
  static const Map<String, double> _standardSizes = {
    '100m²': 5.64, // 半径 or 一辺 (円形: r=5.64m, 方形: 10m×10m)
    '200m²': 7.98,
    '300m²': 9.77,
    '400m²': 11.28,
    '500m²': 12.62,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.control_camera, color: Colors.green),
          SizedBox(width: 8),
          Text('プロットを作成'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 中心位置
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '中心位置: ${widget.locationText}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // プロット名
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'プロット名 *',
                hintText: '例: プロット1, 標準地A',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),

            // 形状選択
            const Text('形状', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<PlotShape>(
              segments: const [
                ButtonSegment(
                  value: PlotShape.circle,
                  label: Text('円形'),
                  icon: Icon(Icons.circle_outlined),
                ),
                ButtonSegment(
                  value: PlotShape.square,
                  label: Text('方形'),
                  icon: Icon(Icons.crop_square),
                ),
              ],
              selected: {_selectedShape},
              onSelectionChanged: (Set<PlotShape> selected) {
                setState(() => _selectedShape = selected.first);
              },
            ),
            const SizedBox(height: 16),

            // サイズ入力
            TextField(
              controller: _sizeController,
              decoration: InputDecoration(
                labelText: _selectedShape == PlotShape.circle ? '半径 (m) *' : '一辺の長さ (m) *',
                hintText: '10',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.straighten),
                helperText: _getAreaHelperText(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}), // 面積表示を更新
            ),
            const SizedBox(height: 8),

            // 標準サイズのクイック選択
            const Text('標準サイズ', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: _standardSizes.entries.map((entry) {
                return OutlinedButton(
                  onPressed: () {
                    if (_selectedShape == PlotShape.circle) {
                      _sizeController.text = entry.value.toStringAsFixed(2);
                    } else {
                      _sizeController.text = (entry.value * 1.77).toStringAsFixed(2);
                    }
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(entry.key, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 説明
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                hintText: '調査目的やメモ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('作成'),
        ),
      ],
    );
  }

  String? _getAreaHelperText() {
    final size = double.tryParse(_sizeController.text);
    if (size == null || size <= 0) return null;

    double area;
    if (_selectedShape == PlotShape.circle) {
      area = 3.14159265359 * size * size;
    } else {
      area = size * size;
    }

    return '面積: ${area.toStringAsFixed(1)} m²';
  }

  void _handleSubmit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロット名を入力してください')),
      );
      return;
    }

    final size = double.tryParse(_sizeController.text);
    if (size == null || size <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('有効なサイズを入力してください')),
      );
      return;
    }

    widget.onSubmit(
      name: _nameController.text,
      shape: _selectedShape,
      size: size,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );

    Navigator.pop(context);
  }
}

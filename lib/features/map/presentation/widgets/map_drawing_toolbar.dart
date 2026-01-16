import 'package:flutter/material.dart';

enum DrawingToolType {
  none,
  point,
  line,
  polygon,
}

class MapDrawingToolbar extends StatelessWidget {
  final DrawingToolType activeTool;
  final ValueChanged<DrawingToolType> onToolSelected;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool hasDrawingData;

  const MapDrawingToolbar({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
    required this.onSave,
    required this.onCancel,
    required this.hasDrawingData,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTool == DrawingToolType.none) {
      return Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_location_alt),
              tooltip: 'ポイント追加',
              onPressed: () => onToolSelected(DrawingToolType.point),
            ),
            IconButton(
              icon: const Icon(Icons.timeline),
              tooltip: 'ライン描画 (距離)',
              onPressed: () => onToolSelected(DrawingToolType.line),
            ),
            IconButton(
              icon: const Icon(Icons.pentagon_outlined),
              tooltip: 'ポリゴン描画 (面積)',
              onPressed: () => onToolSelected(DrawingToolType.polygon),
            ),
          ],
        ),
      );
    }

    return Card(
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _getToolName(activeTool),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (hasDrawingData)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: onSave,
              tooltip: '保存',
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onCancel,
            tooltip: 'キャンセル',
          ),
        ],
      ),
    );
  }

  String _getToolName(DrawingToolType type) {
    switch (type) {
      case DrawingToolType.point:
        return 'ポイント配置';
      case DrawingToolType.line:
        return 'ライン描画';
      case DrawingToolType.polygon:
        return 'ポリゴン描画';
      case DrawingToolType.none:
        return '';
    }
  }
}

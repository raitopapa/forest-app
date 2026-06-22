import 'package:flutter/material.dart';
import '../../domain/models/map_layer.dart';

/// 地図のレイヤー（標準 / 衛星 / 地形 / 標高）を切り替えるパネル。
/// アイコンだけだと気づかれにくいので、短いラベルを併記して見つけやすくする。
class MapLayerSelector extends StatelessWidget {
  final MapLayerType currentLayer;
  final ValueChanged<MapLayerType> onLayerChanged;

  const MapLayerSelector({
    super.key,
    required this.currentLayer,
    required this.onLayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tile(context, MapLayerType.standard, Icons.map, '標準'),
            _tile(context, MapLayerType.satellite, Icons.satellite_alt, '衛星'),
            _tile(context, MapLayerType.terrain, Icons.terrain, '地形'),
            _tile(context, MapLayerType.topo, Icons.gradient, '標高'),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    MapLayerType type,
    IconData icon,
    String label,
  ) {
    final isSelected = currentLayer == type;
    final color =
        isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600;
    return Tooltip(
      message: MapLayer.getLayer(type).name,
      child: InkWell(
        onTap: () => onLayerChanged(type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.0,
                  color: color,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

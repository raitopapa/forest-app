import 'package:flutter/material.dart';
import '../../domain/models/map_layer.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLayerButton(context, MapLayerType.standard, Icons.map),
            const Divider(height: 1),
            _buildLayerButton(context, MapLayerType.satellite, Icons.satellite_alt),
            const Divider(height: 1),
            _buildLayerButton(context, MapLayerType.topo, Icons.terrain),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerButton(BuildContext context, MapLayerType type, IconData icon) {
    final isSelected = currentLayer == type;
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      tooltip: MapLayer.getLayer(type).name,
      onPressed: () => onLayerChanged(type),
    );
  }
}

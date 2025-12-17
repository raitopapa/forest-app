import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../data/work_area_repository.dart';

class WorkAreaCreatePage extends ConsumerStatefulWidget {
  const WorkAreaCreatePage({super.key});

  @override
  ConsumerState<WorkAreaCreatePage> createState() => _WorkAreaCreatePageState();
}

class _WorkAreaCreatePageState extends ConsumerState<WorkAreaCreatePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<LatLng> _points = [];
  bool _isDrawing = false;
  bool _isLoading = false;

  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (_isDrawing) {
      setState(() {
        _points.add(point);
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称を入力してください')),
      );
      return;
    }
    if (_points.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エリアを3点以上で指定してください')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final pointsList = _points.map((p) => [p.latitude, p.longitude]).toList();
      await ref.read(workAreaRepositoryProvider).createWorkArea(
            name: _nameController.text,
            description: _descriptionController.text,
            points: pointsList,
          );
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作業エリア作成'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'エリア名称'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '説明'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('境界線: ${_points.length}点'),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isDrawing = !_isDrawing;
                          if (!_isDrawing) _points.clear();
                        });
                      },
                      icon: Icon(_isDrawing ? Icons.clear : Icons.edit),
                      label: Text(_isDrawing ? 'リセット' : '描画開始'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(35.6812, 139.7671), // Tokyo Station
                initialZoom: 15.0,
                onTap: _handleTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.forest_app.app',
                ),
                PolygonLayer(
                  polygons: [
                    if (_points.isNotEmpty)
                      Polygon(
                        points: _points,
                        color: Colors.blue.withOpacity(0.3),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                        isFilled: true,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: _points
                      .map((p) => Marker(
                            point: p,
                            width: 10,
                            height: 10,
                            child: const Icon(Icons.circle, size: 10, color: Colors.blue),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

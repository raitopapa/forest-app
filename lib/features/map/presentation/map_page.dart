import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../data/tree_repository.dart';

class MapPage extends ConsumerStatefulWidget {
  final String workAreaId;
  const MapPage({super.key, required this.workAreaId});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  late final MapController _mapController;
  List<Map<String, dynamic>> _trees = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _refreshTrees();
  }

  Future<void> _refreshTrees() async {
    final trees = await ref.read(treeRepositoryProvider).getTrees(widget.workAreaId);
    if (mounted) {
      setState(() {
        _trees = trees;
      });
    }
  }

  void _showAddTreeDialog() {
    final center = _mapController.camera.center;
    final speciesController = TextEditingController();
    final heightController = TextEditingController();
    final diameterController = TextEditingController();
    String? photoPath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('樹木を登録'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('位置: ${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}'),
                TextField(controller: speciesController, decoration: const InputDecoration(labelText: '樹種')),
                TextField(controller: heightController, decoration: const InputDecoration(labelText: '樹高 (m)'), keyboardType: TextInputType.number),
                TextField(controller: diameterController, decoration: const InputDecoration(labelText: '胸高直径 (cm)'), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                if (photoPath != null)
                  SizedBox(
                    height: 100,
                    child: Image.file(File(photoPath!)),
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() {
                        photoPath = pickedFile.path;
                      });
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('写真を撮る'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(treeRepositoryProvider).createTree(
                        species: speciesController.text,
                        height: double.tryParse(heightController.text),
                        diameter: double.tryParse(diameterController.text),
                        lat: center.latitude,
                        lng: center.longitude,
                        workAreaId: widget.workAreaId,
                        photoPath: photoPath,
                      );
                  if (mounted) {
                    Navigator.pop(context);
                    _refreshTrees();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
                }
              },
              child: const Text('登録'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTreeDetails(Map<String, dynamic> tree) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tree['species'] ?? '不明な樹種'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tree['photo_path'] != null && File(tree['photo_path']).existsSync())
                Image.file(File(tree['photo_path']), height: 200, fit: BoxFit.cover)
              else if (tree['photo_url'] != null)
                Image.network(tree['photo_url'], height: 200, fit: BoxFit.cover)
              else
                const SizedBox(height: 200, child: Center(child: Icon(Icons.image_not_supported, size: 50))),
              const SizedBox(height: 16),
              Text('樹高: ${tree['height']?.toString() ?? '-'} m'),
              Text('胸高直径: ${tree['diameter']?.toString() ?? '-'} cm'),
              Text('健康状態: ${tree['health_status'] ?? '-'}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forest Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(35.6812, 139.7671),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.forest_app.app',
          ),
          MarkerLayer(
            markers: _trees.map((tree) {
              // Parse WKT POINT(lng lat)
              final wkt = tree['location'] as String;
              final coords = wkt.substring(6, wkt.length - 1).split(' ');
              final lng = double.parse(coords[0]);
              final lat = double.parse(coords[1]);

              return Marker(
                point: LatLng(lat, lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showTreeDetails(tree),
                  child: const Icon(Icons.park, color: Colors.green, size: 40),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTreeDialog,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}

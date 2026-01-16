import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../data/tree_repository.dart';
import '../data/map_object_repository.dart';
import '../domain/models/map_layer.dart';
import '../domain/models/map_object.dart';
import 'widgets/map_layer_selector.dart';
import 'widgets/map_drawing_toolbar.dart';
import '../../export/services/export_service.dart';
import '../domain/services/measurement_service.dart';
import '../domain/services/track_recorder_service.dart';
import 'photo_gallery_page.dart';
import 'widgets/attribute_editor_dialog.dart';
import 'widgets/summary_dashboard.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class MapPage extends ConsumerStatefulWidget {
  final String workAreaId;
  const MapPage({super.key, required this.workAreaId});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  late final MapController _mapController;
  final _picker = ImagePicker();
  final _mapKey = GlobalKey(); // For map screenshot
  
  // Data
  List<Map<String, dynamic>> _trees = [];
  List<MapObject> _mapObjects = [];
  
  // UI State
  MapLayerType _currentLayerType = MapLayerType.standard;
  DrawingToolType _activeTool = DrawingToolType.none;
  List<LatLng> _drawingPoints = [];

  // Services
  final _measurementService = MeasurementService();

  // measurement state
  String? _currentMeasurement;
  
  // GPS Track State
  List<LatLng> _currentTrack = [];
  bool _isRecording = false;
  StreamSubscription<List<LatLng>>? _trackSubscription;
  
  // Current Location State
  LatLng? _currentLocation;
  bool _isFollowMode = false;
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _refreshData();
    // Setup GPS Listener
    final trackService = ref.read(trackRecorderServiceProvider);
    _trackSubscription = trackService.trackStream.listen((track) {
      if (mounted) {
        setState(() {
          _currentTrack = track;
        });
      }
    });
  }

  @override
  void dispose() {
    _trackSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  /// Go to current location
  Future<void> _goToCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied || 
            requested == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('位置情報の権限がありません')),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _currentLocation = latLng);
      _mapController.move(latLng, _mapController.camera.zoom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('位置取得エラー: $e')),
        );
      }
    }
  }

  /// Toggle follow mode (continuous location tracking)
  void _toggleFollowMode() {
    setState(() => _isFollowMode = !_isFollowMode);
    
    if (_isFollowMode) {
      _startLocationUpdates();
    } else {
      _stopLocationUpdates();
    }
  }

  void _startLocationUpdates() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() => _currentLocation = latLng);
        if (_isFollowMode) {
          _mapController.move(latLng, _mapController.camera.zoom);
        }
      }
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _refreshData() async {
    final trees = await ref.read(treeRepositoryProvider).getTrees(widget.workAreaId);
    final mapObjects = await ref.read(mapObjectRepositoryProvider).getMapObjects(widget.workAreaId);
    
    if (mounted) {
      setState(() {
        _trees = trees;
        _mapObjects = mapObjects;
      });
    }
  }



  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_activeTool == DrawingToolType.none) return;

    setState(() {
      if (_activeTool == DrawingToolType.point) {
        _drawingPoints = [point];
        _showSaveDialog(MapObjectType.point);
      } else if (_activeTool == DrawingToolType.line) {
        _drawingPoints.add(point);
        _updateMeasurement(DrawingToolType.line);
      } else if (_activeTool == DrawingToolType.polygon) {
        _drawingPoints.add(point);
        _updateMeasurement(DrawingToolType.polygon);
      }
    });
  }

  void _updateMeasurement(DrawingToolType toolType) {
    if (_drawingPoints.isEmpty) {
      _currentMeasurement = null;
      return;
    }

    if (toolType == DrawingToolType.line) {
      final distance = _measurementService.calculateTotalDistance(_drawingPoints);
      if (distance >= 1000) {
        _currentMeasurement = '${(distance / 1000).toStringAsFixed(2)} km';
      } else {
        _currentMeasurement = '${distance.toStringAsFixed(1)} m';
      }
    } else if (toolType == DrawingToolType.polygon) {
      // Need 3 points for area
      if (_drawingPoints.length < 3) {
        _currentMeasurement = null;
      } else {
        // Close the polygon implicitly for calculation
        final points = [..._drawingPoints]; // simple copy
        final area = _measurementService.calculatePolygonArea(points);
        if (area >= 10000) {
          _currentMeasurement = '${(area / 10000).toStringAsFixed(2)} ha';
        } else {
          _currentMeasurement = '${area.toStringAsFixed(1)} m²';
        }
      }
    }
  }

  Future<void> _toggleRecording() async {
    final service = ref.read(trackRecorderServiceProvider);
    
    if (_isRecording) {
        // Stop
        try {
            final track = await service.stopRecording();
            setState(() => _isRecording = false);
            
            if (track.isNotEmpty) {
                final coords = track.map((p) => '${p.longitude} ${p.latitude}').join(',');
                final wkt = 'LINESTRING($coords)';
                final dateStr = DateTime.now().toString().split('.')[0];
                
                await ref.read(mapObjectRepositoryProvider).createMapObject(
                    type: MapObjectType.line,
                    geometry: wkt,
                    name: 'GPS Track $dateStr',
                    description: 'Recorded Track', 
                    workAreaId: widget.workAreaId,
                );
                
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('軌跡を保存しました')));
                   _refreshData();
                   setState(() => _currentTrack = []);
                }
            }
        } catch (e) {
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('停止エラー: $e')));
        }
    } else {
        // Start
        try {
           final success = await service.requestPermission();
           if (!success) {
               if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('位置情報の権限がありません')));
               return;
           }
           await service.startRecording();
           setState(() => _isRecording = true);
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('記録を開始しました')));
        } catch (e) {
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('開始エラー: $e')));
        }
    }
  }

  Future<void> _showSaveDialog(MapObjectType type) async {
      final nameController = TextEditingController();
      final descriptionController = TextEditingController();
      String? photoPath;

      if (_currentMeasurement != null) {
          descriptionController.text = _currentMeasurement!;
      }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
            return AlertDialog(
        title: Text('${type == MapObjectType.point ? "ポイント" : (type == MapObjectType.line ? "ライン" : "ポリゴン")}を保存'),
        content: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: '名前')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: '説明 (測定値など)')),
            const SizedBox(height: 16),
            if (photoPath != null)
                Stack(
                    alignment: Alignment.topRight,
                    children: [
                        SizedBox(height: 100, child: Image.file(File(photoPath!))),
                        IconButton(onPressed: () => setState(() => photoPath = null), icon: const Icon(Icons.close, color: Colors.red)),
                    ],
                )
            else
                OutlinedButton.icon(
                    onPressed: () async {
                        final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                            setState(() => photoPath = pickedFile.path);
                        }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('写真を追加'),
                ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              _cancelDrawing(); // Reset tool
            },
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close Dialog
              await _saveMapObject(type, nameController.text, descriptionController.text, photoPath);
            },
            child: const Text('保存'),
          ),
        ],
      );
        }
      ),
    );
  }

  Future<void> _saveMapObject(MapObjectType type, String name, String desc, String? photoPath) async {
    if (_drawingPoints.isEmpty) return;

    String wkt;
    if (type == MapObjectType.point) {
      wkt = 'POINT(${_drawingPoints.first.longitude} ${_drawingPoints.first.latitude})';
    } else if (type == MapObjectType.line) {
      final coords = _drawingPoints.map((p) => '${p.longitude} ${p.latitude}').join(',');
      wkt = 'LINESTRING($coords)';
    } else { // Polygon
       // Ensure closed loop
       var points = [..._drawingPoints];
       if (points.first != points.last) {
         points.add(points.first);
       }
       final coords = points.map((p) => '${p.longitude} ${p.latitude}').join(',');
       wkt = 'POLYGON(($coords))';
    }

    try {
      await ref.read(mapObjectRepositoryProvider).createMapObject(
        type: type,
        geometry: wkt,
        name: name,
        description: desc,
        photoPath: photoPath,
        workAreaId: widget.workAreaId,
      );
      _cancelDrawing();
      _refreshData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存エラー: $e')));
    }
  }

  void _undoPoint() {
    if (_drawingPoints.isNotEmpty) {
      setState(() {
        _drawingPoints.removeLast();
        _updateMeasurement(_activeTool);
      });
    }
  }

  void _cancelDrawing() {
    setState(() {
      _activeTool = DrawingToolType.none;
      _drawingPoints = [];
      _currentMeasurement = null;
    });
  }

  // Use this in build method for displaying measurement
  Widget _buildMeasurementBadge() {
    if (_currentMeasurement == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _currentMeasurement!,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- Legacy Tree Logic ---
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
                    _refreshData();
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

  void _showMapObjectDetails(MapObject obj) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(obj.name ?? _getTypeLabel(obj.type)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo
              if (obj.photoPath != null && File(obj.photoPath!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(obj.photoPath!), height: 150, width: double.infinity, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getTypeIcon(obj.type), size: 40, color: Colors.grey),
                ),
              const SizedBox(height: 16),
              // Basic info
              _buildInfoTile(Icons.category, 'タイプ', _getTypeLabel(obj.type)),
              if (obj.description != null)
                _buildInfoTile(Icons.description, '説明', obj.description!),
              _buildInfoTile(Icons.access_time, '更新日時', _formatDateTime(obj.updatedAt)),
              // Custom Attributes
              if (obj.attributes != null && obj.attributes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('カスタム属性', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                ...obj.attributes!.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('${e.key}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(child: Text(e.value?.toString() ?? '-')),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditObjectDialog(obj);
            },
            icon: const Icon(Icons.edit_note),
            label: const Text('基本情報'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final newAttrs = await showAttributeEditorDialog(
                context: context,
                initialAttributes: obj.attributes,
              );
              if (newAttrs != null) {
                await ref.read(mapObjectRepositoryProvider).updateMapObject(
                  id: obj.id,
                  name: obj.name,
                  description: obj.description,
                  photoPath: obj.photoPath,
                  attributes: newAttrs,
                );
                _refreshData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('属性を更新しました')),
                  );
                }
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('属性を編集'),
          ),
          // Delete Button
          IconButton(
            onPressed: () async {
              // Show confirm dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('削除の確認'),
                  content: Text('「${obj.name ?? _getTypeLabel(obj.type)}」を削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('キャンセル'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('削除'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                Navigator.pop(context); // Close details dialog
                await ref.read(mapObjectRepositoryProvider).deleteMapObject(obj.id);
                _refreshData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('削除しました')),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: '削除',
          ),
        ],
      ),
    );
  }

  /// Show dialog to edit name and description
  Future<void> _showEditObjectDialog(MapObject obj) async {
    final nameController = TextEditingController(text: obj.name ?? '');
    final descController = TextEditingController(text: obj.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('オブジェクトを編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(mapObjectRepositoryProvider).updateMapObject(
        id: obj.id,
        name: nameController.text.isEmpty ? null : nameController.text,
        description: descController.text.isEmpty ? null : descController.text,
        photoPath: obj.photoPath,
        attributes: obj.attributes,
      );
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存しました')),
        );
      }
    }
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getTypeLabel(MapObjectType type) {
    switch (type) {
      case MapObjectType.point: return 'ポイント';
      case MapObjectType.line: return 'ライン';
      case MapObjectType.polygon: return 'ポリゴン';
    }
  }

  IconData _getTypeIcon(MapObjectType type) {
    switch (type) {
      case MapObjectType.point: return Icons.place;
      case MapObjectType.line: return Icons.timeline;
      case MapObjectType.polygon: return Icons.pentagon;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Calculate total track distance in meters.
  double? _calculateTrackDistance() {
    if (_currentTrack.length < 2) return null;
    
    const distance = Distance();
    double total = 0;
    for (int i = 0; i < _currentTrack.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, _currentTrack[i], _currentTrack[i + 1]);
    }
    return total;
  }

  Future<void> _exportData() async {
    final format = await showExportDialog(context);
    if (format == null) return;
    
    try {
      await ref.read(exportServiceProvider).exportData(
        widget.workAreaId,
        format: format,
        mapKey: _mapKey,
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エクスポートエラー: $e')));
    }
  }

  // Update build method to include Polygon rendering and measurement badge
  @override
  Widget build(BuildContext context) {
    final currentMapLayer = MapLayer.getLayer(_currentLayerType);

    // Filter MapObjects by Type for rendering
    final polygonObjects = _mapObjects.where((o) => o.type == MapObjectType.polygon).toList();
    final lineObjects = _mapObjects.where((o) => o.type == MapObjectType.line).toList();
    final pointObjects = _mapObjects.where((o) => o.type == MapObjectType.point).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forest Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: '調査サマリー',
            onPressed: () => showSummaryDashboard(
              context,
              trees: _trees,
              mapObjects: _mapObjects,
              trackDistance: _calculateTrackDistance(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'フォトギャラリー',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoGalleryPage(workAreaId: widget.workAreaId),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'データをエクスポート',
            onPressed: _exportData,
          ),
        ],
      ),
      body: Stack(
        children: [
            // FlutterMap wrapped in RepaintBoundary for screenshot
          RepaintBoundary(
            key: _mapKey,
            child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(35.6812, 139.7671),
              initialZoom: 15.0,
              onTap: _handleMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: currentMapLayer.urlTemplate,
                userAgentPackageName: 'com.forest_app.app',
                subdomains: const ['a', 'b', 'c'],
              ),
              // Render Polygons (Below lines/points)
              PolygonLayer(
                polygons: [
                  // Saved Polygons
                  ...polygonObjects.map((obj) {
                    final coordsStr = obj.geometry.substring(9, obj.geometry.length - 2); // POLYGON((...))
                    final points = coordsStr.split(',').map((pair) {
                       final xy = pair.trim().split(' ');
                       return LatLng(double.parse(xy[1]), double.parse(xy[0]));
                    }).toList();
                    return Polygon(points: points, color: Colors.purple.withOpacity(0.3), borderColor: Colors.purple, borderStrokeWidth: 2);
                  }),
                  // Drawing Polygon
                  if (_activeTool == DrawingToolType.polygon && _drawingPoints.isNotEmpty)
                    Polygon(points: _drawingPoints, color: Colors.orange.withOpacity(0.3), borderColor: Colors.orange, borderStrokeWidth: 2, isDotted: true),
                ],
              ),
              // Render Lines
              PolylineLayer(
                polylines: [
                  // Saved Lines
                  ...lineObjects.map((obj) {
                    final coordsStr = obj.geometry.substring(11, obj.geometry.length - 1); // LINESTRING(...)
                    final points = coordsStr.split(',').map((pair) {
                      final xy = pair.trim().split(' ');
                      return LatLng(double.parse(xy[1]), double.parse(xy[0]));
                    }).toList();
                    return Polyline(points: points, color: Colors.blue, strokeWidth: 3.0);
                  }),
                  // Drawing Line
                  if (_activeTool == DrawingToolType.line && _drawingPoints.isNotEmpty)
                    Polyline(points: _drawingPoints, color: Colors.orange, strokeWidth: 3.0, isDotted: true),
                  // GPS Track
                  if (_currentTrack.isNotEmpty)
                    Polyline(points: _currentTrack, color: Colors.red, strokeWidth: 4.0),
                ],
              ),
              // Render Points
              MarkerLayer(
                markers: [
                  // Trees
                  ..._trees.map((tree) {
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
                  }),
                  // Generic Points
                  ...pointObjects.map((obj) {
                    final coords = obj.geometry.substring(6, obj.geometry.length - 1).split(' ');
                    final lng = double.parse(coords[0]);
                    final lat = double.parse(coords[1]);
                    return Marker(
                      point: LatLng(lat, lng),
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => _showMapObjectDetails(obj),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.place, color: Colors.red, size: 36),
                            if (obj.photoPath != null)
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, size: 10, color: Colors.black),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Drawing Points (for Line vertices or Point preview)
                  if (_drawingPoints.isNotEmpty)
                    ..._drawingPoints.map((p) => Marker(
                          point: p,
                          width: 10,
                          height: 10,
                          child: const Icon(Icons.circle, color: Colors.orange, size: 10),
                        )),
                  // Current Location Marker
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(currentMapLayer.attribution),
                ],
              ),
            ],
          ),
          ), // End RepaintBoundary
          // Layer Selector
          Positioned(
            top: 16,
            right: 16,
            child: MapLayerSelector(
              currentLayer: _currentLayerType,
              onLayerChanged: (type) => setState(() => _currentLayerType = type),
            ),
          ),

          // GPS Button
          Positioned(
            top: 70,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'gps_toggle',
              backgroundColor: _isRecording ? Colors.red : Colors.white,
              child: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record, color: _isRecording ? Colors.white : Colors.red),
              onPressed: _toggleRecording,
            ),
          ),

          // Current Location Button
          Positioned(
            top: 120,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'my_location',
              backgroundColor: Colors.white,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // Follow Mode Toggle
          Positioned(
            top: 170,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'follow_mode',
              backgroundColor: _isFollowMode ? Colors.blue : Colors.white,
              onPressed: _toggleFollowMode,
              child: Icon(
                Icons.navigation,
                color: _isFollowMode ? Colors.white : Colors.grey,
              ),
            ),
          ),
          
          // Measurement Badge
          Positioned(
             top: 80,
             left: 0,
             right: 0,
             child: Center(child: _buildMeasurementBadge()),
          ),
          
          // Drawing Toolbar update
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: MapDrawingToolbar(
                activeTool: _activeTool,
                hasDrawingData: _drawingPoints.isNotEmpty,
                onToolSelected: (tool) => setState(() {
                  _activeTool = tool;
                  _drawingPoints = [];
                  _currentMeasurement = null;
                }),
                onSave: () => _activeTool == DrawingToolType.polygon 
                    ? _showSaveDialog(MapObjectType.polygon)
                    : _showSaveDialog(MapObjectType.line),
                onCancel: _cancelDrawing,
              ),
            ),
          ),
        ],
      ),
      // Quick Action FAB - positioned at bottom left for one-handed use
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _activeTool == DrawingToolType.none
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Summary quick access
                FloatingActionButton.small(
                  heroTag: 'quick_summary',
                  backgroundColor: Colors.green[100],
                  onPressed: () => showSummaryDashboard(
                    context,
                    trees: _trees,
                    mapObjects: _mapObjects,
                    trackDistance: _calculateTrackDistance(),
                  ),
                  child: const Icon(Icons.dashboard, color: Colors.green),
                ),
                const SizedBox(height: 8),
                // Current location quick access
                FloatingActionButton.small(
                  heroTag: 'quick_location',
                  backgroundColor: Colors.blue[100],
                  onPressed: _goToCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                // Main action button
                FloatingActionButton.extended(
                  heroTag: 'add_tree',
                  onPressed: _showAddTreeDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('樹木追加'),
                  backgroundColor: Colors.green,
                ),
              ],
            )
          : null, // Hide FAB when drawing
    );
  }
}













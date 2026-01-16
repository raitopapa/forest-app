import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/map_object_repository.dart';
import '../domain/models/map_object.dart';

/// A gallery page to browse all photos from map objects in the current work area.
class PhotoGalleryPage extends ConsumerStatefulWidget {
  final String workAreaId;

  const PhotoGalleryPage({super.key, required this.workAreaId});

  @override
  ConsumerState<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends ConsumerState<PhotoGalleryPage> {
  List<MapObject> _objectsWithPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    
    final allObjects = await ref.read(mapObjectRepositoryProvider).getMapObjects(widget.workAreaId);
    final withPhotos = allObjects.where((obj) => 
        obj.photoPath != null && File(obj.photoPath!).existsSync()
    ).toList();
    
    if (mounted) {
      setState(() {
        _objectsWithPhotos = withPhotos;
        _isLoading = false;
      });
    }
  }

  void _showPhotoDetail(MapObject obj) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PhotoDetailPage(mapObject: obj),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォトギャラリー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPhotos,
            tooltip: '更新',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _objectsWithPhotos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('写真がありません', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('ポイントを追加時に写真を撮影してください', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _objectsWithPhotos.length,
                  itemBuilder: (context, index) {
                    final obj = _objectsWithPhotos[index];
                    return GestureDetector(
                      onTap: () => _showPhotoDetail(obj),
                      child: Hero(
                        tag: 'photo_${obj.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(obj.photoPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                    const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                              ),
                              // Type badge
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    obj.name ?? obj.type.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

/// Full-screen photo detail view with metadata.
class _PhotoDetailPage extends StatelessWidget {
  final MapObject mapObject;

  const _PhotoDetailPage({required this.mapObject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(mapObject.name ?? 'Photo'),
      ),
      body: Column(
        children: [
          // Photo
          Expanded(
            child: Hero(
              tag: 'photo_${mapObject.id}',
              child: InteractiveViewer(
                child: Center(
                  child: Image.file(
                    File(mapObject.photoPath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 64)),
                  ),
                ),
              ),
            ),
          ),
          // Metadata Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (mapObject.name != null)
                  Text(
                    mapObject.name!,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.category, 'タイプ', _getTypeLabel(mapObject.type)),
                if (mapObject.description != null)
                  _buildInfoRow(Icons.description, '説明', mapObject.description!),
                _buildInfoRow(Icons.access_time, '更新日時', _formatDate(mapObject.updatedAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(MapObjectType type) {
    switch (type) {
      case MapObjectType.point:
        return 'ポイント';
      case MapObjectType.line:
        return 'ライン';
      case MapObjectType.polygon:
        return 'ポリゴン';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

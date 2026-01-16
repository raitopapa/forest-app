enum MapObjectType {
  point,
  line,
  polygon,
}

class MapObject {
  final String id;
  final MapObjectType type;
  final String geometry; // WKT
  final String? name;
  final String? description;
  final String? photoPath;
  final Map<String, dynamic>? attributes;
  final String workAreaId;
  final String syncStatus;
  final DateTime updatedAt;

  const MapObject({
    required this.id,
    required this.type,
    required this.geometry,
    this.name,
    this.description,
    this.photoPath,
    this.attributes,
    required this.workAreaId,
    this.syncStatus = 'synced',
    required this.updatedAt,
  });

  MapObject copyWith({
    String? id,
    MapObjectType? type,
    String? geometry,
    String? name,
    String? description,
    String? photoPath,
    Map<String, dynamic>? attributes,
    String? workAreaId,
    String? syncStatus,
    DateTime? updatedAt,
  }) {
    return MapObject(
      id: id ?? this.id,
      type: type ?? this.type,
      geometry: geometry ?? this.geometry,
      name: name ?? this.name,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      attributes: attributes ?? this.attributes,
      workAreaId: workAreaId ?? this.workAreaId,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

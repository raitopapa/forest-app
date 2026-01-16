enum MapLayerType {
  standard,
  satellite,
  topo,
}

class MapLayer {
  final String name;
  final String urlTemplate;
  final String attribution;

  const MapLayer({
    required this.name,
    required this.urlTemplate,
    required this.attribution,
  });

  static const MapLayer standard = MapLayer(
    name: '標準 (OSM)',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
  );

  static const MapLayer satellite = MapLayer(
    name: '衛星写真 (地理院)',
    urlTemplate: 'https://cyberjapandata.gsi.go.jp/xyz/seamlessphoto/{z}/{x}/{y}.jpg',
    attribution: '出典: 国土地理院',
  );

  static const MapLayer topo = MapLayer(
    name: '色別標高図 (地理院)',
    urlTemplate: 'https://cyberjapandata.gsi.go.jp/xyz/relief/{z}/{x}/{y}.png',
    attribution: '出典: 国土地理院',
  );

  static MapLayer getLayer(MapLayerType type) {
    switch (type) {
      case MapLayerType.standard:
        return standard;
      case MapLayerType.satellite:
        return satellite;
      case MapLayerType.topo:
        return topo;
    }
  }
}

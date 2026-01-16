import 'package:latlong2/latlong.dart';

class MeasurementService {
  final Distance _distance = const Distance();

  /// Calculates the total distance of a path defined by [points] in meters.
  double calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _distance.as(LengthUnit.Meter, points[i], points[i+1]);
    }
    return totalDistance;
  }

  /// Calculates the area of a polygon defined by [points] in square meters.
  /// Uses the Shoelace formula (simplified for small areas on Earth).
  /// For larger areas, a spherical excess formula would be more accurate,
  /// but for forest work areas this approximation is usually sufficient or we use a library.
  double calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    // Convert to meters relative to the first point to use planar math
    // This is a "flat earth" approximation nice for small areas (like a forest plot).
    // For very large areas, this will have error.
    
    final origin = points[0];
    final meterPoints = points.map((p) {
      final x = _distance.as(LengthUnit.Meter, LatLng(origin.latitude, origin.longitude), LatLng(origin.latitude, p.longitude));
      final y = _distance.as(LengthUnit.Meter, LatLng(origin.latitude, origin.longitude), LatLng(p.latitude, origin.longitude));
      
      // Adjust sign based on direction
      final xSigned = p.longitude < origin.longitude ? -x : x;
      final ySigned = p.latitude < origin.latitude ? -y : y;
      
      return _Point(xSigned, ySigned);
    }).toList();

    double area = 0.0;
    for (int i = 0; i < meterPoints.length; i++) {
      final j = (i + 1) % meterPoints.length;
      area += meterPoints[i].x * meterPoints[j].y;
      area -= meterPoints[j].x * meterPoints[i].y;
    }

    return (area / 2.0).abs();
  }
}

class _Point {
  final double x;
  final double y;
  _Point(this.x, this.y);
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final trackRecorderServiceProvider = Provider((ref) => TrackRecorderService());

class TrackRecorderService {
  StreamSubscription<Position>? _positionStreamSubscription;
  final List<LatLng> _currentTrack = [];
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  List<LatLng> get currentTrack => List.unmodifiable(_currentTrack);

  final _trackController = StreamController<List<LatLng>>.broadcast();
  Stream<List<LatLng>> get trackStream => _trackController.stream;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    
    final hasPermission = await requestPermission();
    if (!hasPermission) throw Exception('Location permission denied');

    _currentTrack.clear();
    _isRecording = true;
    _trackController.add([]); // Emit empty start

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Minimum distance (meters) between updates
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      final point = LatLng(position.latitude, position.longitude);
      _currentTrack.add(point);
      _trackController.add(_currentTrack);
    });
  }

  Future<List<LatLng>> stopRecording() async {
    if (!_isRecording) return [];

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isRecording = false;
    
    // Return a copy of the track
    return List.from(_currentTrack);
  }
}

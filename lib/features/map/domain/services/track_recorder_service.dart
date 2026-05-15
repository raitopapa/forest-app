import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

final trackRecorderServiceProvider = Provider((ref) => TrackRecorderService());

enum TrackingMode { highAccuracy, balanced, batterySaver }

class TrackRecorderService {
  static const _trackingModeKey = 'tracking_mode';
  StreamSubscription<Position>? _positionStreamSubscription;
  final List<LatLng> _currentTrack = [];
  bool _isRecording = false;
  TrackingMode _trackingMode = TrackingMode.balanced;
  bool _isInitialized = false;

  bool get isRecording => _isRecording;
  List<LatLng> get currentTrack => List.unmodifiable(_currentTrack);

  final _trackController = StreamController<List<LatLng>>.broadcast();
  Stream<List<LatLng>> get trackStream => _trackController.stream;
  TrackingMode get trackingMode => _trackingMode;

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_trackingModeKey);
    if (index != null && index >= 0 && index < TrackingMode.values.length) {
      _trackingMode = TrackingMode.values[index];
    }
    _isInitialized = true;
  }

  Future<void> setTrackingMode(TrackingMode mode) async {
    _trackingMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trackingModeKey, mode.index);
  }

  static LocationSettings locationSettingsForMode(TrackingMode mode) {
    switch (mode) {
      case TrackingMode.highAccuracy:
        return const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 3);
      case TrackingMode.batterySaver:
        return const LocationSettings(accuracy: LocationAccuracy.medium, distanceFilter: 15);
      case TrackingMode.balanced:
        return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 7);
    }
  }

  LocationSettings _locationSettingsForMode() => locationSettingsForMode(_trackingMode);

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
    
    await ensureInitialized();

    final hasPermission = await requestPermission();
    if (!hasPermission) throw Exception('Location permission denied');

    _currentTrack.clear();
    _isRecording = true;
    _trackController.add([]); // Emit empty start

    final locationSettings = _locationSettingsForMode();

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

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_summary.dart';
import '../models/geo_fence.dart';
import '../services/location_tracking_service/location_service.dart';

class LocationTrackingProvider with ChangeNotifier {
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // For demonstration, we use default geofence settings.
  // In a real app, these would be loaded from user settings.
  final GeoFence defaultHome = GeoFence(
    name: 'Home',
    latitude: 37.4219983, // default value – can be changed in settings
    longitude: -22.084,
  );

  final GeoFence defaultOffice = GeoFence(
    name: 'Office',
    latitude: 37.7858, // fixed for example
    longitude: -122.4364,
  );

  final LocationService _locationService = LocationService();

  Map<String, Duration> get summary => _locationService.timeAccumulated;
  LocationService get locationService => _locationService;

  /// Start tracking using the latest saved geofence parameters.
  Future<void> startTracking() async {
    final settingsBox = Hive.box('geofenceSettings');
    // Load saved values or use defaults if not set.
    final double homeLat = settingsBox.get('homeLat',
        defaultValue: defaultHome.latitude,) as double;
    final double homeLon = settingsBox.get('homeLon',
        defaultValue: defaultHome.longitude,) as double;
    final double officeLat = settingsBox.get('officeLat',
        defaultValue: defaultOffice.latitude,) as double;
    final double officeLon = settingsBox.get('officeLon',
        defaultValue: defaultOffice.longitude,) as double;

    final home = GeoFence(name: 'Home', latitude: homeLat, longitude: homeLon);
    final office =
        GeoFence(name: 'Office', latitude: officeLat, longitude: officeLon);

    _isTracking = true;
    notifyListeners();
    await _locationService.fetchInitialLocation();
    // Wait briefly to allow a more accurate location update.

    await Future.delayed(const Duration(seconds: 2));
    notifyListeners();

    await _locationService.initialize(home: home, office: office);
  }

  /// Stop tracking and persist the summary.
  Future<void> stopTracking() async {
    _isTracking = false;
    notifyListeners();
    await _locationService.stopLocationService();
    await _persistSummary();
  }

  /// Persist today's summary using Hive.
  Future<void> _persistSummary() async {
    final box = Hive.box<DailySummary>('dailySummaries');
    final now = DateTime.now();
    final key = '${now.year}-${now.month}-${now.day}';
    final existingSummary = box.get(key);
    final updatedDurations =
        Map<String, int>.from(existingSummary?.durations ?? {});

    // Convert durations to seconds.
    _locationService.timeAccumulated.forEach((activity, duration) {
      updatedDurations[activity] = updatedDurations[activity] =
          ((updatedDurations[activity] ?? 0) + duration.inSeconds).toInt();
    });

    final dailySummary = DailySummary(date: now, durations: updatedDurations);
    await box.put(key, dailySummary);
  }

  /// Update geofence settings dynamically.
  Future<void> updateGeofences(
      {required GeoFence home, required GeoFence office,}) async {
    await _locationService.updateGeofences(home: home, office: office);
  }
}

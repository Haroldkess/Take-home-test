// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:permission_handler/permission_handler.dart';
import '../../models/geo_fence.dart';
import '../../util/logger.dart';
import '../geo_fence_service/geo_fence_service.dart';

import 'location_service_message.dart';

class LocationService {
  /// Map to accumulate time (as Duration) for each category.
  Map<String, Duration> timeAccumulated = {
    'Home': Duration.zero,
    'Office': Duration.zero,
    'Traveling': Duration.zero,
  };

  DateTime? _lastUpdateTime;
  Timer? _timer;

  // Current geofence settings.
  GeoFence? _homeGeofence;
  GeoFence? _officeGeofence;

  // Latest known device location.
  double? _currentLat;
  double? _currentLon;

  double? get currentLat => _currentLat;
  double? get currentLon => _currentLon;
  GeoFence? get homeGeofence => _homeGeofence;
  GeoFence? get officeGeofence => _officeGeofence;

    /// Fetches the current device location and updates internal state.
 Future<void> fetchInitialLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,);
      _currentLat = position.latitude;
      _currentLon = position.longitude;
    } catch (e) {
      // Optionally log or handle the error.
    }
  }

  /// Initialize the service. This requests permissions, gets the current
  /// location, and adds geofences (using current location for Home and saved Office).
  Future<void> initialize(
      {required GeoFence home, required GeoFence office,}) async {
    if (await Permission.location.request().isGranted) {

      // Get initial location.
      await fetchInitialLocation();

      // Get real-time current location.
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLat = position.latitude;
      _currentLon = position.longitude;
      AppLogger.i('Current location: lat=$_currentLat, lon=$_currentLon');

      // Set geofences from user settings.
      _homeGeofence = home;
      _officeGeofence = office;

      // Add geofences via the plugin.
      await Future.wait([
        bg.BackgroundGeolocation.addGeofence(
          bg.Geofence(
            identifier: _homeGeofence!.name,
            latitude: _homeGeofence!.latitude,
            longitude: _homeGeofence!.longitude,
            radius: _homeGeofence!.radius,
            notifyOnEntry: true,
            notifyOnExit: true,
            notifyOnDwell: true,
            loiteringDelay: 30000,
          ),
        ),
        bg.BackgroundGeolocation.addGeofence(
          bg.Geofence(
            identifier: _officeGeofence!.name,
            latitude: _officeGeofence!.latitude,
            longitude: _officeGeofence!.longitude,
            radius: _officeGeofence!.radius,
            notifyOnEntry: true,
            notifyOnExit: true,
            notifyOnDwell: true,
            loiteringDelay: 30000,
          ),
        ),
      ]).then((_) {
        AppLogger.i(
            '[Geofences Added] Home: (${_homeGeofence!.latitude}, ${_homeGeofence!.longitude}) '
            'Office: (${_officeGeofence!.latitude}, ${_officeGeofence!.longitude})');
      }).catchError((error) {
        AppLogger.e('[Geofence Error]', error);
      });

      // Listen for geofence events.
      bg.BackgroundGeolocation.onGeofence(_onGeofenceEvent);

      // Listen for location updates.
      bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);

      // Configure and start background tracking.
      await bg.BackgroundGeolocation.ready(
        bg.Config(
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 10.0,
          stopOnTerminate: false,
          startOnBoot: true,
          debug: false,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        ),
      ).then((state) async {
        if (!state.enabled) {
          await bg.BackgroundGeolocation.start();
          AppLogger.i(LogMessage.locationServiceStarted.message());
        }
      });

      // Start a periodic timer that updates tracking every 5 seconds.
      _startTimer();
      _lastUpdateTime = DateTime.now();
    } else {
      AppLogger.w(LogMessage.locationPermissionNotGranted.message());
    }
  }

  /// Stop tracking and cancel the timer.
  Future<void> stopLocationService() async {
    try {
      await bg.BackgroundGeolocation.stop();
      _timer?.cancel();
      _lastUpdateTime = null;
      AppLogger.i(LogMessage.locationServiceStopped.message());
    } catch (e, stackTrace) {
      AppLogger.e(LogMessage.errorStoppingService.message(), e, stackTrace);
    }
  }

  /// Periodic timer to update tracking.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentTime = DateTime.now();
      if (_lastUpdateTime != null) {
        final elapsedTime = currentTime.difference(_lastUpdateTime!);
        bool counted = false;

        // Use the latest location if available.
        final double currentLat = _currentLat ?? _homeGeofence?.latitude ?? 0;
        final double currentLon = _currentLon ?? _homeGeofence?.longitude ?? 0;

        // Check if inside Home geofence.
        if (_homeGeofence != null &&
            isInsideGeoFence(currentLat, currentLon, _homeGeofence!)) {
          timeAccumulated.update(
            _homeGeofence!.name,
            (existing) => existing + elapsedTime,
            ifAbsent: () => elapsedTime,
          );
          AppLogger.d(
            LogMessage.locationUpdateInsideFence.message(
              fenceName: _homeGeofence!.name,
              duration: elapsedTime.inSeconds.toString(),
            ),
          );
          counted = true;
        }

        // Check if inside Office geofence.
        if (_officeGeofence != null &&
            isInsideGeoFence(currentLat, currentLon, _officeGeofence!)) {
          timeAccumulated.update(
            _officeGeofence!.name,
            (existing) => existing + elapsedTime,
            ifAbsent: () => elapsedTime,
          );
          AppLogger.d(
            LogMessage.locationUpdateInsideFence.message(
              fenceName: _officeGeofence!.name,
              duration: elapsedTime.inSeconds.toString(),
            ),
          );
          counted = true;
        }

        // Otherwise, count as Traveling.
        if (!counted) {
          timeAccumulated.update(
            'Traveling',
            (existing) => existing + elapsedTime,
            ifAbsent: () => elapsedTime,
          );
          AppLogger.d(
            LogMessage.locationUpdateTraveling.message(
              duration: elapsedTime.inSeconds.toString(),
            ),
          );
        }
      }
      _lastUpdateTime = currentTime;
    });
  }

  /// Callback for location updates.
  void _onLocation(bg.Location location) {
    AppLogger.d('Received location update: ${location.coords}');
    _currentLat = location.coords.latitude;
    _currentLon = location.coords.longitude;
  }

  /// Error callback for location updates.
  void _onLocationError(bg.LocationError error) {
    AppLogger.e('Location error: ${error.code} - ${error.message}');
  }

  /// Geofence event callback.
  void _onGeofenceEvent(bg.GeofenceEvent event) {
    if (event.action == 'EXIT') {
      AppLogger.i('Device has left the geofence: ${event.identifier}');
    } else if (event.action == 'ENTER') {
      AppLogger.i('Device has entered the geofence: ${event.identifier}');
    }
  }

  /// Update geofences dynamically (if the user changes settings).
  Future<void> updateGeofences(
      {required GeoFence home, required GeoFence office,}) async {
    // Remove old geofences.
    await bg.BackgroundGeolocation.removeGeofence(_homeGeofence?.name ?? '');
    await bg.BackgroundGeolocation.removeGeofence(_officeGeofence?.name ?? '');

    // Update local settings.
    _homeGeofence = home;
    _officeGeofence = office;

    // Add new geofences.
    await Future.wait([
      bg.BackgroundGeolocation.addGeofence(
        bg.Geofence(
          identifier: _homeGeofence!.name,
          latitude: _homeGeofence!.latitude,
          longitude: _homeGeofence!.longitude,
          radius: _homeGeofence!.radius,
          notifyOnEntry: true,
          notifyOnExit: true,
          notifyOnDwell: true,
          loiteringDelay: 30000,
        ),
      ),
      bg.BackgroundGeolocation.addGeofence(
        bg.Geofence(
          identifier: _officeGeofence!.name,
          latitude: _officeGeofence!.latitude,
          longitude: _officeGeofence!.longitude,
          radius: _officeGeofence!.radius,
          notifyOnEntry: true,
          notifyOnExit: true,
          notifyOnDwell: true,
          loiteringDelay: 30000,
        ),
      ),
    ]).then((_) {
      AppLogger.i(
          '[Geofences Updated] Home: (${_homeGeofence!.latitude}, ${_homeGeofence!.longitude}), '
          'Office: (${_officeGeofence!.latitude}, ${_officeGeofence!.longitude})');
    }).catchError((error) {
      AppLogger.e('[Geofence Update Error]', error);
    });
  }
}

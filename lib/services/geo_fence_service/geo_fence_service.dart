import 'dart:math';
import '../../models/geo_fence.dart';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // in meters
  final double dLat = _degToRad(lat2 - lat1);
  final double dLon = _degToRad(lon2 - lon1);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _degToRad(double deg) => deg * (pi / 180);

bool isInsideGeoFence(double currentLat, double currentLon, GeoFence fence) {
  final distance = calculateDistance(currentLat, currentLon, fence.latitude, fence.longitude);
  return distance <= fence.radius;
}

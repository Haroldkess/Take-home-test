import 'package:clean_provider_architecture/models/geo_fence.dart';
import 'package:clean_provider_architecture/services/geo_fence_service/geo_fence_service.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('GeoFence Service Tests', () {
    test('calculateDistance returns 0 for identical coordinates', () {
      final distance = calculateDistance(37.7749, -122.4194, 37.7749, -122.4194);
      expect(distance, 0);
    });

    test('isInsideGeoFence returns true for a point within the fence', () {
      final fence = GeoFence(name: 'Test', latitude: 37.7749, longitude: -122.4194, );
      final result = isInsideGeoFence(37.7749, -122.4194, fence);
      expect(result, true);
    });

    test('isInsideGeoFence returns false for a point outside the fence', () {
      final fence = GeoFence(name: 'Test', latitude: 37.7749, longitude: -122.4194,);
      // Use coordinates that are clearly outside the 50m radius.
      final result = isInsideGeoFence(37.7849, -122.4294, fence);
      expect(result, false);
    });
  });
}

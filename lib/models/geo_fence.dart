class GeoFence {
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // in meters, default 50

  GeoFence({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 50.0,
  });
}

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/location_tracking_provider.dart';
import '../services/geo_fence_service/geo_fence_service.dart';

class GeofenceStatusWidget extends StatelessWidget {
  const GeofenceStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationTrackingProvider>(
      builder: (context, trackingProvider, child) {
        final locationService = trackingProvider.locationService;
        final double? currentLat = locationService.currentLat;
        final double? currentLon = locationService.currentLon;

        // Retrieve the saved/default geofences.
        final home = locationService.homeGeofence;
        final office = locationService.officeGeofence;

        // Use actual location if available; otherwise, fallback.
        final double lat =
            currentLat ?? (home?.latitude ?? (office?.latitude ?? 0));
        final double lon =
            currentLon ?? (home?.longitude ?? (office?.longitude ?? 0));

        final bool usingFallback = (currentLat == null || currentLon == null);

        double distance = 0;
        String statusText = '';
        double percent = 0.0;

        if (home != null && isInsideGeoFence(lat, lon, home)) {
          final double distToCenter =
              calculateDistance(lat, lon, home.latitude, home.longitude);
          distance = (home.radius - distToCenter).clamp(0, home.radius);
          percent = 1 - (distToCenter / home.radius);
          statusText = 'You are ${distance.toStringAsFixed(0)} m at Home 🏡';
        } else if (office != null && isInsideGeoFence(lat, lon, office)) {
          final double distToCenter =
              calculateDistance(lat, lon, office.latitude, office.longitude);
          distance = (office.radius - distToCenter).clamp(0, office.radius);
          percent = 1 - (distToCenter / office.radius);
          statusText = 'You are ${distance.toStringAsFixed(0)} m at Office 🏢';
        } else {
          final double distanceToHome = home != null
              ? calculateDistance(lat, lon, home.latitude, home.longitude)
              : double.infinity;
          final double distanceToOffice = office != null
              ? calculateDistance(lat, lon, office.latitude, office.longitude)
              : double.infinity;
          String target = '';
          if (distanceToHome < distanceToOffice) {
            target = 'Home';
            distance = distanceToHome;
          } else {
            target = 'Office';
            distance = distanceToOffice;
          }
          percent = 0.0;
          statusText =
              'You are ${distance.isInfinite ? 'traveling' : '${distance.toStringAsFixed(0)} m'} ${distance.isInfinite ? '' : 'away from $target'}';
        }

        if (usingFallback) {
          statusText += ' (using saved location)';
        }

        final String distanceText =
            distance.isInfinite ? 'N/A' : '${distance.toStringAsFixed(1)} m';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                // Optional: manual refresh.
              },
              child: CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 10.0,
                percent: percent.clamp(0.0, 1.0),
                center: Text(
                  distanceText,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,),
                ),
                progressColor: Colors.green,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/location_tracking_provider.dart';
import '../util/helpers.dart'; // formatDuration() helper

class GeofenceStatusWidget extends StatelessWidget {
  const GeofenceStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationTrackingProvider>(
      builder: (context, trackingProvider, child) {
        final elapsed = trackingProvider.currentSessionDuration;
        final String zone =
            trackingProvider.locationService.currentZone ?? 'Unknown';

        // Use a maximum duration (e.g., 1 hour) for visual progress.
        const Duration maxDuration = Duration(hours: 1);
        final double percent = (elapsed.inSeconds / maxDuration.inSeconds)
            .clamp(0.0, 1.0)
            .toDouble();
        final String timerText = Helpers.formatFromSeconds(elapsed.inSeconds);
        String statusText;
        if (zone == 'Home') {
          statusText = 'Been $zone 🏡 for $timerText';
        } else if (zone == 'Traveling') {
          statusText = 'Been $zone ✈️ for $timerText';
        } else {
          statusText = 'Been in the $zone 🏢 for $timerText';
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 10.0,
              percent: percent,
              center: Text(
                timerText,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.green,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
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

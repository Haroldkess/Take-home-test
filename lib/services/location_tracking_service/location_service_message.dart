enum LogMessage {
  locationServiceStarted,
  locationServiceStopped,
  locationPermissionNotGranted,
  locationUpdateInsideFence,
  locationUpdateTraveling,
  errorStartingService,
  errorStoppingService,
}

extension LogMessageExtension on LogMessage {
  String message({String? fenceName, String? duration}) {
    switch (this) {
      case LogMessage.locationServiceStarted:
        return 'Location service started successfully.';
      case LogMessage.locationServiceStopped:
        return 'Location service stopped successfully.';
      case LogMessage.locationPermissionNotGranted:
        return 'Location permission not granted. Cannot start service.';
      case LogMessage.locationUpdateInsideFence:
        return 'User is inside ${fenceName ?? "unknown fence"} for ${duration ?? "unknown duration"}.';
      case LogMessage.locationUpdateTraveling:
        return 'User is traveling for ${duration ?? "unknown duration"}.';
      case LogMessage.errorStartingService:
        return 'Error starting location service.';
      case LogMessage.errorStoppingService:
        return 'Error stopping location service.';
    }
  }
}

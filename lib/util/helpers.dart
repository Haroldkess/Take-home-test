// ignore_for_file: avoid_classes_with_only_static_members

/// A collection of static helper methods for formatting durations and dates.
///
/// This class provides utility functions that can be used throughout the application,
/// such as converting a duration (in seconds) to a human-readable format and converting
/// a [DateTime] object to a string key used for data persistence (e.g., in Hive).
class Helpers {
  /// Formats a duration given in [seconds] into a human-readable string.
  ///
  /// The output format is "Xh Ym Zs", where X is hours, Y is minutes, and Z is seconds.
  ///
  /// Example:
  /// ```dart
  /// final formatted = Helpers.formatDuration(3661);
  /// // formatted will be "1h 1m 1s"
  /// ```
  static String formatFromSeconds(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${secs}s';
  }

  /// Converts a [DateTime] into a string key formatted as "YYYY-M-D".
  ///
  /// This key format is useful for storing and retrieving data from persistent storage,
  /// such as Hive, where you need a unique key for each day.
  ///
  /// Example:
  /// ```dart
  /// final key = Helpers.dateToKey(DateTime(2025, 3, 18));
  /// // key will be "2025-3-18"
  /// ```
  static String dateToKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return '${hours}h ${minutes}m ${seconds}s';
}
}

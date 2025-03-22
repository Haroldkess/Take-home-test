import 'package:hive/hive.dart';

part 'daily_summary.g.dart';

@HiveType(typeId: 0)
class DailySummary extends HiveObject {
  @HiveField(0)
  final DateTime date;
  
  // Store durations in seconds for simplicity.
  @HiveField(1)
  final Map<String, int> durations;

  DailySummary({required this.date, required this.durations});
}

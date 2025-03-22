// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/daily_summary.dart';
import '../../../util/helpers.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DailySummary>('dailySummaries');
    final selectedKey = _selectedDay != null ? Helpers.dateToKey(_selectedDay!) : '';
    final summary = box.get(selectedKey);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Summary')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1,),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            availableCalendarFormats: const  {CalendarFormat.month : 'Month',},
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const Divider(),
          Expanded(
            child: summary == null
                ? const Center(child: Text('No summary available for selected day.'))
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: summary.durations.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        trailing: Text(Helpers.formatDuration(entry.value)),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

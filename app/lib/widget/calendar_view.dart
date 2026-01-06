import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';

class CalendarView extends StatefulWidget {
  final List<Measurement> measurements;
  final Function(DateTime)? onDateSelected;

  const CalendarView({
    super.key,
    required this.measurements,
    this.onDateSelected,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  bool _hasMeasurement(DateTime day) {
    // Check if ANY measurement exists for this day, regardless of isMeasured flag
    return widget.measurements.any((m) => isSameDay(m.date, day));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 0)), // Prevent future dates
        focusedDay: _focusedDay,
        currentDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        enabledDayPredicate: (day) {
           // Disable future dates
           return day.isBefore(DateTime.now()) || isSameDay(day, DateTime.now());
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDateSelected?.call(selectedDay);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (_hasMeasurement(date)) {
              return Positioned(
                bottom: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  width: 6.0,
                  height: 6.0,
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}


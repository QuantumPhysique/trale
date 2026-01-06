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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0, // Flat design for M3 docked look
      color: colorScheme.surfaceContainerHigh, // M3 Container color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), // Larger corner radius
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          currentDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
            rightChevronIcon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.labelLarge!.copyWith(color: colorScheme.onSurfaceVariant),
            weekendStyle: theme.textTheme.labelLarge!.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          calendarStyle: CalendarStyle(
            // M3 Selected State
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            
            // M3 Today State
            todayDecoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 1),
              shape: BoxShape.circle,
            ),
            todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),

            // Default State
            defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface
            ),
            weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface
            ),
            
            // Disabled State
            disabledTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface.withOpacity(0.38)
            ),
            outsideTextStyle: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface.withOpacity(0.38)
            ),
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
                final bool isSelected = isSameDay(date, _selectedDay);
                return Positioned(
                  bottom: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                        ? colorScheme.onPrimary 
                        : colorScheme.primary, // Contrast dot
                    ),
                    width: 5.0,
                    height: 5.0,
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}


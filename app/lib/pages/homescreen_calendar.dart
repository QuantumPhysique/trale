import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trale/core/db/app_database.dart';
import 'package:trale/widget/addCheckInDialog.dart';

/// Full screen month calendar page that highlights dates with check-ins.
class HomeScreenCalendarPage extends StatefulWidget {
  const HomeScreenCalendarPage({super.key, this.initialEvents});

  /// Optional list of preloaded check-in dates (useful for tests)
  final List<DateTime>? initialEvents;

  @override
  State<HomeScreenCalendarPage> createState() => _HomeScreenCalendarPageState();
}

class _HomeScreenCalendarPageState extends State<HomeScreenCalendarPage> {
  late final AppDatabase _db;
  final Map<DateTime, List<String>> _events = <DateTime, List<String>>{};
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    if (widget.initialEvents != null) {
      setState(() {
        for (final d in widget.initialEvents!) {
          final key = DateTime(d.year, d.month, d.day);
          _events.putIfAbsent(key, () => <String>[]).add('checkin');
        }
      });
    } else {
      _loadEvents();
    }
  }

  void _loadEvents() async {
    final rows = await _db.select(_db.checkIns).get();
    setState(() {
      _events.clear();
      for (final r in rows) {
        try {
          final parts = r.date.split('-');
          if (parts.length != 3) continue;
          final d = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          _events.putIfAbsent(d, () => <String>[]).add('checkin');
        } catch (e) {
          // ignore malformed dates
        }
      }
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _events[d] ?? <String>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TableCalendar<String>(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focused,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (d) => isSameDay(_selected, d),
              eventLoader: _getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selected = selectedDay;
                  _focused = focusedDay;
                });
                // In tests we may provide initialEvents and skip opening the dialog
                if (widget.initialEvents == null) {
                  // Open check-in dialog for date
                  await showAddCheckInDialog(
                    context: context,
                    initialWeight: 70.0,
                    initialDate: selectedDay,
                  );
                  // reload events after returning
                  _loadEvents();
                }
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _getEventsForDay(_selected ?? DateTime.now()).length,
                itemBuilder: (context, index) {
                  final items = _getEventsForDay(_selected ?? DateTime.now());
                  return ListTile(title: Text(items[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

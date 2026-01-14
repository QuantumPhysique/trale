import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trale/core/db/app_database.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/screens/daily_entry_screen.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    if (widget.initialEvents != null) {
      setState(() {
        for (final DateTime d in widget.initialEvents!) {
          final DateTime key = DateTime(d.year, d.month, d.day);
          _events.putIfAbsent(key, () => <String>[]).add('checkin');
        }
      });
    } else {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final List<CheckIn> rows = await _db.select(_db.checkIns).get();
      setState(() {
        _events.clear();
        for (final CheckIn r in rows) {
          try {
            final List<String> parts = r.checkInDate.split('-');
            if (parts.length != 3) continue;
            final DateTime d = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            final String eventStr = r.weight != null ? 'Weight: ${r.weight}' : 'Check-in';
            _events.putIfAbsent(d, () => <String>[]).add(eventStr);
          } catch (e) {
            // ignore malformed dates
          }
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    final DateTime d = DateTime(day.year, day.month, day.day);
    return _events[d] ?? <String>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.calendar)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  TableCalendar<String>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focused,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (DateTime d) => isSameDay(_selected, d),
                    eventLoader: _getEventsForDay,
                    onDaySelected: (DateTime selectedDay, DateTime focusedDay) async {
                      setState(() {
                        _selected = selectedDay;
                        _focused = focusedDay;
                      });
                      // In tests we may provide initialEvents and skip opening the screen
                      if (widget.initialEvents == null) {
                        // Open daily entry screen for date
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => DailyEntryScreen(
                              initialDate: selectedDay,
                            ),
                          ),
                        );
                        // reload events after returning
                        if (result == true) {
                          _loadEvents();
                        }
                      }
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (BuildContext context, DateTime day, List<String> events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            right: 6,
                            bottom: 6,
                            child: Semantics(
                              label: 'Check-in',
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
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
                    child: Builder(
                      builder: (BuildContext context) {
                        final List<String> events = _getEventsForDay(_selected ?? DateTime.now());
                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Semantics(
                              label: 'Check-in event: ${events[index]}',
                              child: ListTile(title: Text(events[index])),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

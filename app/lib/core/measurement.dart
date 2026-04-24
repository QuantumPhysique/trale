import 'package:hive_ce/hive.dart';

part 'measurement.g.dart';

/// Class for weight event
@HiveType(typeId: 0)
class Measurement {
  /// constructor
  Measurement({
    required this.weight,
    required this.date,
    this.isMeasured = false,
  }) : assert(weight.isFinite, 'weight must be a finite number'),
       assert(weight > 0, 'weight must be positive');

  /// weight of measurement
  @HiveField(0)
  final double weight;

  /// date of measurement
  @HiveField(1)
  final DateTime date;

  /// to store if measured
  final bool isMeasured;

  /// copy with applying change
  Measurement apply({double? weight, DateTime? date, bool? isMeasured}) =>
      Measurement(
        weight: weight ?? this.weight,
        date: date ?? this.date,
        isMeasured: isMeasured ?? this.isMeasured,
      );

  /// implement sorting entries by date
  /// comparator method
  int compareTo(Measurement other) => date.compareTo(other.date);

  /// check if identical
  bool isIdentical(Measurement other) =>
      (weight == other.weight) &&
      (date.difference(other.date).inMinutes.abs() <= 1);

  /// return day in milliseconds since epoch neglecting the hours, minutes
  int get dayInMs => DateTime(
    date.year,
    date.month,
    date.day,
    12, // use 1h offset to ignore jumps
  ).millisecondsSinceEpoch;

  /// return date in milliseconds
  int get dateInMs => date.millisecondsSinceEpoch;

  /// return string for export
  String get exportString =>
      '${date.toIso8601String()} ${weight.toStringAsFixed(10)}';

  /// Parses a [Measurement] from an [exportString] produced by [exportString].
  ///
  /// Throws a [FormatException] if the string is malformed or contains
  /// an invalid weight or date.
  static Measurement fromString({required String exportString}) {
    final List<String> parts = exportString.split(' ');
    if (parts.length != 2) {
      throw FormatException(
        'Invalid measurement format (expected "<date> <weight>"): '
        '$exportString',
      );
    }
    final DateTime? date = DateTime.tryParse(parts[0]);
    if (date == null) {
      throw FormatException('Invalid date in measurement: ${parts[0]}');
    }
    final double? weight = double.tryParse(parts[1]);
    if (weight == null || !weight.isFinite || weight <= 0) {
      throw FormatException('Invalid weight in measurement: ${parts[1]}');
    }
    return Measurement(weight: weight, date: date, isMeasured: true);
  }

  /// compare method to use default sort method on list
  static int compare(Measurement a, Measurement b) => a.compareTo(b);
}

/// Class wrapping measurement with its hive key
class SortedMeasurement {
  /// constructor
  SortedMeasurement({required this.key, required this.measurement});

  /// Measurement object
  final Measurement measurement;

  /// Hive key
  final dynamic key;

  /// implement sorting entries by date
  /// comparator method
  int compareTo(SortedMeasurement other) =>
      measurement.date.compareTo(other.measurement.date);

  /// compare method to use default sort method on list
  static int compare(SortedMeasurement a, SortedMeasurement b) =>
      a.compareTo(b);
}

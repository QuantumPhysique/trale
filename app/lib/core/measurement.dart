import 'package:hive/hive.dart';

part 'measurement.g.dart';

/// Class for weight event
@HiveType(typeId: 0)
class Measurement {
  /// constructor
  Measurement({
    required this.weight,
    required this.date,
  });

  /// weight of measurement
  @HiveField(0)
  final double weight;
  /// date of measurement
  @HiveField(1)
  final DateTime date;

  /// implement sorting entries by date
  /// comparator method
  int compareTo(Measurement other) => date.compareTo(other.date);

  /// compare method to use default sort method on list
  static int compare(Measurement a, Measurement b) => a.compareTo(b);
}


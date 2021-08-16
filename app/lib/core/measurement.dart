import 'package:flutter/material.dart';


/// Class for weight event
class Measurement {
  /// constructor
  Measurement({
    required this.weight,
    required this.date,
  });

  /// weight of measurement
  final num weight;
  /// date of measurement
  final DateTime date;

  /// implement sorting entries by date
  /// comparator method
  int compareTo(Measurement other) => date.compareTo(other.date);

  /// compare method to use default sort method on list
  static int compare(Measurement a, Measurement b) => a.compareTo(b);
}


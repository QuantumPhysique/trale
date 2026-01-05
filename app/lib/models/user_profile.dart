import 'dart:convert';

enum UnitSystem {
  metric,
  imperial;

  factory UnitSystem.fromString(String value) {
    return value == 'imperial' ? UnitSystem.imperial : UnitSystem.metric;
  }

  String get value {
    return name; // Returns 'metric' or 'imperial'
  }
}

class UserProfile {

  UserProfile({
    this.initialHeight,
    this.heightHistory = const [],
    this.preferredUnits = UnitSystem.metric,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      initialHeight: map['initial_height'] as double?,
      heightHistory: map['height_history'] != null
          ? (jsonDecode(map['height_history']) as List)
              .map((h) => HeightEntry.fromMap(h as Map<String, dynamic>))
              .toList()
          : [],
      preferredUnits: UnitSystem.fromString(map['preferred_units'] as String? ?? 'metric'),
    );
  }
  final double? initialHeight;
  final List<HeightEntry> heightHistory;
  final UnitSystem preferredUnits; // Preferred unit system (metric or imperial)

  // Calculate BMI: weight in kg, height in cm
  double? calculateBMI(double? weight, double? height) {
    if (weight == null || height == null || height == 0) return null;
    final double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': 1, // Single row table
      'initial_height': initialHeight,
      'height_history': jsonEncode(heightHistory.map((HeightEntry h) => h.toMap()).toList()),
      'preferred_units': preferredUnits.value,
    };
  }
}

class HeightEntry {

  HeightEntry({required this.date, required this.height});

  factory HeightEntry.fromMap(Map<String, dynamic> map) {
    return HeightEntry(
      date: DateTime.parse(map['date']),
      height: map['height'] as double,
    );
  }
  final DateTime date;
  final double height;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.toIso8601String(),
      'height': height,
    };
  }
}

import 'dart:convert';

class UserProfile {
  final double? initialHeight;
  final List<HeightEntry> heightHistory;
  final String preferredUnits; // 'metric' or 'imperial'

  UserProfile({
    this.initialHeight,
    this.heightHistory = const [],
    this.preferredUnits = 'metric',
  });

  // Calculate BMI: weight in kg, height in cm
  double? calculateBMI(double? weight, double? height) {
    if (weight == null || height == null || height == 0) return null;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1, // Single row table
      'initial_height': initialHeight,
      'height_history': jsonEncode(heightHistory.map((h) => h.toMap()).toList()),
      'preferred_units': preferredUnits,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      initialHeight: map['initial_height'] as double?,
      heightHistory: map['height_history'] != null
          ? (jsonDecode(map['height_history']) as List)
              .map((h) => HeightEntry.fromMap(h))
              .toList()
          : [],
      preferredUnits: map['preferred_units'] as String? ?? 'metric',
    );
  }
}

class HeightEntry {
  final DateTime date;
  final double height;

  HeightEntry({required this.date, required this.height});

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'height': height,
    };
  }

  factory HeightEntry.fromMap(Map<String, dynamic> map) {
    return HeightEntry(
      date: DateTime.parse(map['date']),
      height: map['height'] as double,
    );
  }
}

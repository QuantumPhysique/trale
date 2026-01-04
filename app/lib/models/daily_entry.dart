import 'dart:convert';

class DailyEntry {
  final DateTime date;
  final double? weight;
  final double? height;
  final List<String> photoPaths;
  final String? workoutText;
  final List<String> workoutTags;
  final String? thoughts;
  final List<String> emotions;
  final DateTime timestamp;

  DailyEntry({
    required this.date,
    this.weight,
    this.height,
    this.photoPaths = const [],
    this.workoutText,
    this.workoutTags = const [],
    this.thoughts,
    this.emotions = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'weight': weight,
      'height': height,
      'photo_paths': jsonEncode(photoPaths),
      'workout_text': workoutText,
      'workout_tags': jsonEncode(workoutTags),
      'thoughts': thoughts,
      'emotions': jsonEncode(emotions),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert from Map (from SQLite)
  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      date: DateTime.parse(map['date']),
      weight: map['weight'] as double?,
      height: map['height'] as double?,
      photoPaths: map['photo_paths'] != null 
          ? List<String>.from(jsonDecode(map['photo_paths']))
          : [],
      workoutText: map['workout_text'] as String?,
      workoutTags: map['workout_tags'] != null
          ? List<String>.from(jsonDecode(map['workout_tags']))
          : [],
      thoughts: map['thoughts'] as String?,
      emotions: map['emotions'] != null
          ? List<String>.from(jsonDecode(map['emotions']))
          : [],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

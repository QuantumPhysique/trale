import 'dart:convert';
import 'emotional_checkin.dart';

class DailyEntry {
  final DateTime date;
  final double? weight;
  final double? height;
  final List<String> photoPaths;
  final String? workoutText;
  final List<String> workoutTags;
  final String? thoughts;
  final List<EmotionalCheckIn> emotionalCheckIns;
  final DateTime timestamp;
  
  /// Whether this entry has been saved and is now immutable
  final bool isImmutable;

  DailyEntry({
    required this.date,
    this.weight,
    this.height,
    this.photoPaths = const [],
    this.workoutText,
    this.workoutTags = const [],
    this.thoughts,
    this.emotionalCheckIns = const [],
    DateTime? timestamp,
    this.isImmutable = false,
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
      'emotional_checkins': jsonEncode(
        emotionalCheckIns.map((e) => e.toJson()).toList()
      ),
      'timestamp': timestamp.toIso8601String(),
      'is_immutable': isImmutable ? 1 : 0,
    };
  }

  // Convert from Map (from SQLite)
  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    // Parse emotional check-ins from JSON
    List<EmotionalCheckIn> checkIns = [];
    if (map['emotional_checkins'] != null && map['emotional_checkins'] != '') {
      final List<dynamic> jsonList = jsonDecode(map['emotional_checkins']);
      checkIns = jsonList
          .map((json) => EmotionalCheckIn.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
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
      emotionalCheckIns: checkIns,
      timestamp: DateTime.parse(map['timestamp']),
      isImmutable: (map['is_immutable'] as int?) == 1,
    );
  }
}

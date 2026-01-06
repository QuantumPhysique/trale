import 'dart:convert';
import 'emotional_checkin.dart';

class DailyEntry {

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

  // Convert from Map (from SQLite)
  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    // Parse emotional check-ins from JSON
    List<EmotionalCheckIn> checkIns = [];
    if (map['emotional_checkins'] != null && map['emotional_checkins'] != '') {
      try {
        final List<dynamic> jsonList = jsonDecode(map['emotional_checkins']);
        checkIns = jsonList
            .where((json) => json is Map<String, dynamic>)
            .map((json) => EmotionalCheckIn.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Log parse error, keep empty list
        checkIns = [];
      }
    }
    
    // Safe parsing for lists with try-catch
    List<String> photoPaths = [];
    try {
      if (map['photo_paths'] != null) {
        photoPaths = List<String>.from(jsonDecode(map['photo_paths']));
      }
    } catch (e) {
      photoPaths = [];
    }
    
    List<String> workoutTags = [];
    try {
      if (map['workout_tags'] != null) {
        workoutTags = List<String>.from(jsonDecode(map['workout_tags']));
      }
    } catch (e) {
      workoutTags = [];
    }
    
    // Safe numeric parsing
    double? weight;
    if (map['weight'] != null) {
      if (map['weight'] is num) {
        weight = (map['weight'] as num).toDouble();
      } else {
        weight = double.tryParse(map['weight'].toString());
      }
    }
    
    double? height;
    if (map['height'] != null) {
      if (map['height'] is num) {
        height = (map['height'] as num).toDouble();
      } else {
        height = double.tryParse(map['height'].toString());
      }
    }
    
    return DailyEntry(
      date: DateTime.tryParse(map['date']) ?? DateTime.now(),
      weight: weight,
      height: height,
      photoPaths: photoPaths,
      workoutText: map['workout_text'] as String?,
      workoutTags: workoutTags,
      thoughts: map['thoughts'] as String?,
      emotionalCheckIns: checkIns,
      timestamp: DateTime.tryParse(map['timestamp']) ?? DateTime.now(),
      isImmutable: (map['is_immutable'] as int?) == 1,
    );
  }
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

  // Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'weight': weight,
      'height': height,
      'photo_paths': jsonEncode(photoPaths),
      'workout_text': workoutText,
      'workout_tags': jsonEncode(workoutTags),
      'thoughts': thoughts,
      'emotional_checkins': jsonEncode(
        emotionalCheckIns.map((EmotionalCheckIn e) => e.toJson()).toList()
      ),
      'timestamp': timestamp.toIso8601String(),
      'is_immutable': isImmutable ? 1 : 0,
    };
  }
}

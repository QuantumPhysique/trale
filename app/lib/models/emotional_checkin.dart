import 'dart:convert';

/// Represents a single emotional check-in at a specific moment in time.
/// Emotional check-ins are immutable and bundled within a daily entry.
class EmotionalCheckIn {
  /// Exact timestamp when this check-in was created
  final DateTime timestamp;
  
  /// List of 1-4 emotion emojis selected from the 8 available options
  final List<String> emotions;
  
  /// User's written reflection about their emotional state (max 500 characters)
  final String text;

  /// Available emotion options (8 total, select any 4)
  static const Map<String, String> availableEmotions = {
    '😠': 'Anger',
    '😨': 'Fear',
    '😣': 'Pain',
    '😔': 'Shame',
    '😞': 'Guilt',
    '😊': 'Joy',
    '💪': 'Strength',
    '❤️': 'Love',
  };

  /// Maximum number of emotions that can be selected
  static const int maxEmotionCount = 4;
  
  /// Maximum character length for the text field
  static const int maxTextLength = 500;

  EmotionalCheckIn({
    required this.timestamp,
    required this.emotions,
    required this.text,
  }) {
    // Validation
    if (emotions.isEmpty || emotions.length > maxEmotionCount) {
      throw ArgumentError(
        'Emotions must contain 1-$maxEmotionCount items, got ${emotions.length}'
      );
    }
    
    if (!emotions.every((e) => availableEmotions.containsKey(e))) {
      throw ArgumentError('All emotions must be from the available set');
    }
    
    if (text.length > maxTextLength) {
      throw ArgumentError(
        'Text must be $maxTextLength characters or less, got ${text.length}'
      );
    }
  }

  /// Convert to JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'emotions': emotions,
      'text': text,
    };
  }

  /// Create from JSON map
  factory EmotionalCheckIn.fromJson(Map<String, dynamic> json) {
    return EmotionalCheckIn(
      timestamp: DateTime.parse(json['timestamp'] as String),
      emotions: List<String>.from(json['emotions'] as List),
      text: json['text'] as String,
    );
  }

  /// Create a copy with optional field updates
  EmotionalCheckIn copyWith({
    DateTime? timestamp,
    List<String>? emotions,
    String? text,
  }) {
    return EmotionalCheckIn(
      timestamp: timestamp ?? this.timestamp,
      emotions: emotions ?? this.emotions,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionalCheckIn &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          _listEquals(emotions, other.emotions) &&
          text == other.text;

  @override
  int get hashCode => Object.hash(
    timestamp,
    Object.hashAll(emotions),
    text,
  );

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'EmotionalCheckIn('
        'timestamp: $timestamp, '
        'emotions: ${emotions.join("")}, '
        'text: "${text.length > 50 ? '${text.substring(0, 50)}...' : text}"'
        ')';
  }
}

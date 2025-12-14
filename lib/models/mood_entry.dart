import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum MoodType {
  veryHappy(5, 'Very Happy', '😄', 'veryHappy'),
  happy(4, 'Happy', '😊', 'happy'),
  neutral(3, 'Neutral', '😐', 'neutral'),
  sad(2, 'Sad', '😢', 'sad'),
  verySad(1, 'Very Sad', '😞', 'verySad');

  final int value;
  final String label;
  final String emoji;
  final String colorKey;

  const MoodType(this.value, this.label, this.emoji, this.colorKey);

  /// Get the default color (for use outside of theme context)
  Color get defaultColor => AppTheme.moodColors[colorKey] ?? const Color(0xFF6B4EFF);

  /// Get color respecting colorblind mode from theme
  Color getColor(BuildContext context) {
    return context.moodTheme.getMoodColor(colorKey);
  }

  /// Legacy getter for backward compatibility - prefer getColor(context)
  int get colorValue => defaultColor.toARGB32();

  static MoodType fromValue(int value) {
    return MoodType.values.firstWhere(
      (mood) => mood.value == value,
      orElse: () => MoodType.neutral,
    );
  }
}

class MoodEntry {
  final String id;
  final DateTime dateTime;
  final MoodType mood;
  final String? note;
  final List<String> activities;

  MoodEntry({
    required this.id,
    required this.dateTime,
    required this.mood,
    this.note,
    this.activities = const [],
  });

  MoodEntry copyWith({
    String? id,
    DateTime? dateTime,
    MoodType? mood,
    String? note,
    List<String>? activities,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'mood': mood.value,
      'note': note,
      'activities': activities,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      mood: MoodType.fromValue(json['mood'] as int),
      note: json['note'] as String?,
      activities: List<String>.from(json['activities'] ?? []),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory MoodEntry.fromJsonString(String jsonString) {
    return MoodEntry.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
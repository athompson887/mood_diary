import 'package:flutter_test/flutter_test.dart';

import 'package:mood_diary/models/mood_entry.dart';

void main() {
  group('MoodEntry model tests', () {
    test('MoodEntry serialization works correctly', () {
      final entry = MoodEntry(
        id: 'test-id',
        dateTime: DateTime(2024, 1, 15, 10, 30),
        mood: MoodType.happy,
        note: 'Test note',
        activities: ['Work', 'Exercise'],
      );

      final json = entry.toJson();
      final restored = MoodEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.mood, entry.mood);
      expect(restored.note, entry.note);
      expect(restored.activities, entry.activities);
    });

    test('MoodType.fromValue returns correct mood', () {
      expect(MoodType.fromValue(5), MoodType.veryHappy);
      expect(MoodType.fromValue(4), MoodType.happy);
      expect(MoodType.fromValue(3), MoodType.neutral);
      expect(MoodType.fromValue(2), MoodType.sad);
      expect(MoodType.fromValue(1), MoodType.verySad);
      expect(MoodType.fromValue(99), MoodType.neutral); // fallback
    });

    test('MoodEntry copyWith works correctly', () {
      final entry = MoodEntry(
        id: 'test-id',
        dateTime: DateTime(2024, 1, 15, 10, 30),
        mood: MoodType.happy,
        note: 'Original note',
        activities: ['Work'],
      );

      final modified = entry.copyWith(
        mood: MoodType.veryHappy,
        note: 'Modified note',
      );

      expect(modified.id, entry.id);
      expect(modified.mood, MoodType.veryHappy);
      expect(modified.note, 'Modified note');
      expect(modified.activities, entry.activities);
    });

    test('MoodType has correct properties', () {
      expect(MoodType.veryHappy.value, 5);
      expect(MoodType.veryHappy.label, 'Very Happy');
      expect(MoodType.veryHappy.emoji, '😄');

      expect(MoodType.verySad.value, 1);
      expect(MoodType.verySad.label, 'Very Sad');
      expect(MoodType.verySad.emoji, '😞');
    });
  });
}

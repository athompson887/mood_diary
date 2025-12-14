import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class MoodStorageService {
  static const String _storageKey = 'mood_entries';

  Future<List<MoodEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_storageKey);

    if (entriesJson == null || entriesJson.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(entriesJson) as List<dynamic>;
    return decoded
        .map((json) => MoodEntry.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> saveEntry(MoodEntry entry) async {
    final entries = await getAllEntries();
    final existingIndex = entries.indexWhere((e) => e.id == entry.id);

    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }

    await _saveEntries(entries);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getAllEntries();
    entries.removeWhere((e) => e.id == id);
    await _saveEntries(entries);
  }

  Future<void> _saveEntries(List<MoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<MoodEntry>> getEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final entries = await getAllEntries();
    return entries.where((e) {
      return e.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
          e.dateTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<MoodEntry?> getEntryForDate(DateTime date) async {
    final entries = await getAllEntries();
    try {
      return entries.firstWhere(
        (e) =>
            e.dateTime.year == date.year &&
            e.dateTime.month == date.month &&
            e.dateTime.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<MoodType, int>> getMoodCounts({int? lastDays}) async {
    List<MoodEntry> entries = await getAllEntries();

    if (lastDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: lastDays));
      entries = entries.where((e) => e.dateTime.isAfter(cutoff)).toList();
    }

    final Map<MoodType, int> counts = {};
    for (final mood in MoodType.values) {
      counts[mood] = 0;
    }
    for (final entry in entries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    return counts;
  }

  Future<double?> getAverageMood({int? lastDays}) async {
    List<MoodEntry> entries = await getAllEntries();

    if (lastDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: lastDays));
      entries = entries.where((e) => e.dateTime.isAfter(cutoff)).toList();
    }

    if (entries.isEmpty) return null;

    final total = entries.fold<int>(0, (sum, e) => sum + e.mood.value);
    return total / entries.length;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<int> getEntryCount() async {
    final entries = await getAllEntries();
    return entries.length;
  }
}
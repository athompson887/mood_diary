import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage_service.dart';
import 'add_mood_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final MoodStorageService _storageService = MoodStorageService();
  DateTime _selectedMonth = DateTime.now();
  Map<DateTime, MoodEntry> _entriesMap = {};
  MoodEntry? _selectedEntry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  /// Public method to reload data from outside
  void reload() => _loadEntries();

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);

    final entries = await _storageService.getAllEntries();
    final map = <DateTime, MoodEntry>{};

    for (final entry in entries) {
      final dateKey = DateTime(
        entry.dateTime.year,
        entry.dateTime.month,
        entry.dateTime.day,
      );
      map[dateKey] = entry;
    }

    setState(() {
      _entriesMap = map;
      _isLoading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
      _selectedEntry = null;
    });
  }

  Future<void> _navigateToAddMood(MoodEntry entry) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMoodScreen(existingEntry: entry),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthSelector(),
                _buildCalendarHeader(),
                _buildCalendarGrid(),
                if (_selectedEntry != null) _buildSelectedEntryCard(),
              ],
            ),
    );
  }

  Widget _buildMonthSelector() {
    final monthYear = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          SizedBox(
            width: 160,
            child: Text(
              monthYear,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: days
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final cells = <Widget>[];

    // Add empty cells for days before the first of the month
    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Add cells for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final entry = _entriesMap[date];
      final isToday = _isToday(date);
      final isSelected = _selectedEntry != null &&
          _selectedEntry!.dateTime.year == date.year &&
          _selectedEntry!.dateTime.month == date.month &&
          _selectedEntry!.dateTime.day == date.day;

      cells.add(
        GestureDetector(
          onTap: () {
            if (entry != null) {
              setState(() => _selectedEntry = entry);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : entry != null
                      ? Color(entry.mood.colorValue).withAlpha(51)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (entry != null)
                  Text(
                    entry.mood.emoji,
                    style: const TextStyle(fontSize: 16),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          crossAxisCount: 7,
          childAspectRatio: 1,
          children: cells,
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildSelectedEntryCard() {
    final entry = _selectedEntry!;
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(entry.dateTime);
    final timeStr = DateFormat('h:mm a').format(entry.dateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                entry.mood.emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.mood.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(entry.mood.colorValue),
                      ),
                    ),
                    Text(
                      '$dateStr at $timeStr',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToAddMood(entry),
              ),
            ],
          ),
          if (entry.activities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: entry.activities
                  .map((a) => Chip(
                        label: Text(a, style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
          if (entry.note != null && entry.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              entry.note!,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

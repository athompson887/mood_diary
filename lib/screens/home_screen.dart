import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage_service.dart';
import 'add_mood_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final MoodStorageService _storageService = MoodStorageService();
  MoodEntry? _todayEntry;
  List<MoodEntry> _recentEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Public method to reload data from outside
  void reload() => _loadData();

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final today = DateTime.now();
    final todayEntry = await _storageService.getEntryForDate(today);
    final allEntries = await _storageService.getAllEntries();

    setState(() {
      _todayEntry = todayEntry;
      _recentEntries = allEntries.take(7).toList();
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddMood([MoodEntry? existingEntry]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMoodScreen(existingEntry: existingEntry),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Diary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTodayCard(),
                    const SizedBox(height: 24),
                    _buildRecentEntries(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMood(),
        icon: const Icon(Icons.add),
        label: const Text('Log Mood'),
      ),
    );
  }

  Widget _buildTodayCard() {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Card(
      child: InkWell(
        onTap: () => _navigateToAddMood(_todayEntry),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                today,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (_todayEntry != null) ...[
                Text(
                  _todayEntry!.mood.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 8),
                Text(
                  _todayEntry!.mood.label,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _todayEntry!.mood.getColor(context),
                  ),
                ),
                if (_todayEntry!.note != null && _todayEntry!.note!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _todayEntry!.note!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _navigateToAddMood(_todayEntry),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ] else ...[
                Icon(
                  Icons.sentiment_neutral_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'How are you feeling today?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to log your mood',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEntries() {
    final theme = Theme.of(context);

    if (_recentEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentEntries.length,
          itemBuilder: (context, index) {
            final entry = _recentEntries[index];
            return _buildEntryTile(entry);
          },
        ),
      ],
    );
  }

  Widget _buildEntryTile(MoodEntry entry) {
    final theme = Theme.of(context);
    final moodColor = entry.mood.getColor(context);
    final dateStr = DateFormat('EEE, MMM d').format(entry.dateTime);
    final timeStr = DateFormat('h:mm a').format(entry.dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _navigateToAddMood(entry),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: moodColor.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          entry.mood.label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: moodColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$dateStr at $timeStr'),
            if (entry.activities.isNotEmpty)
              Text(
                entry.activities.join(', '),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
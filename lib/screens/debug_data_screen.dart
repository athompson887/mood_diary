import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage_service.dart';

class DebugDataScreen extends StatefulWidget {
  const DebugDataScreen({super.key});

  @override
  State<DebugDataScreen> createState() => _DebugDataScreenState();
}

class _DebugDataScreenState extends State<DebugDataScreen> {
  final MoodStorageService _moodService = MoodStorageService();
  final Uuid _uuid = const Uuid();
  bool _isGenerating = false;
  bool _isClearing = false;
  int _entryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEntryCount();
  }

  Future<void> _loadEntryCount() async {
    final count = await _moodService.getEntryCount();
    if (mounted) {
      setState(() => _entryCount = count);
    }
  }

  Future<void> _generateTestData() async {
    setState(() => _isGenerating = true);

    final random = Random();
    final now = DateTime.now();
    int generatedCount = 0;

    // Generate 30 days of mood data with realistic patterns
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));

      // Create mood pattern:
      // Week 1 (days 0-6): Generally good mood (3-5)
      // Week 2 (days 7-13): Mixed mood (2-4)
      // Week 3 (days 14-20): Lower mood (1-3)
      // Week 4 (days 21-29): Recovery (3-5)
      int moodValue;
      if (i < 7) {
        moodValue = random.nextInt(3) + 3; // 3-5
      } else if (i < 14) {
        moodValue = random.nextInt(3) + 2; // 2-4
      } else if (i < 21) {
        moodValue = random.nextInt(3) + 1; // 1-3
      } else {
        moodValue = random.nextInt(3) + 3; // 3-5
      }

      final activities = _randomActivities(random);
      final note = _randomNote(random, moodValue);

      final entry = MoodEntry(
        id: _uuid.v4(),
        dateTime: DateTime(
          date.year,
          date.month,
          date.day,
          8 + random.nextInt(12), // Random hour between 8am and 8pm
          random.nextInt(60),
        ),
        mood: MoodType.fromValue(moodValue),
        activities: activities,
        note: note,
      );

      await _moodService.saveEntry(entry);
      generatedCount++;
    }

    await _loadEntryCount();
    setState(() => _isGenerating = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Generated $generatedCount mood entries'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<String> _randomActivities(Random random) {
    final allActivities = [
      'Work',
      'Exercise',
      'Family',
      'Friends',
      'Hobby',
      'Rest',
      'Travel',
      'Shopping',
      'Reading',
      'Gaming',
      'Music',
      'Nature'
    ];
    final count = random.nextInt(3) + 1;
    allActivities.shuffle(random);
    return allActivities.take(count).toList();
  }

  String? _randomNote(Random random, int moodValue) {
    if (random.nextBool()) return null;

    final goodNotes = [
      'Had a great day!',
      'Feeling productive',
      'Nice weather today',
      'Good conversation with friends',
    ];
    final neutralNotes = [
      'Just an average day',
      'Nothing special happened',
      'Quiet day at home',
    ];
    final badNotes = [
      'Feeling tired',
      'Stressful day at work',
      'Didn\'t sleep well',
      'Feeling a bit down',
    ];

    if (moodValue >= 4) {
      return goodNotes[random.nextInt(goodNotes.length)];
    } else if (moodValue >= 3) {
      return neutralNotes[random.nextInt(neutralNotes.length)];
    } else {
      return badNotes[random.nextInt(badNotes.length)];
    }
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 12),
            Text(l10n.clearAllData),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.clearDataConfirmation),
            const SizedBox(height: 12),
            Text(
              'This will delete $_entryCount entries.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClearing = true);

    // Clear all mood entries
    await _moodService.clearAll();

    await _loadEntryCount();
    setState(() => _isClearing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete_forever, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.dataCleared),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debugData),
        backgroundColor: Colors.orange.shade100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card with stats
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.developer_mode,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.debugData,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            Text(
                              'Current entries: $_entryCount',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadEntryCount,
                        tooltip: 'Refresh count',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use these tools to generate test data for development and testing purposes.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Section
          Text(
            'QUICK ACTIONS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            icon: Icons.add_chart,
            title: l10n.generateTestData,
            subtitle: 'Creates 30 mood entries (one per day for the last 30 days)',
            buttonText: 'Generate 30 Days',
            isLoading: _isGenerating,
            onPressed: _generateTestData,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.delete_forever,
            title: l10n.clearAllData,
            subtitle: 'Removes all $_entryCount mood entries permanently',
            buttonText: 'Clear All Data',
            isLoading: _isClearing,
            onPressed: _entryCount > 0 ? _clearAllData : null,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required bool isLoading,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    final isDisabled = onPressed == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDisabled ? Colors.grey : color).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: isDisabled ? Colors.grey : color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDisabled ? Colors.grey : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(icon, size: 18),
                label: Text(buttonText),
                style: FilledButton.styleFrom(
                  backgroundColor: isDisabled ? Colors.grey : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

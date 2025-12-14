import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage_service.dart';
import '../widgets/journal_editor.dart';
import '../theme/app_theme.dart';
import 'fullscreen_journal_screen.dart';

class AddMoodScreen extends StatefulWidget {
  final MoodEntry? existingEntry;

  const AddMoodScreen({super.key, this.existingEntry});

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen>
    with SingleTickerProviderStateMixin {
  final MoodStorageService _storageService = MoodStorageService();
  final TextEditingController _noteController = TextEditingController();
  final Uuid _uuid = const Uuid();

  MoodType? _selectedMood;
  final List<String> _selectedActivities = [];
  bool _isSaving = false;
  bool _showActivities = false;

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  final List<String> _availableActivities = [
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
    'Nature',
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    if (widget.existingEntry != null) {
      _selectedMood = widget.existingEntry!.mood;
      _noteController.text = widget.existingEntry!.note ?? '';
      _selectedActivities.addAll(widget.existingEntry!.activities);
      if (_selectedActivities.isNotEmpty) {
        _showActivities = true;
        _expandController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select how you\'re feeling'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final entry = MoodEntry(
      id: widget.existingEntry?.id ?? _uuid.v4(),
      dateTime: widget.existingEntry?.dateTime ?? DateTime.now(),
      mood: _selectedMood!,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      activities: _selectedActivities,
    );

    await _storageService.saveEntry(entry);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _openFullscreenEditor() async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullscreenJournalScreen(
          controller: _noteController,
          selectedMood: _selectedMood,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    setState(() {}); // Refresh to show updated text
  }

  void _toggleActivities() {
    setState(() {
      _showActivities = !_showActivities;
      if (_showActivities) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  List<String> _getWritingPrompts() {
    if (_selectedMood == null) {
      return [
        'What\'s on your mind right now?',
        'How has your day been?',
        'What are you grateful for today?',
      ];
    }

    switch (_selectedMood!) {
      case MoodType.veryHappy:
        return [
          'What made you feel so wonderful?',
          'Describe this amazing moment!',
          'Who would you love to share this joy with?',
        ];
      case MoodType.happy:
        return [
          'What brought a smile to your face?',
          'What\'s going well today?',
          'What small win are you celebrating?',
        ];
      case MoodType.neutral:
        return [
          'Take a moment to check in with yourself...',
          'What\'s on your mind?',
          'How are you really feeling?',
        ];
      case MoodType.sad:
        return [
          'It\'s okay to feel this way...',
          'What would help right now?',
          'Let it out, this is your safe space.',
        ];
      case MoodType.verySad:
        return [
          'I\'m here with you...',
          'Write whatever you need to say.',
          'You don\'t have to be strong right now.',
        ];
    }
  }

  Color _getAccentColor(BuildContext context) {
    if (_selectedMood == null) {
      return Theme.of(context).colorScheme.primary;
    }
    return _selectedMood!.getColor(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingEntry != null;
    final accentColor = _getAccentColor(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'How are you feeling?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_noteController.text.isNotEmpty || _selectedMood != null)
            TextButton(
              onPressed: _isSaving ? null : _saveMood,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Text(
                      isEditing ? 'Update' : 'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: _selectedMood != null
                            ? accentColor
                            : theme.colorScheme.onSurface.withAlpha(100),
                      ),
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Mood selector - compact but accessible
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accentColor.withAlpha(20),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                _buildMoodSelector(),
                const SizedBox(height: 12),
                // Activities toggle
                GestureDetector(
                  onTap: _toggleActivities,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showActivities
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedActivities.isEmpty
                              ? 'Add activities'
                              : '${_selectedActivities.length} ${_selectedActivities.length == 1 ? 'activity' : 'activities'} selected',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedActivities.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ...(_selectedActivities.take(3).map((activity) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  activity,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            );
                          })),
                        ],
                      ],
                    ),
                  ),
                ),
                // Expandable activities section
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildActivitySelector(),
                  ),
                ),
              ],
            ),
          ),

          // Journal editor - the main event
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: JournalEditor(
                controller: _noteController,
                writingPrompts: _getWritingPrompts(),
                accentColor: accentColor,
                onExpandPressed: _openFullscreenEditor,
                hintText: _selectedMood != null
                    ? _getHintForMood(_selectedMood!)
                    : 'Start writing your thoughts...',
              ),
            ),
          ),

          // Save button at bottom
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: _isSaving ? null : _saveMood,
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedMood != null
                      ? accentColor
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.check : Icons.save_outlined,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Update Entry' : 'Save Entry',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintForMood(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return 'Capture this wonderful moment...';
      case MoodType.happy:
        return 'Share what\'s making you smile...';
      case MoodType.neutral:
        return 'Take a moment to reflect...';
      case MoodType.sad:
        return 'It\'s okay to let it out...';
      case MoodType.verySad:
        return 'This is your safe space...';
    }
  }

  Widget _buildMoodSelector() {
    final theme = Theme.of(context);
    final moodTheme = context.moodTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: MoodType.values.map((mood) {
          final isSelected = _selectedMood == mood;
          final moodColor = mood.getColor(context);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedMood = mood),
              child: AnimatedContainer(
                duration: moodTheme.animationDuration,
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 20 : 16,
                  vertical: isSelected ? 14 : 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? moodColor.withAlpha(40) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? moodColor : theme.colorScheme.outline.withAlpha(80),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: moodColor.withAlpha(50),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: moodTheme.animationDuration,
                      style: TextStyle(fontSize: isSelected ? 32 : 26),
                      child: Text(mood.emoji),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: moodColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivitySelector() {
    final theme = Theme.of(context);
    final accentColor = _getAccentColor(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableActivities.map((activity) {
        final isSelected = _selectedActivities.contains(activity);
        return FilterChip(
          label: Text(activity),
          selected: isSelected,
          selectedColor: accentColor.withAlpha(50),
          checkmarkColor: accentColor,
          side: BorderSide(
            color: isSelected ? accentColor : theme.colorScheme.outline.withAlpha(80),
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedActivities.add(activity);
              } else {
                _selectedActivities.remove(activity);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
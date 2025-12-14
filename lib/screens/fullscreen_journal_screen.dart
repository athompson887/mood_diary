import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/journal_editor.dart';
import '../models/mood_entry.dart';

/// An immersive, full-screen journaling experience designed for catharsis
class FullscreenJournalScreen extends StatefulWidget {
  final TextEditingController controller;
  final MoodType? selectedMood;

  const FullscreenJournalScreen({
    super.key,
    required this.controller,
    this.selectedMood,
  });

  @override
  State<FullscreenJournalScreen> createState() => _FullscreenJournalScreenState();
}

class _FullscreenJournalScreenState extends State<FullscreenJournalScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fadeController.dispose();
    super.dispose();
  }

  List<String> _getPromptsForMood(MoodType? mood) {
    if (mood == null) {
      return [
        'What\'s on your mind right now?',
        'How has your day been so far?',
        'What are you grateful for today?',
        'Describe a moment that stood out today.',
        'What would make today even better?',
      ];
    }

    switch (mood) {
      case MoodType.veryHappy:
        return [
          'What made you feel so wonderful today?',
          'Describe the joy you\'re feeling right now.',
          'Who or what contributed to this happiness?',
          'How can you carry this feeling forward?',
          'What would you tell your future self about this moment?',
        ];
      case MoodType.happy:
        return [
          'What brought a smile to your face today?',
          'Describe a pleasant moment from your day.',
          'What are you looking forward to?',
          'Who made a positive impact on your day?',
          'What small win are you celebrating?',
        ];
      case MoodType.neutral:
        return [
          'Take a moment to check in with yourself...',
          'What\'s occupying your thoughts right now?',
          'Is there something you\'re processing?',
          'What would shift your mood in either direction?',
          'Describe your day without judgment.',
        ];
      case MoodType.sad:
        return [
          'It\'s okay to feel this way. What happened?',
          'What do you need right now?',
          'Is there something weighing on your heart?',
          'What would help you feel even slightly better?',
          'Write without holding back. This is your safe space.',
        ];
      case MoodType.verySad:
        return [
          'I\'m here with you. Let it all out...',
          'What\'s hurting you right now?',
          'You don\'t have to be strong here. What do you need to say?',
          'Write whatever comes to mind. No judgment.',
          'Sometimes the hardest feelings need the most space. Take yours.',
        ];
    }
  }

  Color _getAccentColor(BuildContext context, MoodType? mood) {
    if (mood == null) return Theme.of(context).colorScheme.primary;
    return mood.getColor(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _getAccentColor(context, widget.selectedMood);
    final prompts = _getPromptsForMood(widget.selectedMood);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accentColor.withAlpha(15),
                theme.colorScheme.surface,
                theme.colorScheme.surface,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Minimal header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                        tooltip: 'Close',
                      ),
                      const Spacer(),
                      if (widget.selectedMood != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.selectedMood!.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.selectedMood!.label,
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Journal editor takes most of the screen
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: JournalEditor(
                      controller: widget.controller,
                      writingPrompts: prompts,
                      accentColor: accentColor,
                      hintText: _getHintForMood(widget.selectedMood),
                      isExpanded: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getHintForMood(MoodType? mood) {
    if (mood == null) return 'Let your thoughts flow freely...';

    switch (mood) {
      case MoodType.veryHappy:
        return 'Capture this beautiful moment...';
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
}
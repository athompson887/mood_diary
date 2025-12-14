import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';
import '../theme/app_theme.dart';

/// A rich, cathartic journal editor with formatting and emoji support
class JournalEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final List<String> writingPrompts;
  final Color? accentColor;
  final VoidCallback? onExpandPressed;
  final bool isExpanded;

  const JournalEditor({
    super.key,
    required this.controller,
    this.hintText,
    this.writingPrompts = const [],
    this.accentColor,
    this.onExpandPressed,
    this.isExpanded = false,
  });

  @override
  State<JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<JournalEditor>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _showEmojiPicker = false;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  int _wordCount = 0;
  int _currentPromptIndex = 0;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _wordCount = _calculateWordCount(widget.controller.text);
    widget.controller.addListener(_onTextChanged);

    // Breathing animation for the calming effect
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathingAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start or stop breathing animation based on reduce motion setting
    final moodTheme = context.moodTheme;
    if (moodTheme.accessibility.reduceMotion) {
      _breathingController.stop();
      _breathingController.value = 1.0; // Set to final value
    } else {
      if (!_breathingController.isAnimating) {
        _breathingController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _wordCount = _calculateWordCount(widget.controller.text);
    });
  }

  int _calculateWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  void _insertEmoji(Emoji emoji) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji.emoji,
    );
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.emoji.length,
      ),
    );
  }

  void _applyFormatting(String prefix, String suffix) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (selection.start == selection.end) {
      // No selection, insert at cursor
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$suffix');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + prefix.length),
      );
    } else {
      // Wrap selection
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.end + prefix.length,
        ),
      );
    }
  }

  void _nextPrompt() {
    if (widget.writingPrompts.isEmpty) return;
    setState(() {
      _currentPromptIndex = (_currentPromptIndex + 1) % widget.writingPrompts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Writing prompt card
        if (widget.writingPrompts.isNotEmpty && widget.controller.text.isEmpty)
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathingAnimation.value,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _nextPrompt,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withAlpha(30),
                      accentColor.withAlpha(15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accentColor.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: accentColor.withAlpha(180),
                      size: 28,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.writingPrompts[_currentPromptIndex],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withAlpha(180),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap for another prompt',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Formatting toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              _FormatButton(
                icon: Icons.format_bold,
                isActive: _isBold,
                onPressed: () {
                  setState(() => _isBold = !_isBold);
                  _applyFormatting('**', '**');
                },
                tooltip: 'Bold',
              ),
              _FormatButton(
                icon: Icons.format_italic,
                isActive: _isItalic,
                onPressed: () {
                  setState(() => _isItalic = !_isItalic);
                  _applyFormatting('_', '_');
                },
                tooltip: 'Italic',
              ),
              _FormatButton(
                icon: Icons.format_underlined,
                isActive: _isUnderline,
                onPressed: () {
                  setState(() => _isUnderline = !_isUnderline);
                  _applyFormatting('~', '~');
                },
                tooltip: 'Underline',
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: theme.colorScheme.outline.withAlpha(50),
              ),
              const SizedBox(width: 8),
              _FormatButton(
                icon: Icons.emoji_emotions_outlined,
                isActive: _showEmojiPicker,
                onPressed: () {
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                    if (_showEmojiPicker) {
                      _focusNode.unfocus();
                    }
                  });
                },
                tooltip: 'Emoji',
              ),
              _FormatButton(
                icon: Icons.format_list_bulleted,
                onPressed: () => _applyFormatting('\n• ', ''),
                tooltip: 'Bullet point',
              ),
              const Spacer(),
              if (widget.onExpandPressed != null)
                _FormatButton(
                  icon: widget.isExpanded
                      ? Icons.close_fullscreen
                      : Icons.open_in_full,
                  onPressed: widget.onExpandPressed!,
                  tooltip: widget.isExpanded ? 'Exit fullscreen' : 'Fullscreen',
                ),
            ],
          ),
        ),

        // Text editor
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? accentColor.withAlpha(128)
                    : theme.colorScheme.outline.withAlpha(50),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Let your thoughts flow freely...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(100),
                        fontStyle: FontStyle.italic,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      if (_showEmojiPicker) {
                        setState(() => _showEmojiPicker = false);
                      }
                    },
                  ),
                ),
                // Word count and character info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withAlpha(30),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withAlpha(100),
                        ),
                      ),
                      const Spacer(),
                      if (_wordCount > 0)
                        AnimatedOpacity(
                          opacity: _wordCount > 0 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            children: [
                              Icon(
                                _wordCount >= 50
                                    ? Icons.auto_awesome
                                    : Icons.edit_note,
                                size: 16,
                                color: _wordCount >= 50
                                    ? Colors.amber
                                    : theme.colorScheme.onSurface.withAlpha(100),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _wordCount >= 100
                                    ? 'Deep reflection'
                                    : _wordCount >= 50
                                        ? 'Great flow!'
                                        : 'Keep writing...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _wordCount >= 50
                                      ? Colors.amber
                                      : theme.colorScheme.onSurface.withAlpha(100),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Emoji picker
        if (_showEmojiPicker)
          SizedBox(
            height: 280,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _insertEmoji(emoji);
              },
              config: Config(
                height: 280,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 28 * (Platform.isIOS ? 1.2 : 1.0),
                  backgroundColor: theme.colorScheme.surface,
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: theme.colorScheme.surface,
                  indicatorColor: accentColor,
                  iconColorSelected: accentColor,
                ),
                bottomActionBarConfig: const BottomActionBarConfig(
                  enabled: false,
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: theme.colorScheme.surface,
                  buttonIconColor: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FormatButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final String tooltip;

  const _FormatButton({
    required this.icon,
    this.isActive = false,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DebugModeState {
  final bool isEnabled;
  final int tapCount;
  final DateTime? lastTapTime;

  const DebugModeState({
    this.isEnabled = false,
    this.tapCount = 0,
    this.lastTapTime,
  });

  DebugModeState copyWith({
    bool? isEnabled,
    int? tapCount,
    DateTime? lastTapTime,
  }) {
    return DebugModeState(
      isEnabled: isEnabled ?? this.isEnabled,
      tapCount: tapCount ?? this.tapCount,
      lastTapTime: lastTapTime ?? this.lastTapTime,
    );
  }
}

class DebugModeNotifier extends StateNotifier<DebugModeState> {
  static const String _boxName = 'debug_settings';
  static const int _requiredTaps = 7;
  static const Duration _tapTimeout = Duration(seconds: 3);
  Box? _box;

  DebugModeNotifier() : super(const DebugModeState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _box = await Hive.openBox(_boxName);
    final isEnabled = _box?.get('debugModeEnabled', defaultValue: false) as bool;
    state = state.copyWith(isEnabled: isEnabled);
  }

  Future<void> _saveSettings() async {
    await _box?.put('debugModeEnabled', state.isEnabled);
  }

  /// Handle a tap on the version number
  /// Returns the number of remaining taps needed, or -1 if debug mode was just enabled
  int handleTap() {
    final now = DateTime.now();

    // Reset tap count if timeout exceeded
    if (state.lastTapTime != null &&
        now.difference(state.lastTapTime!) > _tapTimeout) {
      state = state.copyWith(tapCount: 0);
    }

    final newTapCount = state.tapCount + 1;

    if (newTapCount >= _requiredTaps) {
      // Toggle debug mode
      final newEnabled = !state.isEnabled;
      state = state.copyWith(
        isEnabled: newEnabled,
        tapCount: 0,
        lastTapTime: now,
      );
      _saveSettings();
      return -1; // Indicates debug mode was toggled
    }

    state = state.copyWith(
      tapCount: newTapCount,
      lastTapTime: now,
    );

    return _requiredTaps - newTapCount;
  }

  void setDebugMode(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
    _saveSettings();
  }

  int get remainingTaps => _requiredTaps - state.tapCount;
  bool get shouldShowHint => state.tapCount >= 4;
}

final debugModeProvider =
    StateNotifierProvider<DebugModeNotifier, DebugModeState>(
  (ref) => DebugModeNotifier(),
);

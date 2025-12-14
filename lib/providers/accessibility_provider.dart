import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AccessibilitySettings {
  final bool highContrast;
  final bool largeTapTargets;
  final bool colorBlindSafeMode;
  final bool reduceMotion;
  final bool dyslexiaFriendlyFont;
  final bool readableTextMode;

  const AccessibilitySettings({
    this.highContrast = false,
    this.largeTapTargets = false,
    this.colorBlindSafeMode = false,
    this.reduceMotion = false,
    this.dyslexiaFriendlyFont = false,
    this.readableTextMode = false,
  });

  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? largeTapTargets,
    bool? colorBlindSafeMode,
    bool? reduceMotion,
    bool? dyslexiaFriendlyFont,
    bool? readableTextMode,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      largeTapTargets: largeTapTargets ?? this.largeTapTargets,
      colorBlindSafeMode: colorBlindSafeMode ?? this.colorBlindSafeMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      dyslexiaFriendlyFont: dyslexiaFriendlyFont ?? this.dyslexiaFriendlyFont,
      readableTextMode: readableTextMode ?? this.readableTextMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'highContrast': highContrast,
        'largeTapTargets': largeTapTargets,
        'colorBlindSafeMode': colorBlindSafeMode,
        'reduceMotion': reduceMotion,
        'dyslexiaFriendlyFont': dyslexiaFriendlyFont,
        'readableTextMode': readableTextMode,
      };

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      highContrast: json['highContrast'] as bool? ?? false,
      largeTapTargets: json['largeTapTargets'] as bool? ?? false,
      colorBlindSafeMode: json['colorBlindSafeMode'] as bool? ?? false,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      dyslexiaFriendlyFont: json['dyslexiaFriendlyFont'] as bool? ?? false,
      readableTextMode: json['readableTextMode'] as bool? ?? false,
    );
  }
}

class AccessibilityNotifier extends StateNotifier<AccessibilitySettings> {
  static const String _boxName = 'accessibility_settings';
  Box? _box;

  AccessibilityNotifier() : super(const AccessibilitySettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _box = await Hive.openBox(_boxName);
    final data = _box?.get('settings');
    if (data != null) {
      state = AccessibilitySettings.fromJson(Map<String, dynamic>.from(data));
    }
  }

  Future<void> _saveSettings() async {
    await _box?.put('settings', state.toJson());
  }

  void setHighContrast(bool value) {
    state = state.copyWith(highContrast: value);
    _saveSettings();
  }

  void setLargeTapTargets(bool value) {
    state = state.copyWith(largeTapTargets: value);
    _saveSettings();
  }

  void setColorBlindSafeMode(bool value) {
    state = state.copyWith(colorBlindSafeMode: value);
    _saveSettings();
  }

  void setReduceMotion(bool value) {
    state = state.copyWith(reduceMotion: value);
    _saveSettings();
  }

  void setDyslexiaFriendlyFont(bool value) {
    state = state.copyWith(dyslexiaFriendlyFont: value);
    _saveSettings();
  }

  void setReadableTextMode(bool value) {
    state = state.copyWith(readableTextMode: value);
    _saveSettings();
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>(
  (ref) => AccessibilityNotifier(),
);

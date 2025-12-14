import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_diary/constants/app_color_schemes.dart';

/// Theme settings state
class ThemeSettings {
  final ThemeMode themeMode;
  final AppColorScheme colorScheme;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.colorScheme = AppColorScheme.defaultPurple,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    AppColorScheme? colorScheme,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }
}

/// Theme provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(
  ThemeNotifier.new,
);

/// Theme mode only provider (convenience)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});

/// Color scheme only provider (convenience)
final colorSchemeProvider = Provider<AppColorScheme>((ref) {
  return ref.watch(themeProvider).colorScheme;
});

class ThemeNotifier extends Notifier<ThemeSettings> {
  static const String _boxName = 'settings';
  static const String _themeModeKey = 'theme_mode';
  static const String _colorSchemeKey = 'color_scheme';

  @override
  ThemeSettings build() {
    _loadSettings();
    return const ThemeSettings();
  }

  /// Load theme settings from Hive
  Future<void> _loadSettings() async {
    try {
      final box = Hive.box(_boxName);
      final savedThemeMode = box.get(_themeModeKey) as String?;
      final savedColorScheme = box.get(_colorSchemeKey) as String?;

      ThemeMode themeMode = ThemeMode.system;
      AppColorScheme colorScheme = AppColorScheme.defaultPurple;

      if (savedThemeMode != null) {
        themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedThemeMode,
          orElse: () => ThemeMode.system,
        );
      }

      if (savedColorScheme != null) {
        colorScheme = AppColorScheme.fromName(savedColorScheme);
      }

      state = ThemeSettings(
        themeMode: themeMode,
        colorScheme: colorScheme,
      );
    } catch (e) {
      debugPrint('Failed to load theme settings: $e');
    }
  }

  /// Save theme settings to Hive
  Future<void> _saveSettings() async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_themeModeKey, state.themeMode.name);
      await box.put(_colorSchemeKey, state.colorScheme.name);
    } catch (e) {
      debugPrint('Failed to save theme settings: $e');
    }
  }

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    if (state.themeMode == mode) return;
    state = state.copyWith(themeMode: mode);
    _saveSettings();
  }

  /// Set color scheme
  void setColorScheme(AppColorScheme scheme) {
    if (state.colorScheme == scheme) return;
    state = state.copyWith(colorScheme: scheme);
    _saveSettings();
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  /// Reset to default theme
  void resetToDefault() {
    state = const ThemeSettings();
    _saveSettings();
  }
}

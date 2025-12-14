import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_color_schemes.dart';
import '../providers/accessibility_provider.dart';

/// App-wide theme configuration with accessibility support
class AppTheme {
  static const Color seedColor = Color(0xFF6B4EFF);

  /// Default color scheme
  static const AppColorScheme defaultColorScheme = AppColorScheme.defaultPurple;

  /// Standard mood colors
  static const Map<String, Color> moodColors = {
    'veryHappy': Color(0xFF4CAF50),
    'happy': Color(0xFF8BC34A),
    'neutral': Color(0xFFFFC107),
    'sad': Color(0xFFFF9800),
    'verySad': Color(0xFFF44336),
  };

  /// Colorblind-safe mood colors (deuteranopia/protanopia friendly)
  /// Uses blue-orange-yellow palette that's distinguishable for most color vision deficiencies
  static const Map<String, Color> colorBlindMoodColors = {
    'veryHappy': Color(0xFF0077BB), // Blue
    'happy': Color(0xFF33BBEE), // Cyan/Light blue
    'neutral': Color(0xFFEECC66), // Yellow/Gold
    'sad': Color(0xFFEE7733), // Orange
    'verySad': Color(0xFFCC3311), // Red-orange (distinct from green confusion)
  };

  static ThemeData buildTheme({
    required Brightness brightness,
    required AccessibilitySettings accessibility,
    AppColorScheme appColorScheme = AppColorScheme.defaultPurple,
  }) {
    final bool isDark = brightness == Brightness.dark;

    // Base color scheme using the selected app color scheme
    var colorScheme = ColorScheme.fromSeed(
      seedColor: appColorScheme.seedColor,
      brightness: brightness,
      contrastLevel: accessibility.highContrast ? 1.0 : 0.0,
    );

    // Base text theme with optional scaling and dyslexia-friendly font
    TextTheme textTheme = _buildTextTheme(
      brightness: brightness,
      useDyslexiaFont: accessibility.dyslexiaFriendlyFont,
      scaleFactor: accessibility.readableTextMode ? 1.2 : 1.0,
    );

    // Minimum tap target size
    final double minTapTarget = accessibility.largeTapTargets ? 56.0 : 44.0;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,

      // Card theme
      cardTheme: CardThemeData(
        elevation: accessibility.highContrast ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: accessibility.highContrast
              ? BorderSide(color: colorScheme.outline, width: 1)
              : BorderSide.none,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Button themes with proper tap targets
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(minTapTarget, minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(minTapTarget, minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(minTapTarget, minTapTarget),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: Size(minTapTarget, minTapTarget),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: accessibility.highContrast ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: accessibility.highContrast
                ? colorScheme.outline
                : colorScheme.outline.withAlpha(100),
            width: accessibility.highContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(accessibility.largeTapTargets ? 20 : 16),
      ),

      // Switch/checkbox themes
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(accessibility.largeTapTargets ? 12 : 8),
        ),
      ),

      // List tile
      listTileTheme: ListTileThemeData(
        minVerticalPadding: accessibility.largeTapTargets ? 12 : 8,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: accessibility.largeTapTargets ? 4 : 0,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        sizeConstraints: BoxConstraints(
          minWidth: accessibility.largeTapTargets ? 64 : 56,
          minHeight: accessibility.largeTapTargets ? 64 : 56,
        ),
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        height: accessibility.largeTapTargets ? 88 : 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Extensions for custom theming
      extensions: [
        MoodDiaryTheme(
          accessibility: accessibility,
          moodColors: accessibility.colorBlindSafeMode
              ? colorBlindMoodColors
              : moodColors,
        ),
      ],
    );
  }

  /// Build text theme with optional dyslexia-friendly font (Lexend) and scaling
  static TextTheme _buildTextTheme({
    required Brightness brightness,
    bool useDyslexiaFont = false,
    double scaleFactor = 1.0,
  }) {
    // Use Lexend for dyslexia-friendly mode - it's designed for readability
    // with features that help readers with dyslexia
    TextTheme baseTheme;

    if (useDyslexiaFont) {
      baseTheme = GoogleFonts.lexendTextTheme();
    } else {
      // Use default Material text theme
      baseTheme = brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme;
    }

    // Apply scale factor if needed
    if (scaleFactor != 1.0) {
      return baseTheme.apply(
        fontSizeFactor: scaleFactor,
      );
    }

    return baseTheme;
  }
}

/// Theme extension for mood diary specific theming
class MoodDiaryTheme extends ThemeExtension<MoodDiaryTheme> {
  final AccessibilitySettings accessibility;
  final Map<String, Color> moodColors;

  const MoodDiaryTheme({
    required this.accessibility,
    required this.moodColors,
  });

  /// Get animation duration (0 if reduce motion is enabled)
  Duration get animationDuration => accessibility.reduceMotion
      ? Duration.zero
      : const Duration(milliseconds: 250);

  /// Get longer animation duration
  Duration get slowAnimationDuration => accessibility.reduceMotion
      ? Duration.zero
      : const Duration(milliseconds: 500);

  /// Minimum tap target size
  double get minTapTarget => accessibility.largeTapTargets ? 56.0 : 44.0;

  /// Get mood color by key
  Color getMoodColor(String mood) =>
      moodColors[mood] ?? const Color(0xFF6B4EFF);

  /// Whether to use high contrast styling
  bool get useHighContrast => accessibility.highContrast;

  /// Whether colorblind mode is active
  bool get isColorBlindMode => accessibility.colorBlindSafeMode;

  @override
  MoodDiaryTheme copyWith({
    AccessibilitySettings? accessibility,
    Map<String, Color>? moodColors,
  }) {
    return MoodDiaryTheme(
      accessibility: accessibility ?? this.accessibility,
      moodColors: moodColors ?? this.moodColors,
    );
  }

  @override
  MoodDiaryTheme lerp(ThemeExtension<MoodDiaryTheme>? other, double t) {
    if (other is! MoodDiaryTheme) return this;
    return MoodDiaryTheme(
      accessibility: t < 0.5 ? accessibility : other.accessibility,
      moodColors: t < 0.5 ? moodColors : other.moodColors,
    );
  }
}

/// Extension to easily access MoodDiaryTheme from BuildContext
extension MoodDiaryThemeExtension on BuildContext {
  MoodDiaryTheme get moodTheme =>
      Theme.of(this).extension<MoodDiaryTheme>() ??
      MoodDiaryTheme(
        accessibility: const AccessibilitySettings(),
        moodColors: AppTheme.moodColors,
      );
}
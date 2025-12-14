import 'package:flutter/material.dart';

/// Available color schemes for the app
enum AppColorScheme {
  /// Default purple theme (Free)
  defaultPurple(
    name: 'Default',
    seedColor: Color(0xFF6B4EFF),
    isPremium: false,
    icon: Icons.palette,
  ),

  /// Ocean blue/teal theme (Premium)
  ocean(
    name: 'Ocean',
    seedColor: Color(0xFF0077B6),
    isPremium: true,
    icon: Icons.water,
  ),

  /// Forest green theme (Premium)
  forest(
    name: 'Forest',
    seedColor: Color(0xFF2D6A4F),
    isPremium: true,
    icon: Icons.forest,
  ),

  /// Sunset orange/pink theme (Premium)
  sunset(
    name: 'Sunset',
    seedColor: Color(0xFFE85D04),
    isPremium: true,
    icon: Icons.wb_twilight,
  ),

  /// Lavender purple/pink theme (Premium)
  lavender(
    name: 'Lavender',
    seedColor: Color(0xFF9D4EDD),
    isPremium: true,
    icon: Icons.local_florist,
  ),

  /// Rose pink/red theme (Premium)
  rose(
    name: 'Rose',
    seedColor: Color(0xFFE63946),
    isPremium: true,
    icon: Icons.favorite,
  ),

  /// Midnight dark blue theme (Premium)
  midnight(
    name: 'Midnight',
    seedColor: Color(0xFF1D3557),
    isPremium: true,
    icon: Icons.nightlight_round,
  ),

  /// Sage muted green theme (Premium)
  sage(
    name: 'Sage',
    seedColor: Color(0xFF6B8E6B),
    isPremium: true,
    icon: Icons.spa,
  );

  final String name;
  final Color seedColor;
  final bool isPremium;
  final IconData icon;

  const AppColorScheme({
    required this.name,
    required this.seedColor,
    required this.isPremium,
    required this.icon,
  });

  /// Get all free themes
  static List<AppColorScheme> get freeThemes =>
      values.where((scheme) => !scheme.isPremium).toList();

  /// Get all premium themes
  static List<AppColorScheme> get premiumThemes =>
      values.where((scheme) => scheme.isPremium).toList();

  /// Get color scheme from name
  static AppColorScheme fromName(String name) {
    return values.firstWhere(
      (scheme) => scheme.name == name,
      orElse: () => defaultPurple,
    );
  }
}

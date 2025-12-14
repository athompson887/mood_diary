import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  static const String _boxName = 'locale_settings';
  Box? _box;

  LocaleNotifier() : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _box = await Hive.openBox(_boxName);
    final languageCode = _box?.get('languageCode') as String?;
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale != null) {
      await _box?.put('languageCode', locale.languageCode);
    } else {
      await _box?.delete('languageCode');
    }
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return code;
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

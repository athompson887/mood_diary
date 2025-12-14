import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood Diary'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @moodDiary.
  ///
  /// In en, this message translates to:
  /// **'Mood Diary'**
  String get moodDiary;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @selectYourMood.
  ///
  /// In en, this message translates to:
  /// **'Select your mood'**
  String get selectYourMood;

  /// No description provided for @whatHaveYouBeenUpTo.
  ///
  /// In en, this message translates to:
  /// **'What have you been up to?'**
  String get whatHaveYouBeenUpTo;

  /// No description provided for @addNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNoteOptional;

  /// No description provided for @writeAboutYourDay.
  ///
  /// In en, this message translates to:
  /// **'Write about your day...'**
  String get writeAboutYourDay;

  /// No description provided for @saveEntry.
  ///
  /// In en, this message translates to:
  /// **'Save Entry'**
  String get saveEntry;

  /// No description provided for @updateEntry.
  ///
  /// In en, this message translates to:
  /// **'Update Entry'**
  String get updateEntry;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editEntry;

  /// No description provided for @pleaseSelectMood.
  ///
  /// In en, this message translates to:
  /// **'Please select a mood'**
  String get pleaseSelectMood;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Log Mood'**
  String get logMood;

  /// No description provided for @tapToLogMood.
  ///
  /// In en, this message translates to:
  /// **'Tap to log your mood'**
  String get tapToLogMood;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent Entries'**
  String get recentEntries;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @veryHappy.
  ///
  /// In en, this message translates to:
  /// **'Very Happy'**
  String get veryHappy;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get happy;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get sad;

  /// No description provided for @verySad.
  ///
  /// In en, this message translates to:
  /// **'Very Sad'**
  String get verySad;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @hobby.
  ///
  /// In en, this message translates to:
  /// **'Hobby'**
  String get hobby;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @gaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gaming;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @accessibilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust display and interaction settings'**
  String get accessibilityDescription;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// No description provided for @highContrastDescription.
  ///
  /// In en, this message translates to:
  /// **'Increase contrast for better visibility'**
  String get highContrastDescription;

  /// No description provided for @largeTapTargets.
  ///
  /// In en, this message translates to:
  /// **'Large Tap Targets'**
  String get largeTapTargets;

  /// No description provided for @largeTapTargetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Make buttons and controls easier to tap'**
  String get largeTapTargetsDescription;

  /// No description provided for @colorBlindSafeMode.
  ///
  /// In en, this message translates to:
  /// **'Colour Blind Safe Mode'**
  String get colorBlindSafeMode;

  /// No description provided for @colorBlindSafeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Avoid using red/green only for indicators'**
  String get colorBlindSafeModeDescription;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce Motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Minimise animations and transitions'**
  String get reduceMotionDescription;

  /// No description provided for @dyslexiaFriendlyFont.
  ///
  /// In en, this message translates to:
  /// **'Dyslexia Friendly Font'**
  String get dyslexiaFriendlyFont;

  /// No description provided for @dyslexiaFriendlyFontDescription.
  ///
  /// In en, this message translates to:
  /// **'Use OpenDyslexic font for easier reading'**
  String get dyslexiaFriendlyFontDescription;

  /// No description provided for @readableTextMode.
  ///
  /// In en, this message translates to:
  /// **'Readable Text Mode'**
  String get readableTextMode;

  /// No description provided for @readableTextModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Larger, more readable text throughout the app'**
  String get readableTextModeDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageDescription;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @debugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get debugMode;

  /// No description provided for @debugModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Debug mode enabled'**
  String get debugModeEnabled;

  /// No description provided for @debugModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Debug mode disabled'**
  String get debugModeDisabled;

  /// No description provided for @tapMoreToEnable.
  ///
  /// In en, this message translates to:
  /// **'{count} more taps to enable debug mode'**
  String tapMoreToEnable(int count);

  /// No description provided for @debugData.
  ///
  /// In en, this message translates to:
  /// **'Debug Data'**
  String get debugData;

  /// No description provided for @generateTestData.
  ///
  /// In en, this message translates to:
  /// **'Generate Test Data'**
  String get generateTestData;

  /// No description provided for @generateTestDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Create 30 days of sample mood entries'**
  String get generateTestDataDescription;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove all mood entries and settings'**
  String get clearAllDataDescription;

  /// No description provided for @clearDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data? This cannot be undone.'**
  String get clearDataConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @testDataGenerated.
  ///
  /// In en, this message translates to:
  /// **'Test data generated successfully'**
  String get testDataGenerated;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get dataCleared;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get totalEntries;

  /// No description provided for @averageMood.
  ///
  /// In en, this message translates to:
  /// **'Average Mood'**
  String get averageMood;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @moodDistribution.
  ///
  /// In en, this message translates to:
  /// **'Mood Distribution'**
  String get moodDistribution;

  /// No description provided for @noDataForThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No data for this week'**
  String get noDataForThisWeek;

  /// No description provided for @startLoggingToSeeTrends.
  ///
  /// In en, this message translates to:
  /// **'Start logging your mood to see trends'**
  String get startLoggingToSeeTrends;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage reminder settings'**
  String get notificationsDescription;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share the App'**
  String get shareApp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

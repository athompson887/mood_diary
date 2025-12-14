# Mood Diary

A beautiful, accessible mood tracking app built with Flutter to help you log your daily emotions, identify patterns, and gain insights into your mental wellbeing.

## Features

- **Daily Mood Logging** - Track your mood with intuitive emoji-based ratings
- **Notes & Activities** - Add context to your mood entries with notes and activities
- **Visual Statistics** - View mood trends and patterns with beautiful charts
- **Calendar History** - Browse your mood history in a calendar view
- **Accessibility First** - High contrast mode, dyslexia-friendly fonts, and more
- **Multi-language Support** - English and Spanish localization
- **Premium Features** - Extended history, advanced statistics, and more

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.0
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate localization files:
   ```bash
   flutter gen-l10n
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Building for Release

### Android

```bash
flutter build appbundle --release
```

The signed AAB will be at `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Then archive and upload via Xcode or fastlane.

## Fastlane

This project uses fastlane for automated screenshots and deployment.

### Setup

```bash
cd ios && bundle install
cd ../android && bundle install
```

### Commands

```bash
# iOS screenshots
cd fastlane && bundle exec fastlane ios screenshots

# Android release to Play Store (internal track)
bundle exec fastlane android release
```

## Project Structure

```
lib/
├── constants/       # App constants and configuration
├── l10n/           # Localization files
├── models/         # Data models
├── providers/      # Riverpod providers
├── screens/        # App screens
├── services/       # Business logic services
├── theme/          # App theming
└── widgets/        # Reusable widgets
```

## Configuration

### RevenueCat (In-App Purchases)

Update API keys in `lib/constants/revenue_cat_config.dart`:

```dart
static const String appleApiKey = 'your_apple_api_key';
static const String googleApiKey = 'your_google_api_key';
```

### Bundle IDs

- iOS: `com.athompson.mooddiary`
- Android: `com.athompson.mooddiary`

## Privacy

This app stores all data locally on your device. No personal data is collected or transmitted to external servers. See our [Privacy Policy](https://athompson.dev/mooddiary/privacy) for details.

## License

Copyright 2025 Andrew Thompson. All rights reserved.

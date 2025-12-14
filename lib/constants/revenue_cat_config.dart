/// RevenueCat Configuration
///
/// IMPORTANT: This file contains placeholder API keys.
/// You MUST replace these with your actual RevenueCat API keys before release.
///
/// HOW TO GET YOUR API KEYS:
/// 1. Sign up at https://app.revenuecat.com/signup
/// 2. Create a new project
/// 3. Go to Project Settings → API Keys
/// 4. Copy your iOS and Android keys
/// 5. Replace the placeholders below
///
/// SECURITY NOTE:
/// - These keys are PUBLIC keys and safe to include in your app
/// - They're used for SDK initialization only
/// - Never commit your secret API keys to source control
class RevenueCatConfig {
  /// iOS App Store API Key
  /// Get this from: https://app.revenuecat.com → Project Settings → API Keys → iOS
  static const String appleApiKey = 'YOUR_APPLE_API_KEY_HERE';

  /// Android Google Play API Key
  /// Get this from: https://app.revenuecat.com → Project Settings → API Keys → Android
  static const String googleApiKey = 'YOUR_GOOGLE_API_KEY_HERE';

  /// Entitlement identifier for premium access
  /// This should match the identifier you set up in RevenueCat dashboard
  /// Default: 'premium' (you can change this in RevenueCat dashboard)
  static const String premiumEntitlementId = 'Mood Diary Pro';

  /// Product identifiers for offerings
  /// These should match the product IDs from your premium_status.dart
  /// and must be configured in RevenueCat dashboard
  static const String monthlyProductId = 'mood_diary_premium_monthly';
  static const String yearlyProductId = 'mood_diary_premium_yearly';
  static const String lifetimeProductId = 'mood_diary_premium_lifetime';

  /// Check if API keys are configured
  static bool get isConfigured {
    return appleApiKey != 'YOUR_APPLE_API_KEY_HERE' &&
        googleApiKey != 'YOUR_GOOGLE_API_KEY_HERE';
  }

  /// Get the appropriate API key for the current platform
  static String getApiKey() {
    // This will be determined at runtime based on Platform.isIOS/isAndroid
    // We'll handle this in the service
    throw UnimplementedError(
      'Use RevenueCatService.initialize() to get platform-specific key',
    );
  }
}

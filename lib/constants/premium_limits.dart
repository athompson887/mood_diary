/// Premium feature constants and usage limits
library;

/// Premium features that can be gated
enum PremiumFeature {
  cloudSync,
  unlimitedEntries,
  lifetimeHistory,
  dataExport,
  advancedAnalytics,
  premiumThemes,
  appLock,
  customMoods,
  prioritySupport;

  String get displayName {
    switch (this) {
      case PremiumFeature.cloudSync:
        return 'Cloud Sync & Backup';
      case PremiumFeature.unlimitedEntries:
        return 'Unlimited Entries';
      case PremiumFeature.lifetimeHistory:
        return 'Lifetime History';
      case PremiumFeature.dataExport:
        return 'Data Export (PDF/CSV)';
      case PremiumFeature.advancedAnalytics:
        return 'Advanced Analytics';
      case PremiumFeature.premiumThemes:
        return 'Premium Themes';
      case PremiumFeature.appLock:
        return 'App Lock & Security';
      case PremiumFeature.customMoods:
        return 'Custom Mood Types';
      case PremiumFeature.prioritySupport:
        return 'Priority Support';
    }
  }

  String get description {
    switch (this) {
      case PremiumFeature.cloudSync:
        return 'Automatically sync your mood data across all devices';
      case PremiumFeature.unlimitedEntries:
        return 'Log as many mood entries as you need';
      case PremiumFeature.lifetimeHistory:
        return 'Access all your historical data, forever';
      case PremiumFeature.dataExport:
        return 'Export your data to share with therapists';
      case PremiumFeature.advancedAnalytics:
        return 'Detailed insights and mood pattern analysis';
      case PremiumFeature.premiumThemes:
        return 'Beautiful exclusive color themes';
      case PremiumFeature.appLock:
        return 'Protect your diary with password or biometrics';
      case PremiumFeature.customMoods:
        return 'Create your own custom mood types';
      case PremiumFeature.prioritySupport:
        return 'Get help within 24 hours';
    }
  }
}

/// Usage limits for free tier
class PremiumLimits {
  // Entry limits
  static const int freeMaxEntriesPerMonth = 30;
  static const int premiumMaxEntriesPerMonth = -1; // -1 = unlimited

  // History limits
  static const int freeHistoryDays = 7;
  static const int premiumHistoryDays = -1; // -1 = unlimited (lifetime)

  // Trial period
  static const int trialDurationDays = 7;

  /// Check if count exceeds entry limit for the month
  static bool exceedsEntryLimit(int monthCount, {required bool isPremium}) {
    if (isPremium) return false;
    return monthCount >= freeMaxEntriesPerMonth;
  }

  /// Check if date is within history limit
  static bool isWithinHistoryLimit(DateTime date, {required bool isPremium}) {
    if (isPremium) return true;
    final cutoff =
        DateTime.now().subtract(const Duration(days: freeHistoryDays));
    return date.isAfter(cutoff);
  }

  /// Get remaining entry slots for the month
  static int remainingEntrySlots(int currentCount, {required bool isPremium}) {
    if (isPremium) return -1; // unlimited
    return (freeMaxEntriesPerMonth - currentCount)
        .clamp(0, freeMaxEntriesPerMonth);
  }
}

/// Premium feature messages for upgrade prompts
class PremiumMessages {
  static const String cloudSyncTitle = 'Cloud Sync & Backup';
  static const String cloudSyncMessage =
      'Never lose your mood tracking data. Cloud sync keeps your diary safe across all your devices.';

  static const String entryLimitTitle = 'Entry Limit Reached';
  static const String entryLimitMessage =
      'You\'ve reached the limit of 30 entries this month. Upgrade to Premium for unlimited entries and never miss tracking your moods.';

  static const String historyLimitTitle = 'View Full History';
  static const String historyLimitMessage =
      'Want to see your mood journey from last month? Premium unlocks lifetime history and advanced insights.';

  static const String exportTitle = 'Export Your Data';
  static const String exportMessage =
      'Export your mood data to PDF or CSV. Share with therapists or keep personal records with Premium.';

  static const String analyticsTitle = 'Advanced Analytics';
  static const String analyticsMessage =
      'Unlock detailed insights about your mood patterns, triggers, and what helps you feel better.';

  static const String themesTitle = 'Premium Themes';
  static const String themesMessage =
      'Unlock beautiful exclusive themes like Ocean, Forest, Sunset, and Lavender.';

  static const String appLockTitle = 'App Lock & Security';
  static const String appLockMessage =
      'Keep your mood diary private with PIN code or biometric protection.';

  static const String customMoodsTitle = 'Custom Mood Types';
  static const String customMoodsMessage =
      'Create your own personalised mood types that match how you feel.';

  static const String prioritySupportTitle = 'Priority Support';
  static const String prioritySupportMessage =
      'Get help within 24 hours from our dedicated support team.';

  static const String genericTitle = 'Upgrade to Premium';
  static const String genericMessage =
      'Unlock all premium features including cloud sync, unlimited entries, advanced analytics, and more.';

  /// Get message for specific feature
  static (String title, String message) getMessageForFeature(
      PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.cloudSync:
        return (cloudSyncTitle, cloudSyncMessage);
      case PremiumFeature.unlimitedEntries:
        return (entryLimitTitle, entryLimitMessage);
      case PremiumFeature.lifetimeHistory:
        return (historyLimitTitle, historyLimitMessage);
      case PremiumFeature.dataExport:
        return (exportTitle, exportMessage);
      case PremiumFeature.advancedAnalytics:
        return (analyticsTitle, analyticsMessage);
      case PremiumFeature.premiumThemes:
        return (themesTitle, themesMessage);
      case PremiumFeature.appLock:
        return (appLockTitle, appLockMessage);
      case PremiumFeature.customMoods:
        return (customMoodsTitle, customMoodsMessage);
      case PremiumFeature.prioritySupport:
        return (prioritySupportTitle, prioritySupportMessage);
    }
  }
}

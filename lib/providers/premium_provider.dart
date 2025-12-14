import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_diary/models/premium_status.dart';
import 'package:mood_diary/constants/premium_limits.dart';
import 'package:mood_diary/constants/revenue_cat_config.dart';
import 'package:mood_diary/services/premium_service.dart';
import 'package:mood_diary/services/revenue_cat_service.dart';

// Re-export for convenience
export 'package:mood_diary/models/premium_status.dart';
export 'package:mood_diary/constants/premium_limits.dart';

/// RevenueCat service provider
/// Only created if RevenueCat is configured
final revenueCatServiceProvider = Provider<RevenueCatService?>((ref) {
  if (!RevenueCatConfig.isConfigured) {
    return null; // Mock mode
  }
  return RevenueCatService();
});

/// Premium service provider
/// Automatically uses RevenueCat if configured, otherwise uses mock mode
final premiumServiceProvider = Provider<PremiumService>((ref) {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return PremiumService(revenueCatService: revenueCatService);
});

/// Current premium status provider
final premiumStatusProvider = StreamProvider<PremiumStatus>((ref) {
  final service = ref.watch(premiumServiceProvider);
  return service.premiumStatusStream();
});

/// Simple boolean check for premium access
final isPremiumProvider = Provider<bool>((ref) {
  final status = ref.watch(premiumStatusProvider);
  return status.maybeWhen(
    data: (status) => status.isActive,
    orElse: () => false,
  );
});

/// Check if user is in trial period
final isTrialProvider = Provider<bool>((ref) {
  final status = ref.watch(premiumStatusProvider);
  return status.maybeWhen(
    data: (status) => status.isTrialPeriod && status.isActive,
    orElse: () => false,
  );
});

/// Get days remaining in trial
final trialDaysRemainingProvider = Provider<int?>((ref) {
  final status = ref.watch(premiumStatusProvider);
  return status.maybeWhen(
    data: (status) => status.trialDaysRemaining,
    orElse: () => null,
  );
});

/// Check if user can access a specific premium feature
final canAccessFeatureProvider =
    Provider.family<bool, PremiumFeature>((ref, feature) {
  final isPremium = ref.watch(isPremiumProvider);

  // All features require premium
  return isPremium;
});

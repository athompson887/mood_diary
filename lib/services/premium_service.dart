import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_diary/constants/revenue_cat_config.dart';
import 'package:mood_diary/models/premium_status.dart';
import 'package:mood_diary/services/revenue_cat_service.dart';

/// Premium service - manages subscription status
///
/// This service has two modes:
/// 1. Mock Mode (RevenueCat not configured): Uses local storage for testing
/// 2. Production Mode (RevenueCat configured): Uses RevenueCat for real purchases
///
/// The mode is automatically determined based on RevenueCatConfig.isConfigured
class PremiumService {
  static const String _boxName = 'settings';
  static const String _premiumStatusKey = 'premium_status';

  /// RevenueCat service (null if in mock mode)
  final RevenueCatService? _revenueCatService;

  /// Constructor
  PremiumService({RevenueCatService? revenueCatService})
      : _revenueCatService = revenueCatService;

  /// Check if running in production mode (RevenueCat)
  bool get isProductionMode =>
      RevenueCatConfig.isConfigured && _revenueCatService != null;

  /// Get current premium status
  ///
  /// In production mode: Fetches from RevenueCat
  /// In mock mode: Fetches from local storage
  Future<PremiumStatus> getPremiumStatus() async {
    final service = _revenueCatService;
    if (isProductionMode && service != null) {
      try {
        // Try to initialize if not already done
        if (!service.isInitialized) {
          await service.initialize();
        }
        return await service.getPremiumStatus();
      } catch (e) {
        // If RevenueCat fails, fall back to mock mode
        // This can happen if products aren't set up yet
        return await _getMockStatus();
      }
    }

    return await _getMockStatus();
  }

  /// Get status from local storage (mock mode)
  Future<PremiumStatus> _getMockStatus() async {
    final box = Hive.box(_boxName);
    final saved = box.get(_premiumStatusKey);

    if (saved != null && saved is Map) {
      try {
        return PremiumStatus.fromJson(Map<String, dynamic>.from(saved));
      } catch (e) {
        // If parsing fails, return free tier
        return const PremiumStatus.free();
      }
    }

    return const PremiumStatus.free();
  }

  /// Save premium status to local storage
  Future<void> savePremiumStatus(PremiumStatus status) async {
    final box = Hive.box(_boxName);
    await box.put(_premiumStatusKey, status.toJson());
  }

  /// Stream of premium status changes
  ///
  /// In production mode: Streams from RevenueCat
  /// In mock mode: Streams from Hive changes
  Stream<PremiumStatus> premiumStatusStream() async* {
    final service = _revenueCatService;
    if (isProductionMode && service != null) {
      try {
        // Try to initialize if not already done
        if (!service.isInitialized) {
          await service.initialize();
        }
        yield* service.premiumStatusStream();
        return;
      } catch (e) {
        // If RevenueCat fails, fall back to mock mode stream
        // Continue to mock mode below
      }
    }

    // Mock mode: Use Hive
    // Initial value
    yield await _getMockStatus();

    // Watch for changes in Hive box
    final box = Hive.box(_boxName);
    await for (final _ in box.watch(key: _premiumStatusKey)) {
      yield await _getMockStatus();
    }
  }

  /// Start a premium trial
  Future<void> startTrial() async {
    final trialEnd = DateTime.now().add(
      const Duration(days: 7), // 7-day trial
    );

    final status = PremiumStatus.trial(
      trialEnd: trialEnd,
      subscriptionId: 'trial_${DateTime.now().millisecondsSinceEpoch}',
    );

    await savePremiumStatus(status);
  }

  /// Activate premium subscription
  Future<void> activatePremium({
    required SubscriptionPlan plan,
    required String subscriptionId,
  }) async {
    final now = DateTime.now();

    PremiumStatus status;

    if (plan == SubscriptionPlan.lifetime) {
      status = PremiumStatus.lifetime(
        purchaseDate: now,
        subscriptionId: subscriptionId,
      );
    } else {
      // Calculate subscription end date
      DateTime? endDate;
      if (plan == SubscriptionPlan.monthly) {
        endDate = DateTime(now.year, now.month + 1, now.day);
      } else if (plan == SubscriptionPlan.yearly) {
        endDate = DateTime(now.year + 1, now.month, now.day);
      }

      status = PremiumStatus.premium(
        subscriptionStart: now,
        subscriptionEnd: endDate,
        subscriptionId: subscriptionId,
      );
    }

    await savePremiumStatus(status);
  }

  /// Cancel premium subscription (reverts to free)
  Future<void> cancelPremium() async {
    await savePremiumStatus(const PremiumStatus.free());
  }

  /// Restore purchases from platform
  ///
  /// In production mode: Calls RevenueCat restorePurchases
  /// In mock mode: No-op (returns current status)
  Future<void> restorePurchases() async {
    final service = _revenueCatService;
    if (isProductionMode && service != null) {
      try {
        // Try to initialize if not already done
        if (!service.isInitialized) {
          await service.initialize();
        }
        await service.restorePurchases();
      } catch (e) {
        // If RevenueCat fails, silently fall back
        // User will see no active subscription message
      }
    }
    // In mock mode, purchases are stored locally, nothing to restore
  }

  /// Check if trial is available for user
  Future<bool> isTrialAvailable() async {
    // Check if user has ever used a trial
    // For now, allow trial once
    final status = await getPremiumStatus();

    // Trial available if user is currently free and hasn't had premium before
    return status.tier == PremiumTier.free && status.subscriptionStart == null;
  }

  // ============================================================================
  // DEBUG METHODS (for testing, remove in production)
  // ============================================================================

  /// FOR TESTING: Grant premium access
  Future<void> debugGrantPremium() async {
    await activatePremium(
      plan: SubscriptionPlan.yearly,
      subscriptionId: 'debug_premium',
    );
  }

  /// FOR TESTING: Grant trial access
  Future<void> debugGrantTrial() async {
    await startTrial();
  }

  /// FOR TESTING: Revoke premium access
  Future<void> debugRevokePremium() async {
    await cancelPremium();
  }
}

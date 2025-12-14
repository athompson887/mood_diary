import 'dart:async';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mood_diary/constants/revenue_cat_config.dart';
import 'package:mood_diary/models/premium_status.dart';

/// RevenueCat Service
///
/// Handles all subscription and purchase logic through RevenueCat.
/// This is designed to be:
/// - Testable with dependency injection
/// - Easy to mock for tests
/// - Reusable across multiple apps
///
/// USAGE:
/// ```dart
/// final service = RevenueCatService();
/// await service.initialize();
/// final status = await service.getPremiumStatus();
/// ```
class RevenueCatService {
  /// Stream controller for subscription status changes
  final _statusController = StreamController<PremiumStatus>.broadcast();

  /// Cached current status to avoid redundant API calls
  PremiumStatus? _cachedStatus;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Public getter for initialization status
  bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat SDK
  ///
  /// This must be called before any other methods.
  /// Typically called in main() or app initialization.
  ///
  /// Throws [StateError] if API keys are not configured.
  Future<void> initialize({String? appUserId}) async {
    if (_isInitialized) {
      return; // Already initialized
    }

    if (!RevenueCatConfig.isConfigured) {
      throw StateError(
        'RevenueCat API keys not configured. '
        'Please update lib/constants/revenue_cat_config.dart',
      );
    }

    // Get platform-specific API key
    final apiKey = Platform.isIOS
        ? RevenueCatConfig.appleApiKey
        : RevenueCatConfig.googleApiKey;

    // Configure RevenueCat
    final configuration = PurchasesConfiguration(apiKey);

    if (appUserId != null) {
      configuration.appUserID = appUserId;
    }

    await Purchases.configure(configuration);

    // Listen for customer info updates
    Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

    _isInitialized = true;

    // Load initial status
    await _refreshStatus();
  }

  /// Handle customer info updates from RevenueCat
  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    final status = _parseCustomerInfo(customerInfo);
    _cachedStatus = status;
    _statusController.add(status);
  }

  /// Get current premium status
  Future<PremiumStatus> getPremiumStatus() async {
    _ensureInitialized();

    // Return cached status if available
    if (_cachedStatus != null) {
      return _cachedStatus!;
    }

    // Otherwise fetch fresh status
    return await _refreshStatus();
  }

  /// Refresh premium status from RevenueCat
  Future<PremiumStatus> _refreshStatus() async {
    _ensureInitialized();

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final status = _parseCustomerInfo(customerInfo);
      _cachedStatus = status;
      _statusController.add(status);
      return status;
    } catch (e) {
      // If we can't get status, return free tier
      const status = PremiumStatus.free();
      _cachedStatus = status;
      return status;
    }
  }

  /// Parse CustomerInfo into PremiumStatus
  PremiumStatus _parseCustomerInfo(CustomerInfo customerInfo) {
    // Check if user has premium entitlement
    final hasPremium = customerInfo.entitlements.active
        .containsKey(RevenueCatConfig.premiumEntitlementId);

    if (!hasPremium) {
      return const PremiumStatus.free();
    }

    final entitlement =
        customerInfo.entitlements.active[RevenueCatConfig.premiumEntitlementId]!;

    // Determine if it's a lifetime purchase
    final isLifetime =
        entitlement.productIdentifier == RevenueCatConfig.lifetimeProductId;

    if (isLifetime) {
      return PremiumStatus.lifetime(
        purchaseDate: DateTime.parse(entitlement.originalPurchaseDate),
        subscriptionId: entitlement.productIdentifier,
      );
    }

    // Check if it's in trial period
    final isInTrial = entitlement.periodType == PeriodType.trial;

    if (isInTrial && entitlement.expirationDate != null) {
      return PremiumStatus.trial(
        trialEnd: DateTime.parse(entitlement.expirationDate!),
        subscriptionId: entitlement.productIdentifier,
      );
    }

    // Regular premium subscription
    return PremiumStatus.premium(
      subscriptionStart: DateTime.parse(entitlement.originalPurchaseDate),
      subscriptionEnd: entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : null,
      subscriptionId: entitlement.productIdentifier,
    );
  }

  /// Stream of premium status changes
  Stream<PremiumStatus> premiumStatusStream() async* {
    _ensureInitialized();

    // Emit current status first
    final current = await getPremiumStatus();
    yield current;

    // Then emit updates
    yield* _statusController.stream;
  }

  /// Get available subscription offerings
  ///
  /// Returns packages configured in RevenueCat dashboard.
  /// Typically contains monthly, yearly, and lifetime options.
  Future<List<Package>> getOfferings() async {
    _ensureInitialized();

    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        return [];
      }

      return offerings.current!.availablePackages;
    } catch (e) {
      return [];
    }
  }

  /// Purchase a package
  ///
  /// Returns the updated PremiumStatus after purchase.
  /// Throws [PlatformException] if purchase fails or is cancelled.
  Future<PremiumStatus> purchasePackage(Package package) async {
    _ensureInitialized();

    final purchaseResult = await Purchases.purchasePackage(package);
    return _parseCustomerInfo(purchaseResult);
  }

  /// Purchase a specific product by ID
  ///
  /// This is an alternative to purchasePackage when you know the exact product ID.
  Future<PremiumStatus> purchaseStoreProduct(StoreProduct product) async {
    _ensureInitialized();

    final purchaseResult = await Purchases.purchaseStoreProduct(product);
    return _parseCustomerInfo(purchaseResult);
  }

  /// Restore previous purchases
  ///
  /// Call this when user taps "Restore Purchases" button.
  /// Returns the updated PremiumStatus.
  Future<PremiumStatus> restorePurchases() async {
    _ensureInitialized();

    final customerInfo = await Purchases.restorePurchases();
    return _parseCustomerInfo(customerInfo);
  }

  /// Check if user is eligible for introductory offer (trial)
  ///
  /// Returns map of product IDs to eligibility status.
  Future<Map<String, IntroEligibility>> checkEligibility(
    List<String> productIds,
  ) async {
    _ensureInitialized();

    return await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);
  }

  /// Set user ID for cross-device subscription tracking
  ///
  /// Call this after user logs in to sync their purchases across devices.
  Future<void> logIn(String appUserId) async {
    _ensureInitialized();

    await Purchases.logIn(appUserId);
    await _refreshStatus();
  }

  /// Log out current user
  ///
  /// Call this when user logs out.
  Future<void> logOut() async {
    _ensureInitialized();

    await Purchases.logOut();
    await _refreshStatus();
  }

  /// Get user ID currently used by RevenueCat
  Future<String> getAppUserId() async {
    _ensureInitialized();

    return await Purchases.appUserID;
  }

  /// Ensure the service is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'RevenueCatService not initialized. Call initialize() first.',
      );
    }
  }

  /// Dispose of resources
  ///
  /// Call this when the service is no longer needed (typically never in production)
  void dispose() {
    _statusController.close();
    _cachedStatus = null;
    _isInitialized = false;
  }
}

/// Extension methods for Package to make it easier to work with
extension PackageExtension on Package {
  /// Get the subscription plan type from package identifier
  SubscriptionPlan? get subscriptionPlan {
    if (identifier.contains('monthly')) {
      return SubscriptionPlan.monthly;
    } else if (identifier.contains('annual') || identifier.contains('yearly')) {
      return SubscriptionPlan.yearly;
    } else if (identifier.contains('lifetime')) {
      return SubscriptionPlan.lifetime;
    }
    return null;
  }

  /// Get user-friendly price string
  String get priceString => storeProduct.priceString;

  /// Get localized subscription duration
  String get durationString {
    final plan = subscriptionPlan;
    if (plan == null) return '';

    switch (plan) {
      case SubscriptionPlan.monthly:
        return '/month';
      case SubscriptionPlan.yearly:
        return '/year';
      case SubscriptionPlan.lifetime:
        return 'one-time';
    }
  }
}

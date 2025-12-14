/// Premium tier levels
enum PremiumTier {
  free,
  premium,
  lifetime;

  bool get isPremium => this == PremiumTier.premium || this == PremiumTier.lifetime;
  bool get isLifetime => this == PremiumTier.lifetime;

  String get displayName {
    switch (this) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.premium:
        return 'Premium';
      case PremiumTier.lifetime:
        return 'Lifetime';
    }
  }
}

/// Premium subscription status
class PremiumStatus {
  final PremiumTier tier;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final bool isTrialPeriod;
  final DateTime? trialEnd;
  final String? subscriptionId;

  const PremiumStatus({
    required this.tier,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.isTrialPeriod = false,
    this.trialEnd,
    this.subscriptionId,
  });

  /// Free tier constructor
  const PremiumStatus.free()
      : tier = PremiumTier.free,
        subscriptionStart = null,
        subscriptionEnd = null,
        isTrialPeriod = false,
        trialEnd = null,
        subscriptionId = null;

  /// Premium tier constructor
  PremiumStatus.premium({
    required DateTime this.subscriptionStart,
    this.subscriptionEnd,
    this.subscriptionId,
  })  : tier = PremiumTier.premium,
        isTrialPeriod = false,
        trialEnd = null;

  /// Trial period constructor
  PremiumStatus.trial({
    required DateTime this.trialEnd,
    this.subscriptionId,
  })  : tier = PremiumTier.premium,
        subscriptionStart = DateTime.now(),
        subscriptionEnd = null,
        isTrialPeriod = true;

  /// Lifetime tier constructor
  PremiumStatus.lifetime({
    required DateTime purchaseDate,
    this.subscriptionId,
  })  : tier = PremiumTier.lifetime,
        subscriptionStart = purchaseDate,
        subscriptionEnd = null,
        isTrialPeriod = false,
        trialEnd = null;

  /// Check if user has premium access (paid or trial)
  bool get isPremium => tier.isPremium;

  /// Check if premium is active (not expired)
  bool get isActive {
    if (tier == PremiumTier.free) return false;
    if (tier == PremiumTier.lifetime) return true;

    final now = DateTime.now();

    // Check trial expiration
    if (isTrialPeriod && trialEnd != null) {
      return now.isBefore(trialEnd!);
    }

    // Check subscription expiration
    if (subscriptionEnd != null) {
      return now.isBefore(subscriptionEnd!);
    }

    // No expiration date means active
    return true;
  }

  /// Days remaining in trial period
  int? get trialDaysRemaining {
    if (!isTrialPeriod || trialEnd == null) return null;
    final diff = trialEnd!.difference(DateTime.now());
    // Add 1 to include the current day in the count
    return (diff.inDays + 1).clamp(0, 999);
  }

  /// Check if trial has expired
  bool get isTrialExpired {
    if (!isTrialPeriod || trialEnd == null) return false;
    return DateTime.now().isAfter(trialEnd!);
  }

  PremiumStatus copyWith({
    PremiumTier? tier,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    bool? isTrialPeriod,
    DateTime? trialEnd,
    String? subscriptionId,
  }) {
    return PremiumStatus(
      tier: tier ?? this.tier,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
      trialEnd: trialEnd ?? this.trialEnd,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'subscriptionStart': subscriptionStart?.toIso8601String(),
        'subscriptionEnd': subscriptionEnd?.toIso8601String(),
        'isTrialPeriod': isTrialPeriod,
        'trialEnd': trialEnd?.toIso8601String(),
        'subscriptionId': subscriptionId,
      };

  factory PremiumStatus.fromJson(Map<String, dynamic> json) {
    return PremiumStatus(
      tier: PremiumTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => PremiumTier.free,
      ),
      subscriptionStart: json['subscriptionStart'] != null
          ? DateTime.parse(json['subscriptionStart'])
          : null,
      subscriptionEnd: json['subscriptionEnd'] != null
          ? DateTime.parse(json['subscriptionEnd'])
          : null,
      isTrialPeriod: json['isTrialPeriod'] ?? false,
      trialEnd:
          json['trialEnd'] != null ? DateTime.parse(json['trialEnd']) : null,
      subscriptionId: json['subscriptionId'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumStatus &&
          runtimeType == other.runtimeType &&
          tier == other.tier &&
          subscriptionStart == other.subscriptionStart &&
          subscriptionEnd == other.subscriptionEnd &&
          isTrialPeriod == other.isTrialPeriod &&
          trialEnd == other.trialEnd &&
          subscriptionId == other.subscriptionId;

  @override
  int get hashCode => Object.hash(
        tier,
        subscriptionStart,
        subscriptionEnd,
        isTrialPeriod,
        trialEnd,
        subscriptionId,
      );
}

/// Subscription plan options
enum SubscriptionPlan {
  monthly,
  yearly,
  lifetime;

  String get displayName {
    switch (this) {
      case SubscriptionPlan.monthly:
        return 'Monthly';
      case SubscriptionPlan.yearly:
        return 'Yearly';
      case SubscriptionPlan.lifetime:
        return 'Lifetime';
    }
  }

  String get price {
    switch (this) {
      case SubscriptionPlan.monthly:
        return '£2.99/month';
      case SubscriptionPlan.yearly:
        return '£19.99/year';
      case SubscriptionPlan.lifetime:
        return '£49.99';
    }
  }

  String get priceValue {
    switch (this) {
      case SubscriptionPlan.monthly:
        return '2.99';
      case SubscriptionPlan.yearly:
        return '19.99';
      case SubscriptionPlan.lifetime:
        return '49.99';
    }
  }

  String get savings {
    switch (this) {
      case SubscriptionPlan.monthly:
        return '';
      case SubscriptionPlan.yearly:
        return 'Save 44%';
      case SubscriptionPlan.lifetime:
        return 'Best Value';
    }
  }

  String get perMonth {
    switch (this) {
      case SubscriptionPlan.monthly:
        return '£2.99/mo';
      case SubscriptionPlan.yearly:
        return '£1.67/mo';
      case SubscriptionPlan.lifetime:
        return 'One-time';
    }
  }

  bool get hasTrial {
    return this == SubscriptionPlan.yearly;
  }

  String get description {
    switch (this) {
      case SubscriptionPlan.monthly:
        return 'Perfect for trying out Premium';
      case SubscriptionPlan.yearly:
        return '7-day free trial, then £19.99/year';
      case SubscriptionPlan.lifetime:
        return 'Pay once, own forever';
    }
  }

  String get productId {
    switch (this) {
      case SubscriptionPlan.monthly:
        return 'mood_diary_premium_monthly';
      case SubscriptionPlan.yearly:
        return 'mood_diary_premium_yearly';
      case SubscriptionPlan.lifetime:
        return 'mood_diary_premium_lifetime';
    }
  }
}

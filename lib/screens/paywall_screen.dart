import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mood_diary/providers/premium_provider.dart';
import 'package:mood_diary/services/revenue_cat_service.dart';

/// Beautiful paywall screen to showcase premium features
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({
    super.key,
    this.highlightFeature,
  });

  final PremiumFeature? highlightFeature;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;
  List<Package>? _packages;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final revenueCatService = ref.read(revenueCatServiceProvider);

      // If RevenueCat is not configured, use mock mode
      if (revenueCatService == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final packages = await revenueCatService.getOfferings();

      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer,
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            // Premium badge and title
                            _buildHeader(theme),
                            const SizedBox(height: 32),

                            // Feature list
                            _buildFeaturesList(theme),
                            const SizedBox(height: 32),

                            // Plan selection
                            _buildPlanSelection(theme),
                            const SizedBox(height: 24),

                            // CTA Button
                            _buildCTAButton(theme),
                            const SizedBox(height: 16),

                            // Restore purchases
                            _buildRestorePurchases(theme),
                            const SizedBox(height: 16),

                            // Terms
                            _buildTerms(theme),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Premium star icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.shade100,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withAlpha(75),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.star,
            size: 48,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock Premium',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get unlimited access to all features',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList(ThemeData theme) {
    final features = [
      (
        icon: Icons.all_inclusive,
        color: Colors.purple,
        title: 'Unlimited Entries',
        description: 'Log as many mood entries as you need, every day',
        isPrimary: true,
      ),
      (
        icon: Icons.cloud_sync,
        color: Colors.blue,
        title: 'Cloud Sync & Backup',
        description: 'Sync across devices, never lose your data',
        isPrimary: false,
      ),
      (
        icon: Icons.history,
        color: Colors.orange,
        title: 'Lifetime History',
        description: 'Access your complete mood journey forever',
        isPrimary: false,
      ),
      (
        icon: Icons.insights,
        color: Colors.green,
        title: 'Advanced Analytics',
        description: 'Discover patterns and triggers in your moods',
        isPrimary: false,
      ),
      (
        icon: Icons.download,
        color: Colors.red,
        title: 'Data Export',
        description: 'Export to PDF/CSV to share with therapists',
        isPrimary: false,
      ),
      (
        icon: Icons.palette,
        color: Colors.pink,
        title: 'Premium Themes',
        description: '7 beautiful exclusive colour themes',
        isPrimary: false,
      ),
      (
        icon: Icons.lock_outline,
        color: Colors.indigo,
        title: 'App Lock',
        description: 'Protect your diary with PIN or biometrics',
        isPrimary: false,
      ),
      (
        icon: Icons.add_reaction_outlined,
        color: Colors.teal,
        title: 'Custom Moods',
        description: 'Create your own personalised mood types',
        isPrimary: false,
      ),
      (
        icon: Icons.support_agent,
        color: Colors.amber,
        title: 'Priority Support',
        description: 'Get help within 24 hours when you need it',
        isPrimary: false,
      ),
    ];

    return Column(
      children: features.map((feature) {
        final isHighlighted = widget.highlightFeature != null &&
            feature.title.contains(widget.highlightFeature!.displayName);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isHighlighted
                  ? feature.color.withAlpha(25)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isHighlighted
                  ? Border.all(color: feature.color, width: 2)
                  : null,
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: feature.color.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature.icon,
                  color: feature.color,
                  size: 24,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      feature.title,
                      style: TextStyle(
                        fontWeight:
                            feature.isPrimary ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (feature.isPrimary) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TOP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(feature.description),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanSelection(ThemeData theme) {
    // Use real packages if available, otherwise use mock plans
    if (_packages != null && _packages!.isNotEmpty) {
      return _buildRealPlanSelection(theme);
    }
    return _buildMockPlanSelection(theme);
  }

  Widget _buildRealPlanSelection(ThemeData theme) {
    // Find selected package index
    int selectedIndex = _packages!.indexWhere(
      (pkg) => pkg.subscriptionPlan == _selectedPlan,
    );
    if (selectedIndex == -1) selectedIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._packages!.asMap().entries.map((entry) {
          final index = entry.key;
          final package = entry.value;
          final isSelected = index == selectedIndex;
          final plan = package.subscriptionPlan;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () =>
                  setState(() => _selectedPlan = plan ?? SubscriptionPlan.monthly),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  package.storeProduct.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (plan == SubscriptionPlan.yearly) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'SAVE 44%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            package.storeProduct.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      package.storeProduct.priceString,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMockPlanSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...SubscriptionPlan.values.map((plan) {
          final isSelected = _selectedPlan == plan;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedPlan = plan),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (plan.savings.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    plan.savings,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      plan.price,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCTAButton(ThemeData theme) {
    final isYearly = _selectedPlan == SubscriptionPlan.yearly;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: () => _handlePurchase(),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        child: Text(
          isYearly ? 'Start 7-Day Free Trial' : 'Subscribe Now',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRestorePurchases(ThemeData theme) {
    return TextButton(
      onPressed: () => _handleRestorePurchases(),
      child: const Text('Restore Purchases'),
    );
  }

  Widget _buildTerms(ThemeData theme) {
    return Text(
      'Payment will be charged to your account at confirmation. '
      'Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. '
      'You can manage and cancel your subscription in your account settings.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handlePurchase() async {
    final revenueCatService = ref.read(revenueCatServiceProvider);

    // If no RevenueCat or no packages, use mock mode
    if (revenueCatService == null || _packages == null || _packages!.isEmpty) {
      await _handleMockPurchase();
      return;
    }

    // Find the selected package
    final selectedPackage = _packages!.firstWhere(
      (pkg) => pkg.subscriptionPlan == _selectedPlan,
      orElse: () => _packages!.first,
    );

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Make the actual purchase through RevenueCat
      final status = await revenueCatService.purchasePackage(selectedPackage);

      // Close loading
      if (!mounted) return;
      Navigator.pop(context);

      // Check if purchase was successful
      if (status.isPremium) {
        // Close paywall
        Navigator.pop(context, true);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status.isTrialPeriod
                        ? 'Welcome! Your free trial has started.'
                        : 'Welcome to Premium!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Purchase didn't grant premium - likely cancelled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Purchase cancelled'),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (!mounted) return;
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Fallback for mock mode
  Future<void> _handleMockPurchase() async {
    final premiumService = ref.read(premiumServiceProvider);

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate purchase delay
    await Future.delayed(const Duration(seconds: 1));

    // Grant premium based on plan
    if (_selectedPlan.hasTrial) {
      await premiumService.startTrial();
    } else {
      await premiumService.activatePremium(
        plan: _selectedPlan,
        subscriptionId: 'mock_purchase_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    // Close loading and paywall
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog
    Navigator.pop(context, true); // Close paywall with success

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedPlan.hasTrial
                    ? 'Welcome! Your free trial has started.'
                    : 'Welcome to Premium!',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleRestorePurchases() async {
    final premiumService = ref.read(premiumServiceProvider);

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await premiumService.restorePurchases();

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      // Check if premium was restored
      final status = await premiumService.getPremiumStatus();

      if (!mounted) return;
      if (status.isPremium) {
        Navigator.pop(context, true); // Close paywall
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No previous purchases found'),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error restoring purchases: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

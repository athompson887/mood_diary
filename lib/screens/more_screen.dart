import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';
import '../providers/debug_mode_provider.dart';
import '../providers/premium_provider.dart';
import '../constants/feature_flags.dart';
import '../widgets/premium_badge.dart';
import 'settings_screen.dart';
import 'debug_data_screen.dart';
import 'paywall_screen.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  void _handleVersionTap() {
    final debugNotifier = ref.read(debugModeProvider.notifier);
    final remaining = debugNotifier.handleTap();
    final l10n = AppLocalizations.of(context)!;

    if (remaining == -1) {
      final isEnabled = ref.read(debugModeProvider).isEnabled;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isEnabled ? Icons.bug_report : Icons.bug_report_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(isEnabled ? l10n.debugModeEnabled : l10n.debugModeDisabled),
            ],
          ),
          backgroundColor: isEnabled ? Colors.orange : Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (remaining <= 3 && remaining > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tapMoreToEnable(remaining)),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final debugMode = ref.watch(debugModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.more),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // Subscription Section
          _buildSubscriptionCard(context),

          // Settings Section
          _buildSectionHeader(context, l10n.settings),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: _buildIconContainer(
                context,
                Icons.settings,
                theme.colorScheme.primary,
              ),
              title: Text(l10n.settings),
              subtitle: Text(l10n.accessibilityDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Feedback Section
          _buildSectionHeader(context, 'Feedback'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: _buildIconContainer(
                    context,
                    Icons.rate_review,
                    theme.colorScheme.primary,
                  ),
                  title: const Text('Send Feedback'),
                  subtitle: const Text('Share your thoughts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFeedbackDialog(context, 'feedback'),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: _buildIconContainer(
                    context,
                    Icons.bug_report,
                    Colors.red,
                  ),
                  title: const Text('Report a Bug'),
                  subtitle: const Text('Help us improve'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFeedbackDialog(context, 'bug'),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: _buildIconContainer(
                    context,
                    Icons.lightbulb_outline,
                    Colors.orange,
                  ),
                  title: const Text('Feature Request'),
                  subtitle: const Text('Suggest new features'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFeedbackDialog(context, 'feature'),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: _buildIconContainer(
                    context,
                    Icons.star,
                    Colors.amber,
                  ),
                  title: Text(l10n.rateApp),
                  subtitle: const Text('Rate us on the store'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRatingDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Self-Help Techniques Section
          _buildSectionHeader(context, 'Managing Your Moods'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildTechniqueItem(
                  context: context,
                  icon: Icons.air,
                  title: 'Deep Breathing',
                  description: 'Calm your mind with breathing exercises',
                  onTap: () => _showTechniqueDetail(
                    context,
                    'Deep Breathing',
                    _getDeepBreathingContent(),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                _buildTechniqueItem(
                  context: context,
                  icon: Icons.local_cafe,
                  title: 'Grounding (5-4-3-2-1)',
                  description: 'Reconnect with the present moment',
                  onTap: () => _showTechniqueDetail(
                    context,
                    'Grounding Technique',
                    _getGroundingContent(),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                _buildTechniqueItem(
                  context: context,
                  icon: Icons.lightbulb_outline,
                  title: 'Cognitive Reframing',
                  description: 'Challenge unhelpful thought patterns',
                  onTap: () => _showTechniqueDetail(
                    context,
                    'Cognitive Reframing',
                    _getCognitiveReframingContent(),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                _buildTechniqueItem(
                  context: context,
                  icon: Icons.spa,
                  title: 'Mindfulness',
                  description: 'Be present without judgement',
                  onTap: () => _showTechniqueDetail(
                    context,
                    'Mindfulness',
                    _getMindfulnessContent(),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                _buildTechniqueItem(
                  context: context,
                  icon: Icons.directions_walk,
                  title: 'Physical Activity',
                  description: 'Move your body to lift your mood',
                  onTap: () => _showTechniqueDetail(
                    context,
                    'Physical Activity',
                    _getPhysicalActivityContent(),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                _buildTechniqueItem(
                  context: context,
                  icon: Icons.favorite_outline,
                  title: 'Self-Compassion',
                  description: 'Treat yourself with kindness',
                  onTap: () => _showTechniqueDetail(
                    context,
                    'Self-Compassion',
                    _getSelfCompassionContent(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, l10n.about),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: _buildIconContainer(
                    context,
                    Icons.privacy_tip_outlined,
                    theme.colorScheme.secondary,
                  ),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: _buildIconContainer(
                    context,
                    Icons.description_outlined,
                    theme.colorScheme.secondary,
                  ),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTermsOfService(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Debug Section (only in debug mode or when feature flag enabled)
          if ((kDebugMode || debugMode.isEnabled) &&
              FeatureFlags.showDebugPanel) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'DEVELOPER',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.orange.shade50,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.developer_mode,
                        color: Colors.orange,
                      ),
                    ),
                    title: const Text(
                      'Dev Mode',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Generate test data & debug tools'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DebugDataScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 72),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bug_report,
                        color: Colors.orange,
                      ),
                    ),
                    title: Text(l10n.debugMode),
                    subtitle: const Text('Keep debug mode enabled'),
                    value: debugMode.isEnabled,
                    onChanged: (value) {
                      ref.read(debugModeProvider.notifier).setDebugMode(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Version Footer
          GestureDetector(
            onTap: _handleVersionTap,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.mood,
                    size: 48,
                    color: theme.colorScheme.primary.withAlpha(100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.version} $_version ($_buildNumber)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© ${DateTime.now().year} Mood Diary',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildIconContainer(
    BuildContext context,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    final premiumStatus = ref.watch(premiumStatusProvider);

    return premiumStatus.when(
      data: (status) {
        if (status.isActive) {
          // Premium user card
          return _buildPremiumActiveCard(context, status);
        } else {
          // Free user - show upgrade card
          return _buildUpgradeCard(context);
        }
      },
      loading: () => const SizedBox(height: 16),
      error: (_, _) => _buildUpgradeCard(context),
    );
  }

  Widget _buildUpgradeCard(BuildContext context) {

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade300,
            Colors.amber.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withAlpha(75),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPaywall(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(75),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlimited entries, advanced analytics & more',
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActiveCard(BuildContext context, PremiumStatus status) {
    final theme = Theme.of(context);

    String statusText;
    String subtitleText;
    Color cardColor;

    if (status.tier == PremiumTier.lifetime) {
      statusText = 'Lifetime Premium';
      subtitleText = 'You have lifetime access to all features';
      cardColor = Colors.purple;
    } else if (status.isTrialPeriod) {
      final daysLeft = status.trialDaysRemaining ?? 0;
      statusText = 'Trial Active';
      subtitleText = '$daysLeft day${daysLeft == 1 ? '' : 's'} remaining';
      cardColor = Colors.blue;
    } else {
      statusText = 'Premium Active';
      subtitleText = 'You have access to all features';
      cardColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withAlpha(75)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSubscriptionDetails(context, status),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cardColor.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: cardColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            statusText,
                            style: TextStyle(
                              color: cardColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const PremiumBadge(size: PremiumBadgeSize.tiny),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: cardColor,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSubscriptionDetails(BuildContext context, PremiumStatus status) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(75),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          status.tier.displayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                'Status',
                status.isActive ? 'Active' : 'Expired',
                status.isActive ? Colors.green : Colors.red,
              ),
              if (status.isTrialPeriod && status.trialEnd != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  'Trial Ends',
                  _formatDate(status.trialEnd!),
                  null,
                ),
              ],
              if (status.subscriptionStart != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  'Started',
                  _formatDate(status.subscriptionStart!),
                  null,
                ),
              ],
              if (status.subscriptionEnd != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  'Renews',
                  _formatDate(status.subscriptionEnd!),
                  null,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Manage your subscription in your device\'s app store settings.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTechniqueItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onPrimaryContainer,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showTechniqueDetail(
    BuildContext context,
    String title,
    Widget content,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ),
      ),
    );
  }

  // === Technique Content ===

  Widget _getDeepBreathingContent() {
    return const _TechniqueContent(
      sections: [
        _ContentSection(
          title: 'What is it?',
          content:
              'Deep breathing activates your parasympathetic nervous system, which helps calm your body\'s stress response. When you\'re feeling overwhelmed, anxious, or upset, your breathing often becomes shallow and rapid. Consciously slowing and deepening your breath can help restore a sense of calm.',
        ),
        _ContentSection(
          title: 'The 4-7-8 Technique',
          content: '''1. Breathe in through your nose for 4 seconds
2. Hold your breath for 7 seconds
3. Exhale slowly through your mouth for 8 seconds
4. Repeat 3-4 times''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Box Breathing',
          content: '''1. Breathe in for 4 seconds
2. Hold for 4 seconds
3. Breathe out for 4 seconds
4. Hold for 4 seconds
5. Repeat until calm''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'When to Use',
          content: '''• When feeling anxious or overwhelmed
• Before a stressful situation
• When you notice tension building
• During moments of anger or frustration
• Before sleep to help relax''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Remember',
          content:
              'It\'s normal for your mind to wander during breathing exercises. Simply notice when this happens and gently bring your attention back to your breath. With practice, this becomes easier.',
          isImportant: true,
        ),
      ],
    );
  }

  Widget _getGroundingContent() {
    return const _TechniqueContent(
      sections: [
        _ContentSection(
          title: 'What is it?',
          content:
              'Grounding techniques help you reconnect with the present moment when you\'re feeling overwhelmed by emotions or anxious thoughts. The 5-4-3-2-1 technique uses your five senses to anchor you in the here and now.',
        ),
        _ContentSection(
          title: 'The 5-4-3-2-1 Technique',
          content: '''Notice and name:
• 5 things you can SEE
• 4 things you can TOUCH
• 3 things you can HEAR
• 2 things you can SMELL
• 1 thing you can TASTE''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Other Grounding Techniques',
          content: '''• Hold something cold (ice cube, cold water)
• Feel your feet firmly on the ground
• Describe your surroundings in detail
• Count backwards from 100 by 7s
• Name items in a category (cities, animals, films)''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'When to Use',
          content: '''• During panic or anxiety attacks
• When feeling disconnected or "spacey"
• When overwhelmed by difficult emotions
• During flashbacks or intrusive thoughts
• When spiralling into worry''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Why It Works',
          content:
              'Grounding works by redirecting your attention from internal distress to external sensations. This interrupts the cycle of anxious thoughts and helps your nervous system settle.',
        ),
      ],
    );
  }

  Widget _getCognitiveReframingContent() {
    return const _TechniqueContent(
      sections: [
        _ContentSection(
          title: 'What is it?',
          content:
              'Cognitive reframing is a technique from cognitive behavioural therapy (CBT) that helps you identify and challenge unhelpful thought patterns. By examining your thoughts, you can develop more balanced and realistic perspectives.',
        ),
        _ContentSection(
          title: 'The ABCDE Model',
          content: '''A - Activating event (what happened)
B - Belief (your interpretation)
C - Consequence (how you feel/act)
D - Dispute (challenge the belief)
E - Effect (new perspective/feeling)''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Questions to Challenge Thoughts',
          content: '''• Is this thought based on facts or feelings?
• What evidence supports or contradicts this thought?
• Am I jumping to conclusions?
• What would I tell a friend thinking this?
• Is there another way to look at this situation?
• Will this matter in a week/month/year?''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Common Thinking Traps',
          content: '''• All-or-nothing thinking ("I always fail")
• Mind reading ("They must think I'm stupid")
• Catastrophising ("This is the worst thing ever")
• Emotional reasoning ("I feel bad, so things must be bad")
• Should statements ("I should be perfect")''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Practice',
          content:
              'Next time you notice a strong negative emotion, pause and identify the thought behind it. Write it down and work through the questions above. With practice, balanced thinking becomes more automatic.',
          isImportant: true,
        ),
      ],
    );
  }

  Widget _getMindfulnessContent() {
    return const _TechniqueContent(
      sections: [
        _ContentSection(
          title: 'What is it?',
          content:
              'Mindfulness is the practice of paying attention to the present moment without judgement. Instead of getting caught up in thoughts about the past or future, mindfulness helps you observe your experiences as they are.',
        ),
        _ContentSection(
          title: 'Simple Mindfulness Meditation',
          content: '''1. Find a comfortable position
2. Close your eyes or soften your gaze
3. Notice your breathing without changing it
4. When thoughts arise, acknowledge them
5. Gently return attention to your breath
6. Start with 5 minutes and build up''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Mindful Activities',
          content: '''• Mindful eating (notice taste, texture, smell)
• Mindful walking (feel each step)
• Mindful listening (focus fully on sounds)
• Body scan (notice sensations in each body part)
• Mindful observation (study an object in detail)''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Benefits for Mood',
          content: '''• Reduces rumination about the past
• Decreases worry about the future
• Increases awareness of emotional patterns
• Creates space between trigger and response
• Builds acceptance of difficult emotions''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Getting Started',
          content:
              'Start small - even one minute of mindful attention counts. The goal isn\'t to empty your mind, but to notice when it wanders and gently bring it back. There\'s no "perfect" meditation.',
        ),
      ],
    );
  }

  Widget _getPhysicalActivityContent() {
    return const _TechniqueContent(
      sections: [
        _ContentSection(
          title: 'Why It Helps',
          content:
              'Physical activity is one of the most effective ways to improve mood. Exercise releases endorphins, reduces stress hormones, improves sleep, and provides a sense of accomplishment. Even small amounts can make a difference.',
        ),
        _ContentSection(
          title: 'Quick Mood Boosters (5-10 mins)',
          content: '''• Brisk walk around the block
• Dancing to a favourite song
• Stretching or simple yoga
• Jumping jacks or star jumps
• Walking up and down stairs''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Moderate Activities (20-30 mins)',
          content: '''• Walking or jogging
• Swimming or cycling
• Gardening or housework
• Playing with pets
• Following an exercise video''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Tips for Getting Started',
          content: '''• Start with what you can manage
• Choose activities you enjoy
• Schedule it like an appointment
• Find an accountability partner
• Track your mood before and after
• Be patient - benefits build over time''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Remember',
          content:
              'Any movement is better than none. On difficult days, even a 5-minute walk counts. The goal is progress, not perfection. Listen to your body and adjust accordingly.',
          isImportant: true,
        ),
      ],
    );
  }

  Widget _getSelfCompassionContent() {
    return const _TechniqueContent(
      sections: [
        _ContentSection(
          title: 'What is it?',
          content:
              'Self-compassion means treating yourself with the same kindness you would offer a good friend. It involves recognising that suffering and imperfection are part of the shared human experience, rather than something that isolates you.',
        ),
        _ContentSection(
          title: 'Three Components',
          content: '''1. Self-kindness: Be gentle with yourself rather than self-critical
2. Common humanity: Remember everyone struggles; you're not alone
3. Mindfulness: Acknowledge difficult feelings without over-identifying with them''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Self-Compassion Phrases',
          content: '''Try saying to yourself:
• "This is a moment of suffering"
• "Suffering is part of being human"
• "May I be kind to myself"
• "May I give myself the compassion I need"
• "I'm doing the best I can right now"''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'The Self-Compassion Break',
          content: '''When struggling, pause and:
1. Acknowledge the difficulty ("This is hard")
2. Remember common humanity ("Others feel this too")
3. Offer yourself kindness (hand on heart, kind words)''',
          isSteps: true,
        ),
        _ContentSection(
          title: 'Common Misconceptions',
          content: '''Self-compassion is NOT:
• Self-pity (which isolates you)
• Self-indulgence (which ignores growth)
• Weakness (it actually builds resilience)
• Making excuses (it allows honest reflection)

Research shows self-compassion leads to greater motivation and wellbeing than self-criticism.''',
        ),
        _ContentSection(
          title: 'Practice',
          content:
              'Notice your inner critic. When you catch yourself being harsh, pause and ask: "Would I speak to a friend this way?" Then offer yourself the same understanding you would give them.',
          isImportant: true,
        ),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context, String type) {
    final textController = TextEditingController();
    final theme = Theme.of(context);

    String title;
    String hint;
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'bug':
        title = 'Report a Bug';
        hint = 'Please describe the bug and steps to reproduce it...';
        icon = Icons.bug_report;
        iconColor = Colors.red;
        break;
      case 'feature':
        title = 'Feature Request';
        hint = 'Describe the feature you\'d like to see...';
        icon = Icons.lightbulb_outline;
        iconColor = Colors.orange;
        break;
      default:
        title = 'Send Feedback';
        hint = 'Share your thoughts about Mood Diary...';
        icon = Icons.rate_review;
        iconColor = theme.colorScheme.primary;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const OutlineInputBorder(),
                  hintStyle: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your feedback will be sent to the developer',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              textController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final feedback = textController.text.trim();
              if (feedback.isNotEmpty) {
                textController.dispose();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                            child: Text('Thank you for your feedback!')),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    final theme = Theme.of(context);
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 12),
              Text('Rate Mood Diary'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How would you rate your experience?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        selectedRating > index
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              if (selectedRating > 0) ...[
                const SizedBox(height: 16),
                Text(
                  _getRatingLabel(selectedRating),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Maybe Later'),
            ),
            FilledButton(
              onPressed: selectedRating > 0
                  ? () {
                      Navigator.pop(dialogContext);
                      if (selectedRating >= 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.favorite, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                      'Thank you! We\'d love a review on the store!'),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        _showFeedbackDialog(context, 'feedback');
                      }
                    }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.privacyPolicy),
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: _PrivacyPolicyContent(),
          ),
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.termsOfService),
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: _TermsOfServiceContent(),
          ),
        ),
      ),
    );
  }
}

/// Privacy Policy Content
class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last updated: December 2025',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        const _PolicySection(
          title: 'Introduction',
          content:
              'Mood Diary ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
        ),
        const _PolicySection(
          title: 'Information We Collect',
          content: '''We collect minimal information to provide you with the best experience:

• Mood Entries: Your mood logs, ratings, and journal entries are stored locally on your device
• Preferences: Your app settings (theme, notifications, accessibility options)

We do NOT collect:
• Personal identification information
• Location data
• Contact information
• Health data beyond what you voluntarily enter''',
        ),
        const _PolicySection(
          title: 'Data Storage',
          content:
              'All your mood data is stored locally on your device. We do not have access to your personal mood entries or journal content. Your emotional journey remains private and under your control.',
        ),
        const _PolicySection(
          title: 'Third-Party Services',
          content: '''We may use third-party services that collect information:

• Analytics: To understand app usage patterns (anonymised)
• Crash Reporting: To identify and fix bugs

These services do not have access to your mood entries or personal journal content.''',
        ),
        const _PolicySection(
          title: 'Your Rights',
          content: '''You have the right to:

• Access your data at any time within the app
• Export your mood data
• Delete all your data through the app settings
• Opt-out of analytics collection''',
        ),
        const _PolicySection(
          title: 'Data Security',
          content:
              'We implement appropriate security measures to protect your information. Your local data is protected by your device\'s security features. We recommend using device-level security (PIN, fingerprint, or face recognition) for additional protection.',
        ),
        const _PolicySection(
          title: 'Children\'s Privacy',
          content:
              'Mood Diary is not intended for children under 13. We do not knowingly collect information from children under 13.',
        ),
        const _PolicySection(
          title: 'Mental Health Disclaimer',
          content:
              'Mood Diary is a self-help tool for tracking moods and is not a substitute for professional mental health care. If you are experiencing mental health difficulties, please consult a qualified healthcare professional.',
        ),
        const _PolicySection(
          title: 'Changes to This Policy',
          content:
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the app.',
        ),
        const _PolicySection(
          title: 'Contact Us',
          content:
              'If you have questions about this Privacy Policy, please contact us through the feedback option in the app.',
        ),
      ],
    );
  }
}

/// Terms of Service Content
class _TermsOfServiceContent extends StatelessWidget {
  const _TermsOfServiceContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last updated: December 2025',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        const _PolicySection(
          title: 'Acceptance of Terms',
          content:
              'By downloading, installing, or using Mood Diary, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.',
        ),
        const _PolicySection(
          title: 'Description of Service',
          content:
              'Mood Diary is a personal mood tracking application designed to help users monitor their emotional wellbeing. The app provides features for logging moods, writing journal entries, and viewing mood patterns over time.',
        ),
        const _PolicySection(
          title: 'Not Medical Advice',
          content:
              'Mood Diary is a self-help tool and does not provide medical, psychological, or professional mental health advice. The app is designed to support personal awareness and mindfulness around emotional wellbeing. For mental health concerns, please consult a qualified healthcare professional.',
        ),
        const _PolicySection(
          title: 'User Responsibilities',
          content: '''By using Mood Diary, you agree to:

• Use the app for its intended purpose
• Not attempt to reverse engineer or modify the app
• Not use the app for any illegal purposes
• Keep your device and app secure
• Take responsibility for the accuracy of information you enter''',
        ),
        const _PolicySection(
          title: 'Intellectual Property',
          content:
              'All content, features, and functionality of Mood Diary are owned by us and are protected by copyright, trademark, and other intellectual property laws.',
        ),
        const _PolicySection(
          title: 'Limitation of Liability',
          content:
              'Mood Diary is provided "as is" without warranties of any kind. We are not liable for any damages arising from your use of the app, including but not limited to decisions made based on mood tracking data or insights.',
        ),
        const _PolicySection(
          title: 'Data Ownership',
          content:
              'You retain ownership of all mood entries and journal content you create within the app. We do not claim any rights to your personal data.',
        ),
        const _PolicySection(
          title: 'Modifications',
          content:
              'We reserve the right to modify or discontinue the app at any time. We may also update these Terms of Service, and continued use constitutes acceptance of any changes.',
        ),
        const _PolicySection(
          title: 'Termination',
          content:
              'We may terminate or suspend your access to the app at any time, without notice, for conduct that we believe violates these Terms or is harmful to other users or us.',
        ),
        const _PolicySection(
          title: 'Governing Law',
          content:
              'These Terms shall be governed by the laws of the United Kingdom, without regard to conflict of law provisions.',
        ),
        const _PolicySection(
          title: 'Contact',
          content:
              'For questions about these Terms of Service, please contact us through the feedback option in the app.',
        ),
      ],
    );
  }
}

/// Policy section helper widget
class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Technique content container
class _TechniqueContent extends StatelessWidget {
  final List<_ContentSection> sections;

  const _TechniqueContent({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections
          .map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: section,
              ))
          .toList(),
    );
  }
}

/// Content section for technique details
class _ContentSection extends StatelessWidget {
  final String title;
  final String content;
  final bool isSteps;
  final bool isImportant;

  const _ContentSection({
    required this.title,
    required this.content,
    this.isSteps = false,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isImportant ? theme.colorScheme.primary : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: isImportant ? const EdgeInsets.all(12) : null,
          decoration: isImportant
              ? BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(75),
                  ),
                )
              : null,
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: isSteps ? 1.8 : 1.5,
              color: isImportant ? theme.colorScheme.onPrimaryContainer : null,
            ),
          ),
        ),
      ],
    );
  }
}

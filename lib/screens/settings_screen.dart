import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/premium_provider.dart';
import '../constants/app_color_schemes.dart';
import '../widgets/premium_badge.dart';
import 'accessibility_settings_screen.dart';
import 'paywall_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final themeSettings = ref.watch(themeProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: _buildIconContainer(
              context,
              Icons.brightness_6,
              theme.colorScheme.primary,
            ),
            title: const Text('Theme Mode'),
            subtitle: Text(_getThemeModeName(themeSettings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeModeDialog(context, ref, themeSettings.themeMode),
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            leading: _buildIconContainer(
              context,
              Icons.palette,
              themeSettings.colorScheme.seedColor,
            ),
            title: const Text('Colour Theme'),
            subtitle: Text(themeSettings.colorScheme.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showColorSchemeDialog(context, ref, themeSettings.colorScheme, isPremium),
          ),
          const SizedBox(height: 24),

          // General Section
          _buildSectionHeader(context, l10n.settings),
          ListTile(
            leading: _buildIconContainer(
              context,
              Icons.language,
              theme.colorScheme.tertiary,
            ),
            title: Text(l10n.language),
            subtitle: Text(
              locale != null
                  ? LocaleNotifier.getLanguageName(locale.languageCode)
                  : 'System Default',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, ref, l10n),
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            leading: _buildIconContainer(
              context,
              Icons.accessibility,
              theme.colorScheme.secondary,
            ),
            title: Text(l10n.accessibility),
            subtitle: Text(l10n.accessibilityDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AccessibilitySettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, l10n.notifications),
          ListTile(
            leading: _buildIconContainer(
              context,
              Icons.notifications_outlined,
              Colors.orange,
            ),
            title: Text(l10n.notifications),
            subtitle: Text(l10n.notificationsDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeModeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.brightness_6),
            SizedBox(width: 12),
            Text('Theme Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final isSelected = mode == currentMode;
            return ListTile(
              leading: Icon(_getThemeModeIcon(mode)),
              title: Text(_getThemeModeName(mode)),
              trailing: isSelected
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(mode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  void _showColorSchemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme currentScheme,
    bool isPremium,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(75),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.palette),
                    const SizedBox(width: 12),
                    Text(
                      'Colour Theme',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Themes grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: AppColorScheme.values.length,
                  itemBuilder: (context, index) {
                    final scheme = AppColorScheme.values[index];
                    final isSelected = scheme == currentScheme;
                    final isLocked = scheme.isPremium && !isPremium;

                    return _buildColorSchemeCard(
                      context,
                      ref,
                      scheme,
                      isSelected,
                      isLocked,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColorSchemeCard(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme scheme,
    bool isSelected,
    bool isLocked,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PaywallScreen(),
              fullscreenDialog: true,
            ),
          );
        } else {
          ref.read(themeProvider.notifier).setColorScheme(scheme);
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? scheme.seedColor : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Color preview circle
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.seedColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.seedColor.withAlpha(75),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    scheme.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: scheme.seedColor,
                        size: 20,
                      ),
                    ),
                  ),
                if (isLocked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              scheme.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (scheme.isPremium && !isLocked)
              const PremiumBadge(size: PremiumBadgeSize.tiny, showIcon: false),
          ],
        ),
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

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 12),
            Text(l10n.language),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              ref,
              null,
              '🌐',
              'System Default',
              currentLocale == null,
            ),
            ...LocaleNotifier.supportedLocales.map(
              (locale) => _buildLanguageOption(
                context,
                ref,
                locale,
                _getLocaleFlag(locale.languageCode),
                LocaleNotifier.getLanguageName(locale.languageCode),
                currentLocale?.languageCode == locale.languageCode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    Locale? locale,
    String flag,
    String name,
    bool isSelected,
  ) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  String _getLocaleFlag(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'es':
        return '🇪🇸';
      default:
        return '🌐';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accessibility_provider.dart';
import '../l10n/app_localizations.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accessibility),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildSettingTile(
            context: context,
            icon: Icons.contrast,
            title: l10n.highContrast,
            subtitle: l10n.highContrastDescription,
            value: settings.highContrast,
            onChanged: notifier.setHighContrast,
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.touch_app,
            title: l10n.largeTapTargets,
            subtitle: l10n.largeTapTargetsDescription,
            value: settings.largeTapTargets,
            onChanged: notifier.setLargeTapTargets,
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.visibility,
            title: l10n.colorBlindSafeMode,
            subtitle: l10n.colorBlindSafeModeDescription,
            value: settings.colorBlindSafeMode,
            onChanged: notifier.setColorBlindSafeMode,
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.animation,
            title: l10n.reduceMotion,
            subtitle: l10n.reduceMotionDescription,
            value: settings.reduceMotion,
            onChanged: notifier.setReduceMotion,
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.font_download,
            title: l10n.dyslexiaFriendlyFont,
            subtitle: l10n.dyslexiaFriendlyFontDescription,
            value: settings.dyslexiaFriendlyFont,
            onChanged: notifier.setDyslexiaFriendlyFont,
          ),
          _buildSettingTile(
            context: context,
            icon: Icons.text_fields,
            title: l10n.readableTextMode,
            subtitle: l10n.readableTextModeDescription,
            value: settings.readableTextMode,
            onChanged: notifier.setReadableTextMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

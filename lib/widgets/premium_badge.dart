import 'package:flutter/material.dart';

/// Premium badge widget to show "PRO" or "PREMIUM" on features
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
    super.key,
    this.size = PremiumBadgeSize.small,
    this.showIcon = true,
  });

  final PremiumBadgeSize size;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final (fontSize, padding, iconSize) = switch (size) {
      PremiumBadgeSize.tiny =>
        (9.0, const EdgeInsets.symmetric(horizontal: 4, vertical: 1), 10.0),
      PremiumBadgeSize.small =>
        (10.0, const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 12.0),
      PremiumBadgeSize.medium =>
        (12.0, const EdgeInsets.symmetric(horizontal: 8, vertical: 3), 14.0),
      PremiumBadgeSize.large =>
        (14.0, const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 16.0),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFFD54F)],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withAlpha(75),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.star,
              size: iconSize,
              color: Colors.white,
            ),
            SizedBox(width: iconSize * 0.3),
          ],
          Text(
            'PRO',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

enum PremiumBadgeSize {
  tiny,
  small,
  medium,
  large,
}

/// Premium lock icon for locked features
class PremiumLockIcon extends StatelessWidget {
  const PremiumLockIcon({
    super.key,
    this.size = 20,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.25),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber.withAlpha(50),
      ),
      child: Icon(
        Icons.lock,
        size: size,
        color: Colors.amber,
      ),
    );
  }
}

/// Premium feature card for paywall or settings
class PremiumFeatureCard extends StatelessWidget {
  const PremiumFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.color,
    this.isUnlocked = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? color;
  final bool isUnlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: effectiveColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        else
                          const PremiumLockIcon(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

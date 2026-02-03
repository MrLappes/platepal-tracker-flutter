import 'package:flutter/material.dart';

/// Industrial/Cyberpunk-styled reusable UI components
/// Used throughout the app for consistent design language

/// Industrial-styled container with border and sharp corners
class IndustrialContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;

  const IndustrialContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 4,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border.all(
          color: borderColor ?? colorScheme.outline.withValues(alpha: 0.5),
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

/// Industrial-styled card for sections and content blocks
class IndustrialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const IndustrialCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = IndustrialContainer(
      padding: padding,
      margin: margin,
      child: child,
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Industrial-styled section header
class IndustrialSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const IndustrialSectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(left: 4, bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding!,
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Industrial-styled list tile for settings and menu items
class IndustrialListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showBorder;

  const IndustrialListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration:
            showBorder
                ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                )
                : null,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}

/// Industrial-styled button with border
class IndustrialButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;

  const IndustrialButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final button = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? colorScheme.primary : Colors.transparent,
        border: Border.all(color: colorScheme.primary, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isPrimary ? colorScheme.onPrimary : colorScheme.primary,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: isPrimary ? colorScheme.onPrimary : colorScheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (onPressed == null) return button;

    return InkWell(onTap: onPressed, child: button);
  }
}

/// Industrial-styled info box
class IndustrialInfoBox extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;

  const IndustrialInfoBox({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: borderColor ?? colorScheme.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Industrial-styled divider with label
class IndustrialDivider extends StatelessWidget {
  final String? label;
  final EdgeInsets? margin;

  const IndustrialDivider({
    super.key,
    this.label,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (label == null) {
      return Padding(
        padding: margin!,
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      );
    }

    return Padding(
      padding: margin!,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

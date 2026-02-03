# Industrial/Cyberpunk UI Style Guide

## Overview
PlatePal Tracker uses an industrial/cyberpunk design language throughout the app for a cohesive, modern aesthetic.

## Core Design Principles

### 1. Typography
- **Uppercase Text**: Section headers, button labels, and titles use uppercase
- **Bold Weights**: FontWeight.w900 for primary headers, w700 for secondary
- **Letter Spacing**: 0.5-1.0 for uppercase text to improve readability
- **Font Sizes**: 
  - Headers: 12-14px
  - Body: 11px
  - Labels: 9-10px

### 2. Layout & Spacing
- **Sharp Corners**: borderRadius: 4 (no rounded corners like 16 or 20)
- **Consistent Padding**: 16px standard, 20px for larger sections
- **Borders**: Always visible, alpha: 0.5 for primary, 0.2-0.3 for dividers
- **Container Margins**: 16-24px between sections

### 3. Color Usage
- **Primary Color**: Used for accents, icons, and CTAs
- **Surface**: colorScheme.surface for card backgrounds
- **Borders**: colorScheme.outline with withValues(alpha: 0.3-0.5)
- **Text**: onSurface with alpha variations (0.6-0.8) for hierarchy

### 4. AppBar Style
```dart
AppBar(
  title: Text('${localizations.title.toUpperCase()} //'),
  // No explicit backgroundColor, foregroundColor, or elevation
)
```

## Reusable Components

### IndustrialContainer
Basic container with border and sharp corners.
```dart
IndustrialContainer(
  padding: const EdgeInsets.all(16),
  child: YourWidget(),
)
```

### IndustrialCard
Pre-styled card for content blocks.
```dart
IndustrialCard(
  padding: const EdgeInsets.all(16),
  onTap: () {}, // Optional
  child: YourContent(),
)
```

### IndustrialSectionHeader
Uppercase section headers with consistent styling.
```dart
IndustrialSectionHeader(
  title: 'Section Title', // Will be automatically uppercased
)
```

### IndustrialListTile
Settings-style list items with icons and subtitles.
```dart
IndustrialListTile(
  title: 'Item Title', // Automatically uppercased
  subtitle: 'Description text',
  icon: Icons.settings,
  onTap: () {},
)
```

### IndustrialButton
Primary and secondary buttons with border style.
```dart
IndustrialButton(
  text: 'Button Label', // Automatically uppercased
  icon: Icons.save,
  isPrimary: true,
  isFullWidth: false,
  onPressed: () {},
)
```

### IndustrialInfoBox
Information cards with icons.
```dart
IndustrialInfoBox(
  title: 'Info Title',
  message: 'Detailed information message',
  icon: Icons.info_outline,
)
```

### IndustrialDivider
Section dividers with optional labels.
```dart
IndustrialDivider(label: 'Optional Label')
```

## Implementation Examples

### Settings Screen Pattern
```dart
return Scaffold(
  appBar: AppBar(
    title: Text('${l10n.screenTitle.toUpperCase()} //'),
  ),
  body: ListView(
    padding: const EdgeInsets.all(20),
    children: [
      IndustrialSectionHeader(title: 'Section Name'),
      const SizedBox(height: 16),
      
      IndustrialCard(
        child: Column(
          children: [
            IndustrialListTile(
              title: 'Setting 1',
              subtitle: 'Description',
              icon: Icons.settings,
              onTap: () {},
            ),
            IndustrialListTile(
              title: 'Setting 2',
              subtitle: 'Description',
              icon: Icons.tune,
              onTap: () {},
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 24),
      IndustrialInfoBox(
        title: 'Important Note',
        message: 'Additional information for users',
      ),
    ],
  ),
);
```

### Form Input Pattern
```dart
IndustrialContainer(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'FIELD LABEL',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    ],
  ),
)
```

### Action Button Pattern
```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: colorScheme.primary.withValues(alpha: 0.05),
    border: Border.all(
      color: colorScheme.primary.withValues(alpha: 0.3),
    ),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Column(
    children: [
      Text(
        'CALL TO ACTION',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 12),
      IndustrialButton(
        text: 'Action Label',
        icon: Icons.arrow_forward,
        isFullWidth: true,
        onPressed: () {},
      ),
    ],
  ),
)
```

## Migration Checklist

When updating a screen to industrial style:

- [ ] Update AppBar title to uppercase with "//"
- [ ] Replace Card widgets with IndustrialCard
- [ ] Replace ListTile with IndustrialListTile where appropriate
- [ ] Add IndustrialSectionHeader for section titles
- [ ] Change borderRadius from 8-20 to 4
- [ ] Update button styling to use IndustrialButton
- [ ] Ensure all labels use .toUpperCase()
- [ ] Apply proper letter spacing to uppercase text
- [ ] Use withValues(alpha: X) instead of withOpacity()
- [ ] Remove explicit theme colors from AppBar

## Color Reference

```dart
// Primary colors and borders
colorScheme.primary                          // Accent color
colorScheme.surface                          // Card backgrounds
colorScheme.outline.withValues(alpha: 0.5)   // Primary borders
colorScheme.outline.withValues(alpha: 0.3)   // Secondary borders
colorScheme.outline.withValues(alpha: 0.2)   // Dividers

// Text colors
colorScheme.onSurface                        // Primary text
colorScheme.onSurface.withValues(alpha: 0.8) // Secondary text
colorScheme.onSurface.withValues(alpha: 0.6) // Tertiary text
colorScheme.onSurface.withValues(alpha: 0.5) // Disabled/hint text

// Backgrounds
colorScheme.primary.withValues(alpha: 0.05)  // Light primary tint
colorScheme.primary.withValues(alpha: 0.1)   // Medium primary tint
```

## DO's and DON'Ts

### DO
✅ Use uppercase for headers, labels, and buttons  
✅ Use sharp corners (borderRadius: 4)  
✅ Show borders on all containers  
✅ Use consistent padding (16, 20, 24)  
✅ Apply letter spacing to uppercase text  
✅ Use FontWeight.w900 for emphasis  

### DON'T
❌ Use rounded corners (> 8)  
❌ Hide borders on containers  
❌ Use mixed case in headers  
❌ Use gradient backgrounds  
❌ Hardcode color values  
❌ Use withOpacity() (use withValues(alpha:))  

## Resources

- Industrial Components: `/lib/components/ui/industrial_components.dart`
- Reference Screens: 
  - `/lib/screens/settings/about_screen.dart`
  - `/lib/screens/settings/contributors_screen.dart`
  - `/lib/screens/menu_screen.dart`

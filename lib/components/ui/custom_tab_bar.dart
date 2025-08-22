import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.restaurant),
          label: AppLocalizations.of(context).componentsUiCustomTabBarMeals,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today),
          label: AppLocalizations.of(context).componentsUiCustomTabBarCalendar,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat),
          label: AppLocalizations.of(context).componentsUiCustomTabBarChat,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.menu),
          label: AppLocalizations.of(context).componentsUiCustomTabBarMenu,
        ),
      ],
    );
  }
}

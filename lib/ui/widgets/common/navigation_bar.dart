import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.selectedRoute,
    required this.onSelected,
  });

  final String selectedRoute;
  final ValueChanged<String> onSelected;

  static const _destinations = [
    ('/', Icons.home_outlined, Icons.home, 'home'),
    ('/path', Icons.route_outlined, Icons.route, 'path'),
    ('/settings', Icons.settings_outlined, Icons.settings, 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      'home': l10n.navigateHome,
      'path': l10n.navigatePath,
      'settings': l10n.navigateSettings,
    };
    final selectedIndex = _destinations.indexWhere(
      (destination) => destination.$1 == selectedRoute,
    );
    final index = selectedIndex < 0 ? 0 : selectedIndex;
    if (MediaQuery.sizeOf(context).width >= 840) {
      return NavigationRail(
        selectedIndex: index,
        onDestinationSelected: (value) =>
            onSelected(_destinations[value].$1),
        labelType: NavigationRailLabelType.all,
        destinations: [
          for (final destination in _destinations)
            NavigationRailDestination(
              icon: Icon(destination.$2),
              selectedIcon: Icon(destination.$3),
              label: Text(labels[destination.$4]!),
            ),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => onSelected(_destinations[value].$1),
      destinations: [
        for (final destination in _destinations)
          NavigationDestination(
            icon: Icon(destination.$2),
            selectedIcon: Icon(destination.$3),
            label: labels[destination.$4]!,
          ),
      ],
    );
  }
}

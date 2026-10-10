// shared/layouts/clinician_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routing/route_paths.dart';
import 'responsive_app_shell.dart';

class ClinicianShell extends StatelessWidget {
  final Widget child;

  const ClinicianShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RoutePaths.clinicianHome)) return 0;
    if (location.startsWith(RoutePaths.clinicianDirectory)) return 1;
    if (location.startsWith(RoutePaths.clinicianAdherenceOverview)) return 2;
    if (location.startsWith(RoutePaths.clinicianSettings)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RoutePaths.clinicianHome);
        break;
      case 1:
        context.go(RoutePaths.clinicianDirectory);
        break;
      case 2:
        context.go(RoutePaths.clinicianAdherenceOverview);
        break;
      case 3:
        context.go(RoutePaths.clinicianSettings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAppShell(
      sectionLabel: 'Clinician Portal',
      selectedIndex: _calculateSelectedIndex(context),
      onSelected: (index) => _onItemTapped(index, context),
      items: const [
        ResponsiveNavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Dashboard'),
        ResponsiveNavItem(
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            label: 'Patients'),
        ResponsiveNavItem(
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics,
            label: 'Analytics'),
        ResponsiveNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings'),
      ],
      child: child,
    );
  }
}

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
    if (location.startsWith(RoutePaths.clinicianMessages)) return 2;
    if (location.startsWith(RoutePaths.clinicianAdherenceOverview)) return 3;
    if (location.startsWith(RoutePaths.clinicianProfile)) return 4;
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
        context.go(RoutePaths.clinicianMessages);
        break;
      case 3:
        context.go(RoutePaths.clinicianAdherenceOverview);
        break;
      case 4:
        context.go(RoutePaths.clinicianProfile);
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
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups,
            label: 'Patients'),
        ResponsiveNavItem(
            icon: Icons.mail_outline,
            selectedIcon: Icons.mail,
            label: 'Messages'),
        ResponsiveNavItem(
            icon: Icons.bar_chart,
            selectedIcon: Icons.analytics,
            label: 'Analytics'),
        ResponsiveNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile'),
      ],
      child: child,
    );
  }
}

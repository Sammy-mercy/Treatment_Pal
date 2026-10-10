// shared/layouts/patient_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routing/route_paths.dart';
import 'responsive_app_shell.dart';

class PatientShell extends StatelessWidget {
  final Widget child;

  const PatientShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RoutePaths.patientHome)) return 0;
    if (location.startsWith(RoutePaths.patientRegimens)) return 1;
    if (location.startsWith(RoutePaths.patientAdherence)) return 2;
    if (location.startsWith(RoutePaths.patientNotifications)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RoutePaths.patientHome);
        break;
      case 1:
        context.go(RoutePaths.patientRegimens);
        break;
      case 2:
        context.go(RoutePaths.patientAdherence);
        break;
      case 3:
        context.go(RoutePaths.patientNotifications);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAppShell(
      sectionLabel: 'Patient Portal',
      selectedIndex: _calculateSelectedIndex(context),
      onSelected: (index) => _onItemTapped(index, context),
      items: const [
        ResponsiveNavItem(
            icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
        ResponsiveNavItem(
            icon: Icons.medication_outlined,
            selectedIcon: Icons.medication,
            label: 'Regimen'),
        ResponsiveNavItem(
            icon: Icons.show_chart,
            selectedIcon: Icons.show_chart,
            label: 'Adherence'),
        ResponsiveNavItem(
            icon: Icons.notifications_none,
            selectedIcon: Icons.notifications,
            label: 'Alerts'),
      ],
      child: child,
    );
  }
}

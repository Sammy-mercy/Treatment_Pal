// shared/layouts/patient_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../routing/route_paths.dart';

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
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), activeIcon: Icon(Icons.medication), label: 'Regimen'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Adherence'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
}

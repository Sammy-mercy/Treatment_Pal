import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:therapy_pal/shared/layouts/responsive_app_shell.dart';

void main() {
  const items = [
    ResponsiveNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    ResponsiveNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  Future<void> pumpAtWidth(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveAppShell(
          sectionLabel: 'Patient Portal',
          items: items,
          selectedIndex: 0,
          onSelected: (_) {},
          child: const Scaffold(body: Text('Page content')),
        ),
      ),
    );
  }

  testWidgets('uses bottom navigation on phones', (tester) async {
    await pumpAtWidth(tester, 390);

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses navigation rail on tablets', (tester) async {
    await pumpAtWidth(tester, 820);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('uses branded sidebar on laptops', (tester) async {
    await pumpAtWidth(tester, 1366);

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Therapy Pal'), findsOneWidget);
    expect(find.text('PATIENT PORTAL'), findsOneWidget);
  });
}

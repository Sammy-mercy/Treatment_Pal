// app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/logic/auth_provider.dart';
import 'routing/app_router.dart';

class TherapyPalApp extends StatefulWidget {
  const TherapyPalApp({super.key});

  @override
  State<TherapyPalApp> createState() => _TherapyPalAppState();
}

class _TherapyPalAppState extends State<TherapyPalApp> {
  late final router = createAppRouter(context.read<AuthProvider>());

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
 
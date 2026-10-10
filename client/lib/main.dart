// main.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core Network
import 'core/network/api_client.dart';
import 'core/analytics/visit_tracker.dart';

// Feature Repositories & Services
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/regimen/data/regimen_api_service.dart';
import 'features/regimen/data/regimen_repository.dart';
import 'features/regimen/logic/regimen_provider.dart';
import 'features/adherence/data/adherence_repository.dart';
import 'features/adherence/logic/adherence_provider.dart';
import 'features/patient_directory/data/patient_directory_repository.dart';
import 'features/patient_directory/logic/patient_directory_provider.dart';
import 'features/notifications/data/notification_service.dart';
import 'features/notifications/logic/notification_provider.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Instantiate singleton network client
  final apiClient = ApiClient();
  unawaited(VisitTracker.recordAnonymousVisit(apiClient));

  // Instantiate repositories
  final authRepository = AuthRepository(apiClient);
  final regimenApiService = RegimenApiService(apiClient);
  final regimenRepository = RegimenRepository(regimenApiService);
  final adherenceRepository = AdherenceRepository(apiClient);
  final patientDirectoryRepository = PatientDirectoryRepository(apiClient);
  final notificationService = NotificationService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RegimenProvider(regimenRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AdherenceProvider(adherenceRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PatientDirectoryProvider(patientDirectoryRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationService),
        ),
      ],
      child: const TherapyPalApp(),
    ),
  );
}

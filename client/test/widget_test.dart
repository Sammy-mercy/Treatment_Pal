import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:therapy_pal/app.dart';
import 'package:therapy_pal/core/network/api_client.dart';
import 'package:therapy_pal/features/auth/data/auth_repository.dart';
import 'package:therapy_pal/features/auth/logic/auth_provider.dart';
import 'package:therapy_pal/features/auth/presentation/screens/splash_screen.dart';
import 'package:therapy_pal/features/regimen/data/regimen_api_service.dart';
import 'package:therapy_pal/features/regimen/data/regimen_repository.dart';
import 'package:therapy_pal/features/regimen/logic/regimen_provider.dart';
import 'package:therapy_pal/features/adherence/data/adherence_repository.dart';
import 'package:therapy_pal/features/adherence/logic/adherence_provider.dart';
import 'package:therapy_pal/features/patient_directory/data/patient_directory_repository.dart';
import 'package:therapy_pal/features/patient_directory/logic/patient_directory_provider.dart';
import 'package:therapy_pal/features/notifications/data/notification_service.dart';
import 'package:therapy_pal/features/notifications/logic/notification_provider.dart';
import 'package:therapy_pal/shared/widgets/brand_logo.dart';

void main() {
  testWidgets('App smoke test: Splash Screen transitions to Login Screen with BrandLogo', (WidgetTester tester) async {
    final apiClient = ApiClient();
    final authRepository = AuthRepository(apiClient);
    final regimenApiService = RegimenApiService(apiClient);
    final regimenRepository = RegimenRepository(regimenApiService);
    final adherenceRepository = AdherenceRepository(apiClient);
    final patientDirectoryRepository = PatientDirectoryRepository(apiClient);
    final notificationService = NotificationService(apiClient);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
          ChangeNotifierProvider(create: (_) => RegimenProvider(regimenRepository)),
          ChangeNotifierProvider(create: (_) => AdherenceProvider(adherenceRepository)),
          ChangeNotifierProvider(create: (_) => PatientDirectoryProvider(patientDirectoryRepository)),
          ChangeNotifierProvider(create: (_) => NotificationProvider(notificationService)),
        ],
        child: const TherapyPalApp(),
      ),
    );

    // Initial frame renders on Splash screen
    expect(find.byType(TherapyPalApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('CARE THAT KEEPS UP WITH YOU'), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);

    // Advance timer past the 1.2 second splash duration
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Now on Login Screen
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Therapy Pal'), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
  });
}

// routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/utils/browser_location_stub.dart'
    if (dart.library.html) '../core/utils/browser_location_web.dart'
    as browser_location;
import '../features/auth/logic/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/patient_home_screen.dart';
import '../features/home/presentation/screens/clinician_home_screen.dart';
import '../features/regimen/presentation/screens/patient/regimen_list_screen.dart';
import '../features/regimen/presentation/screens/patient/regimen_detail_screen.dart';
import '../features/regimen/presentation/screens/clinician/create_regimen_screen.dart';
import '../features/regimen/presentation/screens/clinician/edit_regimen_screen.dart';
import '../features/adherence/presentation/screens/patient/adherence_log_screen.dart';
import '../features/adherence/presentation/screens/clinician/adherence_overview_screen.dart';
import '../features/patient_directory/presentation/screens/patient_list_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/profile/presentation/screens/patient_profile_screen.dart';
import '../features/profile/presentation/screens/clinician_profile_screen.dart';
import '../features/messages/presentation/screens/clinician_messages_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../shared/layouts/patient_shell.dart';
import '../shared/layouts/clinician_shell.dart';
import 'route_paths.dart';
import 'route_guard.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _patientShellKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _clinicianShellKey =
    GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      return RouteGuard.checkAccess(
        isAuthenticated: authProvider.isAuthenticated,
        userRole: authProvider.currentRole,
        targetPath: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => RoutePaths.splash,
      ),
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth routes
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => LoginScreen(
          adminPortal: browser_location.browserPath == '/admin' ||
              browser_location.browserPath == '/admin/',
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Patient Shell Navigation
      ShellRoute(
        navigatorKey: _patientShellKey,
        builder: (context, state, child) => PatientShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.patientHome,
            builder: (context, state) => const PatientHomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.patientRegimens,
            builder: (context, state) => const PatientRegimenListScreen(),
          ),
          GoRoute(
            path: RoutePaths.patientAdherence,
            builder: (context, state) => const PatientAdherenceLogScreen(),
          ),
          GoRoute(
            path: RoutePaths.patientNotifications,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: RoutePaths.patientProfile,
            builder: (context, state) => const PatientProfileScreen(),
          ),
        ],
      ),

      // Clinician Shell Navigation
      ShellRoute(
        navigatorKey: _clinicianShellKey,
        builder: (context, state, child) => ClinicianShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.clinicianHome,
            builder: (context, state) => const ClinicianHomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.clinicianDirectory,
            builder: (context, state) => const PatientListScreen(),
          ),
          GoRoute(
            path: RoutePaths.clinicianMessages,
            builder: (context, state) => const ClinicianMessagesScreen(),
          ),
          GoRoute(
            path: RoutePaths.clinicianAdherenceOverview,
            builder: (context, state) =>
                const ClinicianAdherenceOverviewScreen(),
          ),
          GoRoute(
            path: RoutePaths.clinicianProfile,
            builder: (context, state) => const ClinicianProfileScreen(),
          ),
          GoRoute(
            path: RoutePaths.clinicianSettings,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
        ],
      ),

      // Standalone Detail & Action Routes
      GoRoute(
        path: RoutePaths.patientRegimenDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PatientRegimenDetailScreen(
          regimenId: state.pathParameters['id'] ?? 'reg_01',
        ),
      ),
      GoRoute(
        path: RoutePaths.clinicianCreateRegimen,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClinicianCreateRegimenScreen(),
      ),
      GoRoute(
        path: RoutePaths.clinicianEditRegimen,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ClinicianEditRegimenScreen(
          regimenId: state.pathParameters['id'] ?? 'reg_01',
        ),
      ),
    ],
  );
}

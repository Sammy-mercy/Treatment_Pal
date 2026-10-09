// routing/route_guard.dart
import '../models/user_model.dart';
import 'route_paths.dart';

class RouteGuard {
  static String? checkAccess({
    required bool isAuthenticated,
    required UserRole? userRole,
    required String targetPath,
  }) {
    final isAuthRoute = targetPath == RoutePaths.login ||
        targetPath == RoutePaths.register ||
        targetPath == RoutePaths.splash;

    // 1. Unauthenticated users can only visit auth routes
    if (!isAuthenticated) {
      return isAuthRoute ? null : RoutePaths.login;
    }

    // 2. If authenticated user tries to visit login/register, redirect to appropriate home
    if (isAuthRoute && targetPath != RoutePaths.splash) {
      return userRole == UserRole.clinician ? RoutePaths.clinicianHome : RoutePaths.patientHome;
    }

    // 3. Role-based route enforcement
    if (userRole == UserRole.patient && targetPath.startsWith('/clinician')) {
      return RoutePaths.patientHome;
    }

    if (userRole == UserRole.clinician && targetPath.startsWith('/patient')) {
      return RoutePaths.clinicianHome;
    }

    return null; // Access granted
  }
}
 
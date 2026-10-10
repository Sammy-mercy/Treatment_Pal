import 'package:flutter_test/flutter_test.dart';
import 'package:therapy_pal/models/user_model.dart';
import 'package:therapy_pal/routing/route_guard.dart';
import 'package:therapy_pal/routing/route_paths.dart';

void main() {
  test('only admin sessions can open the admin route', () {
    expect(
      RouteGuard.checkAccess(
        isAuthenticated: true,
        userRole: UserRole.patient,
        targetPath: RoutePaths.adminDashboard,
      ),
      RoutePaths.patientHome,
    );
    expect(
      RouteGuard.checkAccess(
        isAuthenticated: true,
        userRole: UserRole.admin,
        targetPath: RoutePaths.adminDashboard,
      ),
      isNull,
    );
    expect(
      RouteGuard.checkAccess(
        isAuthenticated: false,
        userRole: null,
        targetPath: RoutePaths.adminDashboard,
      ),
      RoutePaths.login,
    );
  });

  test('authenticated admins return to the dashboard from auth routes', () {
    expect(
      RouteGuard.checkAccess(
        isAuthenticated: true,
        userRole: UserRole.admin,
        targetPath: RoutePaths.login,
      ),
      RoutePaths.adminDashboard,
    );
  });
}

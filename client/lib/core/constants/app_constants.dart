// core/constants/app_constants.dart

class AppConstants {
  static const String appName = 'Therapy Pal';
  static const String appTagline = 'Treatment Regimen Management';
  static const String apiBaseUrl = 'http://localhost:5000/api';
  
  // Storage Keys
  static const String tokenKey = 'tp_auth_token';
  static const String refreshTokenKey = 'tp_refresh_token';
  static const String userRoleKey = 'tp_user_role';

  // Benchmark Adherence Target
  static const int adherenceTargetPercent = 80;
}

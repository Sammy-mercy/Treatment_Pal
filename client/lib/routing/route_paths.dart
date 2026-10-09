// routing/route_paths.dart

class RoutePaths {
  // Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Patient Routes
  static const String patientHome = '/patient/home';
  static const String patientRegimens = '/patient/regimens';
  static const String patientRegimenDetail = '/patient/regimens/:id';
  static const String patientAdherence = '/patient/adherence';
  static const String patientNotifications = '/patient/notifications';
  static const String patientProfile = '/patient/profile';

  // Clinician Routes
  static const String clinicianHome = '/clinician/home';
  static const String clinicianDirectory = '/clinician/patients';
  static const String clinicianPatientDetail = '/clinician/patients/:id';
  static const String clinicianCreateRegimen = '/clinician/regimens/create';
  static const String clinicianEditRegimen = '/clinician/regimens/:id/edit';
  static const String clinicianAdherenceOverview = '/clinician/adherence-overview';
  static const String clinicianSettings = '/clinician/settings';
}
 
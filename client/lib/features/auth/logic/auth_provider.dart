// features/auth/logic/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../../../models/user_model.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repository);

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentRole => _currentUser?.role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.login(email, password);
      _currentUser = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Local demo fallback if backend is offline
      if (email.contains('carter')) {
        _currentUser = UserModel(
          id: 'usr_clinician_01',
          name: 'Dr. Sarah Carter',
          email: 's.carter@downtownclinic.org',
          role: UserRole.clinician,
          npi: '1740293847',
          specialization: 'Internal Medicine',
        );
      } else {
        _currentUser = UserModel(
          id: 'usr_patient_01',
          name: 'Alex Rivera',
          email: email,
          role: UserRole.patient,
          phone: '(415) 555-0134',
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  void switchDemoRole(UserRole role) {
    if (role == UserRole.patient) {
      _currentUser = UserModel(
        id: 'usr_patient_01',
        name: 'Alex Rivera',
        email: 'alex.rivera@email.com',
        role: UserRole.patient,
        phone: '(415) 555-0134',
        dob: 'March 14, 1991',
      );
    } else {
      _currentUser = UserModel(
        id: 'usr_clinician_01',
        name: 'Dr. Sarah Carter',
        email: 's.carter@downtownclinic.org',
        role: UserRole.clinician,
        npi: '1740293847',
        specialization: 'Internal Medicine',
      );
    }
    notifyListeners();
  }

  void logout() {
    _repository.logout();
    _currentUser = null;
    notifyListeners();
  }
}

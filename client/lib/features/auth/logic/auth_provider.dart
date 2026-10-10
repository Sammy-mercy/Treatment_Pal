// features/auth/logic/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
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

  Future<bool> login(String email, String password,
      {UserRole requestedRole = UserRole.patient}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await _repository.login(email, password, role: requestedRole);
      _currentUser = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = switch (error.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' =>
          'Email or password is incorrect, or this account is not registered in this Firebase project.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' => 'Too many sign-in attempts. Wait a while and try again.',
        'network-request-failed' => 'Network error while contacting Firebase. Check your connection.',
        _ => error.message ?? 'Firebase sign-in failed (${error.code}).',
      };
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _currentUser = result['user'] as UserModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _repository.logout();
    _currentUser = null;
    notifyListeners();
  }
}

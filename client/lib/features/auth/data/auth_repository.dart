// features/auth/data/auth_repository.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final FirebaseAuth? _firebaseAuthOverride;

  AuthRepository(this._apiClient, {FirebaseAuth? firebaseAuth})
      : _firebaseAuthOverride = firebaseAuth;

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? FirebaseAuth.instance;

  Future<void> ensureBackendIsAvailable() async {
    final healthy = await _apiClient.isBackendHealthy();
    if (!healthy) {
      throw ApiException(
        message:
            'Therapy Pal is temporarily unavailable. Please try again in a moment.',
      );
    }
  }

  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    required UserRole role,
  }) async {
    if (role == UserRole.admin) {
      await ensureBackendIsAvailable();
      final response = await _apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );
      final user = UserModel.fromJson(response['user']);
      _apiClient.setAuthTokenProvider(null);
      _apiClient.setAuthToken(response['token'] as String);
      return {'user': user, 'token': response['token']};
    }

    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final token = await credential.user!.getIdToken();
    _apiClient
        .setAuthTokenProvider(() => _firebaseAuth.currentUser?.getIdToken());
    _apiClient.setAuthToken(token);
    await ensureBackendIsAvailable();
    final response = await _apiClient.post('/auth/session', body: const {});

    final user = UserModel.fromJson(response['user']);
    await _recordAuthenticatedVisit();

    return {'user': user, 'token': token};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user!;
    await firebaseUser.updateDisplayName(name);
    final token = await firebaseUser.getIdToken();
    _apiClient
        .setAuthTokenProvider(() => _firebaseAuth.currentUser?.getIdToken());
    _apiClient.setAuthToken(token);

    try {
      await ensureBackendIsAvailable();
      final response = await _apiClient.post(
        '/auth/register',
        body: {
          'name': name,
          'role': role == UserRole.clinician ? 'clinician' : 'patient',
        },
      );
      final user = UserModel.fromJson(response['user']);
      await _recordAuthenticatedVisit();
      return {'user': user, 'token': token};
    } catch (_) {
      _apiClient.setAuthToken(null);
      _apiClient.setAuthTokenProvider(null);
      try {
        await firebaseUser.delete();
      } catch (_) {
        await _firebaseAuth.signOut();
      }
      rethrow;
    }
  }

  void logout() {
    _apiClient.setAuthToken(null);
    _apiClient.setAuthTokenProvider(null);
    if (_firebaseAuth.currentUser != null) unawaited(_firebaseAuth.signOut());
  }

  Future<void> _recordAuthenticatedVisit() async {
    try {
      await _apiClient.post('/analytics/visit', body: const {});
    } catch (_) {
      // Visit tracking should not fail an otherwise valid sign-in.
    }
  }
}

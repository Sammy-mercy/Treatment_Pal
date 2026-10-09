// features/auth/data/auth_repository.dart
import '../../../core/network/api_client.dart';
import '../../../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    final user = UserModel.fromJson(response['user']);
    final token = response['token'] as String;
    _apiClient.setAuthToken(token);

    return {'user': user, 'token': token};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role == UserRole.clinician ? 'clinician' : 'patient',
      },
    );

    final user = UserModel.fromJson(response['user']);
    final token = response['token'] as String;
    _apiClient.setAuthToken(token);

    return {'user': user, 'token': token};
  }

  void logout() {
    _apiClient.setAuthToken(null);
  }
}

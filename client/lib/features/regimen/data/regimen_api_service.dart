// features/regimen/data/regimen_api_service.dart
import '../../../core/network/api_client.dart';

class RegimenApiService {
  final ApiClient _apiClient;

  RegimenApiService(this._apiClient);

  Future<List<dynamic>> fetchRegimens() async {
    final response = await _apiClient.get('/regimens');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> fetchRegimenById(String id) async {
    final response = await _apiClient.get('/regimens/$id');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createRegimen(Map<String, dynamic> body) async {
    final response = await _apiClient.post('/regimens', body: body);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateRegimen(String id, Map<String, dynamic> body) async {
    final response = await _apiClient.put('/regimens/$id', body: body);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> toggleItem(String regimenId, String itemId) async {
    final response = await _apiClient.patch('/regimens/$regimenId/items/$itemId/toggle');
    return response as Map<String, dynamic>;
  }
}

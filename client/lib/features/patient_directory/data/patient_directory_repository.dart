// features/patient_directory/data/patient_directory_repository.dart
import '../../../core/network/api_client.dart';

class PatientDirectoryRepository {
  final ApiClient _apiClient;

  PatientDirectoryRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final list = await _apiClient.get('/users?role=patient') as List<dynamic>;
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      // Local seed
      return [
        {
          'id': 'p1',
          'name': 'Alex Rivera',
          'initials': 'AR',
          'regimen': 'Ibuprofen · Ankle Exercises',
          'rate': 92,
          'last': 'Today · 09:20 AM',
          'age': 34,
          'note': 'Post-operative ankle recovery'
        },
        {
          'id': 'p2',
          'name': 'Maya Chen',
          'initials': 'MC',
          'regimen': 'Lisinopril 10 mg',
          'rate': 88,
          'last': 'Today · 07:40 AM',
          'age': 58,
          'note': 'Hypertension management'
        },
        {
          'id': 'p3',
          'name': 'Jordan Blake',
          'initials': 'JB',
          'regimen': 'Physical therapy (Shoulder)',
          'rate': 55,
          'last': 'Sep 27, 2026',
          'age': 27,
          'note': 'Shoulder rehabilitation - Needs attention'
        },
      ];
    }
  }
}

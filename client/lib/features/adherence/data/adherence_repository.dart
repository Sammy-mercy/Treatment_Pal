// features/adherence/data/adherence_repository.dart
import '../../../core/network/api_client.dart';
import '../../../models/adherence_log_model.dart';

class AdherenceRepository {
  final ApiClient _apiClient;

  AdherenceRepository(this._apiClient);

  Future<List<AdherenceLogModel>> getLogs() async {
    try {
      final list = await _apiClient.get('/adherence-logs') as List<dynamic>;
      return list.map((item) => AdherenceLogModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      // Local seed
      return [
        AdherenceLogModel(
          id: 'log_01',
          regimenItemId: 'item_02',
          patientId: 'usr_patient_01',
          status: AdherenceStatus.taken,
          scheduledAt: '2026-09-29T09:00:00Z',
          loggedAt: '2026-09-29T09:20:00Z',
        ),
        AdherenceLogModel(
          id: 'log_02',
          regimenItemId: 'item_03',
          patientId: 'usr_patient_01',
          status: AdherenceStatus.taken,
          scheduledAt: '2026-09-29T08:00:00Z',
          loggedAt: '2026-09-29T08:06:00Z',
        ),
        AdherenceLogModel(
          id: 'log_03',
          regimenItemId: 'item_01',
          patientId: 'usr_patient_01',
          status: AdherenceStatus.taken,
          scheduledAt: '2026-09-29T08:00:00Z',
          loggedAt: '2026-09-29T08:05:00Z',
        ),
        AdherenceLogModel(
          id: 'log_04',
          regimenItemId: 'item_03',
          patientId: 'usr_patient_01',
          status: AdherenceStatus.missed,
          scheduledAt: '2026-09-28T20:00:00Z',
          loggedAt: '2026-09-28T20:00:00Z',
          notes: 'Shift work delay',
        ),
      ];
    }
  }

  Future<AdherenceLogModel> logDose(String regimenItemId, String status) async {
    try {
      final response = await _apiClient.post(
        '/adherence-logs',
        body: {'regimenItemId': regimenItemId, 'status': status},
      );
      return AdherenceLogModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return AdherenceLogModel(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        regimenItemId: regimenItemId,
        patientId: 'usr_patient_01',
        status: status == 'missed' ? AdherenceStatus.missed : AdherenceStatus.taken,
        scheduledAt: DateTime.now().toIso8601String(),
        loggedAt: DateTime.now().toIso8601String(),
      );
    }
  }
}

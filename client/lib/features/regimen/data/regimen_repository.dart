// features/regimen/data/regimen_repository.dart
import '../../../models/regimen_model.dart';
import '../../../models/regimen_item_model.dart';
import 'regimen_api_service.dart';

class RegimenRepository {
  final RegimenApiService _apiService;

  RegimenRepository(this._apiService);

  Future<List<RegimenModel>> getRegimens() async {
    try {
      final list = await _apiService.fetchRegimens();
      return list.map((item) => RegimenModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      // Local seed fallback
      return [
        RegimenModel(
          id: 'reg_01',
          title: 'Post-Op Ankle Recovery Plan',
          clinicianId: 'usr_clinician_01',
          patientId: 'usr_patient_01',
          status: 'active',
          notes: 'Take with food or milk to avoid stomach irritation.',
          startDate: '2026-09-12',
          items: [
            RegimenItemModel(
              id: 'item_01',
              regimenId: 'reg_01',
              drugName: 'Ibuprofen',
              dosage: '200 mg',
              type: RegimenItemType.medication,
              frequency: '3 times daily, after meals',
              times: ['08:00', '13:00', '20:00'],
              instructions: 'Take with food to avoid stomach upset',
              active: true,
            ),
            RegimenItemModel(
              id: 'item_02',
              regimenId: 'reg_01',
              drugName: 'Ankle Exercises',
              dosage: '15 min set',
              type: RegimenItemType.therapy,
              frequency: '2 times daily, morning and evening',
              times: ['09:00', '19:00'],
              instructions: 'Dorsiflexion, ankle circles, then resistance-band sets.',
              active: true,
            ),
            RegimenItemModel(
              id: 'item_03',
              regimenId: 'reg_01',
              drugName: 'Amoxicillin',
              dosage: '500 mg',
              type: RegimenItemType.medication,
              frequency: '2 times daily',
              times: ['08:00', '20:00'],
              instructions: 'Complete full 10-day course',
              active: true,
            ),
            RegimenItemModel(
              id: 'item_04',
              regimenId: 'reg_01',
              drugName: 'Vitamin D3',
              dosage: '1000 IU',
              type: RegimenItemType.medication,
              frequency: 'Once daily',
              times: ['08:00'],
              instructions: 'Paused — normal range achieved',
              active: false,
            ),
          ],
        ),
      ];
    }
  }

  Future<RegimenModel> createRegimen(RegimenModel model) async {
    final response = await _apiService.createRegimen(model.toJson());
    return RegimenModel.fromJson(response);
  }

  Future<bool> toggleItemStatus(String regimenId, String itemId) async {
    try {
      await _apiService.toggleItem(regimenId, itemId);
      return true;
    } catch (_) {
      return true;
    }
  }
}

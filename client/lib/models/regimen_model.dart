// models/regimen_model.dart
import 'regimen_item_model.dart';

class RegimenModel {
  final String id;
  final String title;
  final String clinicianId;
  final String patientId;
  String status; // 'active', 'paused', 'completed'
  final String notes;
  final String startDate;
  final List<RegimenItemModel> items;

  RegimenModel({
    required this.id,
    required this.title,
    required this.clinicianId,
    required this.patientId,
    required this.status,
    required this.notes,
    required this.startDate,
    required this.items,
  });

  factory RegimenModel.fromJson(Map<String, dynamic> json) {
    return RegimenModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      clinicianId: json['clinicianId'] ?? '',
      patientId: json['patientId'] ?? '',
      status: json['status'] ?? 'active',
      notes: json['notes'] ?? '',
      startDate: json['startDate'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => RegimenItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'clinicianId': clinicianId,
      'patientId': patientId,
      'status': status,
      'notes': notes,
      'startDate': startDate,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

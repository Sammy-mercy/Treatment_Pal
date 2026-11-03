// models/regimen_item_model.dart

enum RegimenItemType { medication, therapy }

class RegimenItemModel {
  final String id;
  final String regimenId;
  final String drugName;
  final String dosage;
  final RegimenItemType type;
  final String frequency;
  final List<String> times;
  final String instructions;
  bool active;

  RegimenItemModel({
    required this.id,
    required this.regimenId,
    required this.drugName,
    required this.dosage,
    required this.type,
    required this.frequency,
    required this.times,
    required this.instructions,
    this.active = true,
  });

  bool get isTherapy => type == RegimenItemType.therapy;
  bool get isMedication => type == RegimenItemType.medication;

  factory RegimenItemModel.fromJson(Map<String, dynamic> json) {
    return RegimenItemModel(
      id: json['id'] ?? '',
      regimenId: json['regimenId'] ?? '',
      drugName: json['drugName'] ?? '',
      dosage: json['dosage'] ?? '',
      type: json['type'] == 'therapy' ? RegimenItemType.therapy : RegimenItemType.medication,
      frequency: json['frequency'] ?? 'Daily',
      times: List<String>.from(json['times'] ?? []),
      instructions: json['instructions'] ?? '',
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'regimenId': regimenId,
      'drugName': drugName,
      'dosage': dosage,
      'type': type == RegimenItemType.therapy ? 'therapy' : 'medication',
      'frequency': frequency,
      'times': times,
      'instructions': instructions,
      'active': active,
    };
  }
}

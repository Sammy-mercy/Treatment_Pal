// models/adherence_log_model.dart

enum AdherenceStatus { taken, missed }

class AdherenceLogModel {
  final String id;
  final String regimenItemId;
  final String patientId;
  final AdherenceStatus status;
  final String scheduledAt;
  final String loggedAt;
  final String? notes;

  AdherenceLogModel({
    required this.id,
    required this.regimenItemId,
    required this.patientId,
    required this.status,
    required this.scheduledAt,
    required this.loggedAt,
    this.notes,
  });

  factory AdherenceLogModel.fromJson(Map<String, dynamic> json) {
    return AdherenceLogModel(
      id: json['id'] ?? '',
      regimenItemId: json['regimenItemId'] ?? '',
      patientId: json['patientId'] ?? '',
      status: json['status'] == 'missed' ? AdherenceStatus.missed : AdherenceStatus.taken,
      scheduledAt: json['scheduledAt'] ?? '',
      loggedAt: json['loggedAt'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'regimenItemId': regimenItemId,
      'patientId': patientId,
      'status': status == AdherenceStatus.missed ? 'missed' : 'taken',
      'scheduledAt': scheduledAt,
      'loggedAt': loggedAt,
      'notes': notes,
    };
  }
}

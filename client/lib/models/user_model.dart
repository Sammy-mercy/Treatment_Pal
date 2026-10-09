// models/user_model.dart

enum UserRole { patient, clinician }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? dob;
  final String? npi;
  final String? specialization;
  final String? assignedClinicianId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.dob,
    this.npi,
    this.specialization,
    this.assignedClinicianId,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] == 'clinician' ? UserRole.clinician : UserRole.patient,
      phone: json['phone'],
      dob: json['dob'],
      npi: json['npi'],
      specialization: json['specialization'],
      assignedClinicianId: json['assignedClinicianId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.clinician ? 'clinician' : 'patient',
      'phone': phone,
      'dob': dob,
      'npi': npi,
      'specialization': specialization,
      'assignedClinicianId': assignedClinicianId,
    };
  }
}

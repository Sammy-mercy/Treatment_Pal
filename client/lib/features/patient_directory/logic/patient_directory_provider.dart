// features/patient_directory/logic/patient_directory_provider.dart
import 'package:flutter/foundation.dart';
import '../data/patient_directory_repository.dart';

class PatientDirectoryProvider extends ChangeNotifier {
  final PatientDirectoryRepository _repository;

  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;

  PatientDirectoryProvider(this._repository) {
    loadPatients();
  }

  List<Map<String, dynamic>> get patients => _patients;
  bool get isLoading => _isLoading;

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();
    _patients = await _repository.getPatients();
    _isLoading = false;
    notifyListeners();
  }
}

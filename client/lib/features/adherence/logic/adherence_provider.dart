// features/adherence/logic/adherence_provider.dart
import 'package:flutter/foundation.dart';
import '../../../models/adherence_log_model.dart';
import '../data/adherence_repository.dart';

class AdherenceProvider extends ChangeNotifier {
  final AdherenceRepository _repository;

  List<AdherenceLogModel> _logs = [];
  bool _isLoading = false;

  AdherenceProvider(this._repository) {
    loadLogs();
  }

  List<AdherenceLogModel> get logs => _logs;
  bool get isLoading => _isLoading;

  int get complianceRate {
    if (_logs.isEmpty) return 92;
    final taken = _logs.where((l) => l.status == AdherenceStatus.taken).length;
    return (taken / _logs.length * 100).round();
  }

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();
    _logs = await _repository.getLogs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logDose(String regimenItemId, String status) async {
    final newLog = await _repository.logDose(regimenItemId, status);
    _logs.insert(0, newLog);
    notifyListeners();
  }
}

// features/regimen/logic/regimen_provider.dart
import 'package:flutter/foundation.dart';
import '../../../models/regimen_model.dart';
import '../../../models/regimen_item_model.dart';
import '../data/regimen_repository.dart';

class RegimenProvider extends ChangeNotifier {
  final RegimenRepository _repository;

  List<RegimenModel> _regimens = [];
  RegimenModel? _selectedRegimen;
  bool _isLoading = false;
  String? _errorMessage;

  RegimenProvider(this._repository) {
    loadRegimens();
  }

  List<RegimenModel> get regimens => _regimens;
  RegimenModel? get selectedRegimen => _selectedRegimen;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<RegimenItemModel> get allItems {
    return _regimens.expand((r) => r.items).toList();
  }

  Future<void> loadRegimens() async {
    _isLoading = true;
    notifyListeners();

    try {
      _regimens = await _repository.getRegimens();
      if (_regimens.isNotEmpty) {
        _selectedRegimen = _regimens.first;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRegimen(String id) {
    _selectedRegimen = _regimens.firstWhere((r) => r.id == id, orElse: () => _regimens.first);
    notifyListeners();
  }

  Future<void> toggleItemActive(String regimenId, String itemId) async {
    final regimen = _regimens.firstWhere((r) => r.id == regimenId);
    final item = regimen.items.firstWhere((i) => i.id == itemId);
    item.active = !item.active;
    notifyListeners();

    await _repository.toggleItemStatus(regimenId, itemId);
  }

  Future<void> addRegimen(RegimenModel newModel) async {
    _regimens.insert(0, newModel);
    notifyListeners();
    try {
      await _repository.createRegimen(newModel);
    } catch (_) {}
  }
}

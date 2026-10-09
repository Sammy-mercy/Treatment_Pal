// features/notifications/logic/notification_provider.dart
import 'package:flutter/foundation.dart';
import '../data/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  List<Map<String, dynamic>> _notifications = [];
  bool _doseReminders = true;
  bool _missedDoseAlerts = true;
  bool _clinicianMessages = true;
  bool _weeklySummary = false;

  NotificationProvider(this._service) {
    loadNotifications();
  }

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !(n['read'] as bool)).length;

  bool get doseReminders => _doseReminders;
  bool get missedDoseAlerts => _missedDoseAlerts;
  bool get clinicianMessages => _clinicianMessages;
  bool get weeklySummary => _weeklySummary;

  Future<void> loadNotifications() async {
    _notifications = await _service.getNotifications();
    notifyListeners();
  }

  void markAllRead() {
    for (var n in _notifications) {
      n['read'] = true;
    }
    notifyListeners();
    _service.markAllRead();
  }

  void toggleDoseReminders(bool val) {
    _doseReminders = val;
    notifyListeners();
  }

  void toggleMissedAlerts(bool val) {
    _missedDoseAlerts = val;
    notifyListeners();
  }

  void toggleMessages(bool val) {
    _clinicianMessages = val;
    notifyListeners();
  }

  void toggleWeeklySummary(bool val) {
    _weeklySummary = val;
    notifyListeners();
  }
}

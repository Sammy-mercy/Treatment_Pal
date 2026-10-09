// features/notifications/data/notification_service.dart
import '../../../core/network/api_client.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final list = await _apiClient.get('/notifications') as List<dynamic>;
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [
        {
          'id': 'n1',
          'title': 'Take Ibuprofen in 30 min',
          'body': 'Scheduled dose at 1:00 PM with food.',
          'time': '12:30 PM',
          'read': false,
        },
        {
          'id': 'n2',
          'title': 'New regimen assigned by Dr. Carter',
          'body': 'Ankle Exercises (15 min set) added to your recovery plan.',
          'time': 'Today · 09:12 AM',
          'read': false,
        },
        {
          'id': 'n3',
          'title': 'Message from Dr. Carter',
          'body': 'How is the ankle feeling after the new set of resistance exercises?',
          'time': 'Today · 08:40 AM',
          'read': true,
        },
      ];
    }
  }

  Future<void> markAllRead() async {
    try {
      await _apiClient.post('/notifications/read-all');
    } catch (_) {}
  }
}

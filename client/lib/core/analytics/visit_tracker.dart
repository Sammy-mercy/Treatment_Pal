import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class VisitTracker {
  static const _visitorKey = 'tp_analytics_visitor_id';

  static Future<void> recordAnonymousVisit(ApiClient apiClient) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      var visitorId = preferences.getString(_visitorKey);
      if (visitorId == null || visitorId.isEmpty) {
        visitorId =
            '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';
        await preferences.setString(_visitorKey, visitorId);
      }
      await apiClient.post('/analytics/visits', body: {'visitorId': visitorId});
    } catch (_) {
      // Analytics must not block app startup when the API or storage is unavailable.
    }
  }
}

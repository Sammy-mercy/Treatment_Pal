import 'package:flutter/foundation.dart';

class Config {
  static const _fromEnv = String.fromEnvironment('API_BASE_URL');

  static String get apiBase {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }
}

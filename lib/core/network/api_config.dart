import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const Duration timeout = Duration(seconds: 15);

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }

    return 'http://localhost:8080/api';
  }

  static String get internalKey {
    const configured = String.fromEnvironment('INTERNAL_KEY');
    return configured;
  }

  static Map<String, Object?> get headers {
    return {
      Headers.contentTypeHeader: Headers.jsonContentType,
      Headers.acceptHeader: Headers.jsonContentType,
      if (internalKey.isNotEmpty) 'X-Internal-Key': internalKey,
    };
  }
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class ApiConfig {
  final Environment environment;
  final String? customBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const ApiConfig({
    this.environment = Environment.development,
    this.customBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
  });

  /// Base URL derived dynamically based on target platform and environment.
  String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    switch (environment) {
      case Environment.development:
        if (!kIsWeb && Platform.isAndroid) {
          // Android emulator maps host localhost to 10.0.2.2
          return 'http://10.0.2.2:5162';
        }
        return 'https://localhost:7291';
      case Environment.staging:
        return 'https://staging-api.wovzostore.com';
      case Environment.production:
        return 'https://api.wovzostore.com';
    }
  }

  /// Whether SSL certificate validation bypass should be enabled for dev certificates.
  bool get allowSelfSignedCertificate =>
      environment == Environment.development && kDebugMode;
}

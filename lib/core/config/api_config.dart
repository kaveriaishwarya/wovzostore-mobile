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

  /// Base URL derived dynamically based on target platform and environment,
  /// or overridden at compile time via `--dart-define=WOVZO_API_URL=https://...`.
  String get baseUrl {
    const compileTimeUrl = String.fromEnvironment('WOVZO_API_URL');
    if (compileTimeUrl.isNotEmpty) {
      return compileTimeUrl;
    }

    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    const compileTimeEnv = String.fromEnvironment('WOVZO_ENV');
    final activeEnv = compileTimeEnv == 'staging'
        ? Environment.staging
        : compileTimeEnv == 'production'
            ? Environment.production
            : environment;

    switch (activeEnv) {
      case Environment.development:
        if (!kIsWeb && Platform.isAndroid) {
          // Default development LAN IP for physical Android device testing
          return 'http://192.168.1.39:5162';
        }
        return 'http://192.168.1.39:5162';
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

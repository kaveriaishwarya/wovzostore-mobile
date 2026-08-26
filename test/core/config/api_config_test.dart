import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/config/api_config.dart';

void main() {
  group('ApiConfig Tests', () {
    test('default configuration uses development environment', () {
      const config = ApiConfig();
      expect(config.environment, Environment.development);
      expect(config.connectTimeout, const Duration(seconds: 15));
      expect(config.receiveTimeout, const Duration(seconds: 15));
      expect(config.sendTimeout, const Duration(seconds: 15));
    });

    test('customBaseUrl overrides default environment baseUrl', () {
      const config = ApiConfig(customBaseUrl: 'https://my-custom-api.com');
      expect(config.baseUrl, 'https://my-custom-api.com');
    });

    test('staging environment returns staging URL', () {
      const config = ApiConfig(environment: Environment.staging);
      expect(config.baseUrl, 'https://staging-api.wovzostore.com');
    });

    test('production environment returns production URL', () {
      const config = ApiConfig(environment: Environment.production);
      expect(config.baseUrl, 'https://api.wovzostore.com');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';

void main() {
  final tStoreSettingsModel = StoreSettingsModel(
    storeName: 'Wovzo Store',
    logoUrl: 'https://example.com/logo.png',
    supportEmail: 'support@example.com',
    supportPhone: '1234567890',
    codEnabled: true,
    minOrderAmountForCod: 100.0,
    defaultCurrency: 'INR',
    freeDeliveryThreshold: 500.0,
    flatDeliveryCharge: 50.0,
    estimatedDeliveryDays: 3,
    servicablePinCodes: '100001,100002',
    returnWindowDays: 7,
    replaceWindowDays: 7,
    returnAllowed: true,
    policyText: 'Return within 7 days',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
  );

  final tStoreSettingsJson = {
    'storeName': 'Wovzo Store',
    'logoUrl': 'https://example.com/logo.png',
    'supportEmail': 'support@example.com',
    'supportPhone': '1234567890',
    'codEnabled': true,
    'minOrderAmountForCod': 100.0,
    'defaultCurrency': 'INR',
    'freeDeliveryThreshold': 500.0,
    'flatDeliveryCharge': 50.0,
    'estimatedDeliveryDays': 3,
    'servicablePinCodes': '100001,100002',
    'returnWindowDays': 7,
    'replaceWindowDays': 7,
    'returnAllowed': true,
    'policyText': 'Return within 7 days',
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-02T00:00:00.000Z',
  };

  test('fromJson should return a valid model', () {
    final result = StoreSettingsModel.fromJson(tStoreSettingsJson);
    expect(result.storeName, tStoreSettingsModel.storeName);
    expect(result.logoUrl, tStoreSettingsModel.logoUrl);
    expect(result.codEnabled, tStoreSettingsModel.codEnabled);
    expect(result.createdAt, tStoreSettingsModel.createdAt);
  });

  test('toJson should return a JSON map containing proper data', () {
    final result = tStoreSettingsModel.toJson();
    final expectedMap = {
      'storeName': 'Wovzo Store',
      'logoUrl': 'https://example.com/logo.png',
      'supportEmail': 'support@example.com',
      'supportPhone': '1234567890',
      'codEnabled': true,
      'minOrderAmountForCod': 100.0,
      'defaultCurrency': 'INR',
      'freeDeliveryThreshold': 500.0,
      'flatDeliveryCharge': 50.0,
      'estimatedDeliveryDays': 3,
      'servicablePinCodes': '100001,100002',
      'returnWindowDays': 7,
      'replaceWindowDays': 7,
      'returnAllowed': true,
      'policyText': 'Return within 7 days',
    };
    expect(result, expectedMap);
  });
}

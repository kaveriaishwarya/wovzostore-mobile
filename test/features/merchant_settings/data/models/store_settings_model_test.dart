import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';

void main() {
  group('StoreSettingsModel GST & Bank Serialization Tests', () {
    test('fromJson & toJson correctly map GST and bank fields', () {
      final json = {
        'storeName': 'Wovzo Enterprise Store',
        'logoUrl': 'https://img.wovzo.com/logo.png',
        'supportEmail': 'support@wovzo.com',
        'supportPhone': '9876543210',
        'codEnabled': true,
        'minOrderAmountForCod': 100.0,
        'defaultCurrency': 'INR',
        'freeDeliveryThreshold': 500.0,
        'flatDeliveryCharge': 50.0,
        'estimatedDeliveryDays': 3,
        'servicablePinCodes': '400001,400002',
        'returnWindowDays': 7,
        'replaceWindowDays': 7,
        'returnAllowed': true,
        'policyText': 'Standard returns',
        'gstin': '27AAAAA0000A1Z5',
        'legalName': 'Wovzo Enterprise Pvt Ltd',
        'panNumber': 'AAAAA0000A',
        'stateCode': '27',
        'stateName': 'Maharashtra',
        'addressLine1': '123 Tech Park',
        'addressLine2': 'Suite 401',
        'city': 'Mumbai',
        'pinCode': '400051',
        'bankName': 'HDFC Bank',
        'bankAccountNumber': '502000123456',
        'bankIfscCode': 'HDFC0001234',
        'invoicePrefix': 'INV-',
        'createdAt': '2026-08-29T10:00:00.000Z',
        'updatedAt': '2026-08-29T12:00:00.000Z',
      };

      final model = StoreSettingsModel.fromJson(json);

      expect(model.storeName, 'Wovzo Enterprise Store');
      expect(model.gstin, '27AAAAA0000A1Z5');
      expect(model.legalName, 'Wovzo Enterprise Pvt Ltd');
      expect(model.panNumber, 'AAAAA0000A');
      expect(model.stateCode, '27');
      expect(model.stateName, 'Maharashtra');
      expect(model.addressLine1, '123 Tech Park');
      expect(model.bankName, 'HDFC Bank');
      expect(model.bankAccountNumber, '502000123456');
      expect(model.bankIfscCode, 'HDFC0001234');
      expect(model.invoicePrefix, 'INV-');

      final serialized = model.toJson();
      expect(serialized['gstin'], '27AAAAA0000A1Z5');
      expect(serialized['legalName'], 'Wovzo Enterprise Pvt Ltd');
      expect(serialized['bankName'], 'HDFC Bank');
      expect(serialized['invoicePrefix'], 'INV-');
    });

    test('fromJson handles null GST fields gracefully', () {
      final json = {
        'storeName': 'Basic Store',
        'codEnabled': false,
        'minOrderAmountForCod': 0.0,
        'defaultCurrency': 'INR',
        'flatDeliveryCharge': 0.0,
        'estimatedDeliveryDays': 2,
        'returnWindowDays': 0,
        'replaceWindowDays': 0,
        'returnAllowed': false,
        'createdAt': '2026-08-29T10:00:00.000Z',
      };

      final model = StoreSettingsModel.fromJson(json);

      expect(model.storeName, 'Basic Store');
      expect(model.gstin, isNull);
      expect(model.legalName, isNull);
      expect(model.invoicePrefix, 'INV-');
    });
  });
}

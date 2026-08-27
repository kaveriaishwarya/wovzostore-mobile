import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_details_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_model.dart';

void main() {
  group('Merchant Customer Models Tests', () {
    test('MerchantCustomerModel parses JSON and serializes correctly', () {
      final json = {
        'id': 'cust-101',
        'fullName': 'Rahul Sharma',
        'email': 'rahul@example.com',
        'phoneNumber': '9876543210',
        'status': true,
        'createdAt': '2026-08-28T00:00:00.000Z',
        'ordersCount': 5,
        'totalSpent': 12500.0,
      };

      final model = MerchantCustomerModel.fromJson(json);
      expect(model.id, 'cust-101');
      expect(model.fullName, 'Rahul Sharma');
      expect(model.ordersCount, 5);
      expect(model.totalSpent, 12500.0);

      final outputJson = model.toJson();
      expect(outputJson['fullName'], 'Rahul Sharma');
      expect(outputJson['totalSpent'], 12500.0);
    });

    test('MerchantCustomerDetailsModel parses JSON and serializes correctly', () {
      final json = {
        'id': 'cust-101',
        'fullName': 'Rahul Sharma',
        'email': 'rahul@example.com',
        'phoneNumber': '9876543210',
        'isEmailVerified': true,
        'isPhoneVerified': true,
        'dateOfBirth': '1995-05-15T00:00:00.000Z',
        'status': true,
        'createdAt': '2026-08-28T00:00:00.000Z',
        'defaultAddress': '123 Main Street, Bangalore',
        'ordersCount': 5,
        'totalSpent': 12500.0,
      };

      final details = MerchantCustomerDetailsModel.fromJson(json);
      expect(details.id, 'cust-101');
      expect(details.isEmailVerified, isTrue);
      expect(details.defaultAddress, '123 Main Street, Bangalore');

      final outputJson = details.toJson();
      expect(outputJson['defaultAddress'], '123 Main Street, Bangalore');
    });
  });
}

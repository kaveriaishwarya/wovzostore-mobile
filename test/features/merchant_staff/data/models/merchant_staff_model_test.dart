import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/merchant_staff_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/create_staff_request_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/update_staff_request_model.dart';

void main() {
  group('MerchantStaffModel Serialization', () {
    final sampleJson = {
      'id': 'staff-123',
      'fullName': 'Ramesh Kumar',
      'email': 'ramesh@wovzo.com',
      'phoneNumber': '9876543210',
      'role': 'StoreManager',
      'isActive': true,
      'createdAt': '2026-08-28T01:00:00.000Z',
    };

    test('should parse MerchantStaffModel from valid JSON', () {
      final model = MerchantStaffModel.fromJson(sampleJson);

      expect(model.id, equals('staff-123'));
      expect(model.fullName, equals('Ramesh Kumar'));
      expect(model.email, equals('ramesh@wovzo.com'));
      expect(model.phoneNumber, equals('9876543210'));
      expect(model.role, equals('StoreManager'));
      expect(model.isActive, isTrue);
      expect(model.createdAt, equals(DateTime.parse('2026-08-28T01:00:00.000Z')));
    });

    test('should convert MerchantStaffModel to JSON accurately', () {
      final model = MerchantStaffModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], equals('staff-123'));
      expect(json['fullName'], equals('Ramesh Kumar'));
      expect(json['email'], equals('ramesh@wovzo.com'));
      expect(json['role'], equals('StoreManager'));
      expect(json['isActive'], isTrue);
    });

    test('CreateStaffRequestModel should serialize to JSON correctly', () {
      const request = CreateStaffRequestModel(
        fullName: 'Anita Sharma',
        email: 'anita@wovzo.com',
        phoneNumber: '9876543211',
        role: 'Support',
        password: 'Password@123',
      );

      final json = request.toJson();
      expect(json['fullName'], equals('Anita Sharma'));
      expect(json['email'], equals('anita@wovzo.com'));
      expect(json['role'], equals('Support'));
      expect(json['password'], equals('Password@123'));
    });

    test('UpdateStaffRequestModel should serialize to JSON correctly', () {
      const request = UpdateStaffRequestModel(
        fullName: 'Anita Verma',
        phoneNumber: '9876543299',
        role: 'Admin',
      );

      final json = request.toJson();
      expect(json['fullName'], equals('Anita Verma'));
      expect(json['phoneNumber'], equals('9876543299'));
      expect(json['role'], equals('Admin'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/otp_request_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/otp_verify_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/user_model.dart';

void main() {
  group('Auth Data Models Tests', () {
    test('OtpRequestModel toJson converts correctly', () {
      const model = OtpRequestModel(phone: '9876543210');
      expect(model.toJson(), {'phone': '9876543210'});
    });

    test('OtpSentResponseModel.fromJson parses JSON correctly', () {
      final json = {
        'message': 'OTP sent successfully.',
        'expiresInSeconds': 300,
        'resendCooldownSeconds': 60,
      };

      final response = OtpSentResponseModel.fromJson(json);

      expect(response.message, 'OTP sent successfully.');
      expect(response.expiresInSeconds, 300);
      expect(response.resendCooldownSeconds, 60);
      expect(response.toJson(), json);
    });

    test('OtpVerifyRequestModel toJson converts correctly', () {
      const model = OtpVerifyRequestModel(phone: '9876543210', otp: '123456');
      expect(model.toJson(), {
        'phone': '9876543210',
        'otp': '123456',
      });
    });

    test('UserModel.fromJson parses complete and nullable fields correctly', () {
      final json = {
        'userId': 'usr_123',
        'role': 'Customer',
        'phoneNumber': '+919876543210',
        'email': 'customer@wovzo.com',
        'customerId': 'cust_456',
        'displayName': 'Jane Doe',
        'profileImageUrl': 'https://example.com/avatar.jpg',
        'isActive': true,
        'dateOfBirth': '1995-05-15',
      };

      final user = UserModel.fromJson(json);

      expect(user.userId, 'usr_123');
      expect(user.role, 'Customer');
      expect(user.phoneNumber, '+919876543210');
      expect(user.email, 'customer@wovzo.com');
      expect(user.customerId, 'cust_456');
      expect(user.displayName, 'Jane Doe');
      expect(user.profileImageUrl, 'https://example.com/avatar.jpg');
      expect(user.isActive, isTrue);
      expect(user.dateOfBirth, '1995-05-15');
    });

    test('AuthResponseModel.fromJson parses full authentication response', () {
      final json = {
        'accessToken': 'jwt_access_token',
        'accessTokenExpiresAt': '2026-08-26T22:00:00Z',
        'refreshToken': 'raw_refresh_token',
        'refreshTokenExpiresAt': '2026-09-26T22:00:00Z',
        'isNewUser': true,
        'user': {
          'userId': 'usr_123',
          'role': 'Customer',
          'phoneNumber': '9876543210',
          'isActive': true,
        },
      };

      final authResponse = AuthResponseModel.fromJson(json);

      expect(authResponse.accessToken, 'jwt_access_token');
      expect(authResponse.refreshToken, 'raw_refresh_token');
      expect(authResponse.isNewUser, isTrue);
      expect(authResponse.user.userId, 'usr_123');
      expect(authResponse.user.role, 'Customer');
    });
  });
}

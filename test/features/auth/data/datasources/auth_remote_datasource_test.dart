import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

void main() {
  group('AuthRemoteDataSource Tests', () {
    late Dio dio;
    late AuthRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://localhost:7291'));
      dataSource = AuthRemoteDataSourceImpl(dio: dio);
    });

    test('requestOtp sends POST /api/v1/auth/otp/request with phone body', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'POST');
          expect(options.path, '/api/v1/auth/otp/request');
          expect(options.data, {'phone': '9876543210'});

          return ResponseBody.fromString(
            '{"message": "OTP sent successfully.", "expiresInSeconds": 300, "resendCooldownSeconds": 60}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final result = await dataSource.requestOtp('9876543210');
      expect(result.expiresInSeconds, 300);
      expect(result.resendCooldownSeconds, 60);
    });

    test('verifyOtp sends POST /api/v1/auth/otp/verify with phone and otp', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'POST');
          expect(options.path, '/api/v1/auth/otp/verify');
          expect(options.data, {'phone': '9876543210', 'otp': '123456'});

          return ResponseBody.fromString(
            '{"accessToken": "access_123", "accessTokenExpiresAt": "2026-08-26T22:00:00Z", "refreshToken": "refresh_456", "refreshTokenExpiresAt": "2026-09-26T22:00:00Z", "isNewUser": false, "user": {"userId": "u1", "role": "Customer"}}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final result = await dataSource.verifyOtp('9876543210', '123456');
      expect(result.accessToken, 'access_123');
      expect(result.refreshToken, 'refresh_456');
      expect(result.user.userId, 'u1');
    });

    test('getMe sends GET /api/v1/auth/me', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/auth/me');

          return ResponseBody.fromString(
            '{"userId": "u1", "role": "Customer", "phoneNumber": "9876543210", "isActive": true}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final user = await dataSource.getMe();
      expect(user.userId, 'u1');
      expect(user.role, 'Customer');
    });

    test('logout sends POST /api/v1/auth/logout with refreshToken', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'POST');
          expect(options.path, '/api/v1/auth/logout');
          expect(options.data, {'refreshToken': 'refresh_token_xyz'});

          return ResponseBody.fromString(
            '{"message": "Logged out successfully."}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      await expectLater(
        dataSource.logout('refresh_token_xyz'),
        completes,
      );
    });
  });
}

class _MockHttpAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

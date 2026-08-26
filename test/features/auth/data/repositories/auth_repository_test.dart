import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:wovzo_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/otp_request_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/user_model.dart';
import 'package:wovzo_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wovzo_mobile/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldThrowDioException = false;
  int dioStatusCode = 400;

  @override
  Future<OtpSentResponseModel> requestOtp(String phone) async {
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/otp/request'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/otp/request'),
          statusCode: dioStatusCode,
          data: {'detail': 'Invalid phone number.'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return const OtpSentResponseModel(
      message: 'OTP sent successfully.',
      expiresInSeconds: 300,
      resendCooldownSeconds: 60,
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp(String phone, String otp) async {
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/otp/verify'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/otp/verify'),
          statusCode: dioStatusCode,
          data: {'detail': 'Invalid or expired OTP.'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return const AuthResponseModel(
      accessToken: 'access_123',
      accessTokenExpiresAt: '2026-08-26T22:00:00Z',
      refreshToken: 'refresh_456',
      refreshTokenExpiresAt: '2026-09-26T22:00:00Z',
      isNewUser: false,
      user: UserModel(userId: 'u1', role: 'Customer'),
    );
  }

  @override
  Future<UserModel> getMe() async {
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          statusCode: 401,
          data: {'detail': 'Unauthorized.'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return const UserModel(userId: 'u1', role: 'Customer');
  }

  @override
  Future<void> logout(String refreshToken) async {
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/logout'),
        type: DioExceptionType.connectionError,
      );
    }
  }
}

void main() {
  group('AuthRepositoryImpl Tests', () {
    late FakeAuthRemoteDataSource fakeDataSource;
    late AuthRepository repository;

    setUp(() {
      fakeDataSource = FakeAuthRemoteDataSource();
      repository = AuthRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('requestOtp succeeds and returns OtpSentResponseModel', () async {
      final result = await repository.requestOtp('9876543210');
      expect(result.expiresInSeconds, 300);
    });

    test('requestOtp maps DioException to ApiValidationException', () async {
      fakeDataSource.shouldThrowDioException = true;
      fakeDataSource.dioStatusCode = 400;

      expect(
        () => repository.requestOtp('invalid'),
        throwsA(isA<ApiValidationException>()),
      );
    });

    test('verifyOtp succeeds and returns AuthResponseModel', () async {
      final result = await repository.verifyOtp('9876543210', '123456');
      expect(result.accessToken, 'access_123');
      expect(result.user.userId, 'u1');
    });

    test('verifyOtp maps 400 error to ApiValidationException', () async {
      fakeDataSource.shouldThrowDioException = true;
      fakeDataSource.dioStatusCode = 400;

      expect(
        () => repository.verifyOtp('9876543210', '000000'),
        throwsA(isA<ApiValidationException>()),
      );
    });

    test('getCurrentUser maps 401 error to ApiUnauthorizedException', () async {
      fakeDataSource.shouldThrowDioException = true;

      expect(
        () => repository.getCurrentUser(),
        throwsA(isA<ApiUnauthorizedException>()),
      );
    });

    test('logout maps connection error to ApiNetworkException', () async {
      fakeDataSource.shouldThrowDioException = true;

      expect(
        () => repository.logout('token_xyz'),
        throwsA(isA<ApiNetworkException>()),
      );
    });
  });
}

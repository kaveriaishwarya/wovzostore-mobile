import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/otp_request_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/user_model.dart';
import 'package:wovzo_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_state.dart';

import '../../../../core/storage/secure_storage_service_test.dart';

class MockAuthRepository implements AuthRepository {
  bool requestOtpShouldFail = false;
  bool verifyOtpShouldFail = false;
  bool getMeShouldFail = false;
  bool logoutShouldFail = false;

  @override
  Future<OtpSentResponseModel> requestOtp(String phone) async {
    if (requestOtpShouldFail) {
      throw const ApiValidationException(message: 'Invalid phone number.');
    }
    return const OtpSentResponseModel(
      message: 'OTP sent successfully.',
      expiresInSeconds: 300,
      resendCooldownSeconds: 60,
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp(String phone, String otp) async {
    if (verifyOtpShouldFail) {
      throw const ApiValidationException(message: 'Invalid OTP code.');
    }
    return const AuthResponseModel(
      accessToken: 'access_jwt_123',
      accessTokenExpiresAt: '2026-08-26T22:00:00Z',
      refreshToken: 'refresh_raw_456',
      refreshTokenExpiresAt: '2026-09-26T22:00:00Z',
      isNewUser: false,
      user: UserModel(userId: 'usr_1', role: 'Customer'),
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (getMeShouldFail) {
      throw const ApiUnauthorizedException(message: 'Token expired.');
    }
    return const UserModel(userId: 'usr_1', role: 'Customer', displayName: 'John Customer');
  }

  @override
  Future<void> logout(String refreshToken) async {
    if (logoutShouldFail) {
      throw const ApiNetworkException(message: 'Network offline.');
    }
  }
}

void main() {
  group('AuthCubit Tests', () {
    late MockAuthRepository repository;
    late MemorySecureStorageService storage;
    late AuthCubit cubit;

    setUp(() {
      repository = MockAuthRepository();
      storage = MemorySecureStorageService();
      cubit = AuthCubit(repository: repository, secureStorage: storage);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is AuthState.initial', () {
      expect(cubit.state.status, AuthStatus.initial);
    });

    test('restoreSession with no tokens emits checkingSession then unauthenticated', () async {
      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.restoreSession();
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, AuthStatus.checkingSession);
      expect(states[1].status, AuthStatus.unauthenticated);
    });

    test('restoreSession with valid tokens emits checkingSession then authenticated', () async {
      await storage.saveTokens(accessToken: 'token_a', refreshToken: 'token_r');

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.restoreSession();
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, AuthStatus.checkingSession);
      expect(states[1].status, AuthStatus.authenticated);
      expect(states[1].user?.displayName, 'John Customer');
    });

    test('restoreSession with failing /me clears tokens and emits unauthenticated', () async {
      await storage.saveTokens(accessToken: 'invalid_a', refreshToken: 'invalid_r');
      repository.getMeShouldFail = true;

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.restoreSession();
      await Future.delayed(Duration.zero);

      expect(states.last.status, AuthStatus.unauthenticated);
      expect(await storage.getAccessToken(), null);
      expect(await storage.getRefreshToken(), null);
    });

    test('requestOtp emits loading then otpSent', () async {
      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.requestOtp('9876543210');
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, AuthStatus.loading);
      expect(states[1].status, AuthStatus.otpSent);
      expect(states[1].phone, '9876543210');
      expect(states[1].expiresInSeconds, 300);
      expect(states[1].resendCooldownSeconds, 60);
    });

    test('requestOtp error emits loading then error state', () async {
      repository.requestOtpShouldFail = true;

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.requestOtp('invalid');
      await Future.delayed(Duration.zero);

      expect(states.last.status, AuthStatus.error);
      expect(states.last.errorMessage, 'Invalid phone number.');
    });

    test('verifyOtp persists tokens and emits authenticated state', () async {
      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.verifyOtp('9876543210', '123456');
      await Future.delayed(Duration.zero);

      expect(await storage.getAccessToken(), 'access_jwt_123');
      expect(await storage.getRefreshToken(), 'refresh_raw_456');
      expect(states.last.status, AuthStatus.authenticated);
      expect(states.last.user?.userId, 'usr_1');
    });

    test('logout deletes local tokens even if backend logout fails', () async {
      await storage.saveTokens(accessToken: 'token_a', refreshToken: 'token_r');
      repository.logoutShouldFail = true;

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      await cubit.logout();
      await Future.delayed(Duration.zero);

      expect(await storage.getAccessToken(), null);
      expect(await storage.getRefreshToken(), null);
      expect(states.last.status, AuthStatus.unauthenticated);
    });
  });
}

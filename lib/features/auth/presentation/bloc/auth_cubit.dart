import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final SecureStorageService _secureStorage;

  AuthCubit({
    required AuthRepository repository,
    required SecureStorageService secureStorage,
  })  : _repository = repository,
        _secureStorage = secureStorage,
        super(const AuthState.initial());

  /// Restores authentication session on app startup.
  Future<void> restoreSession() async {
    emit(const AuthState.checkingSession());

    try {
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (accessToken == null || accessToken.isEmpty || refreshToken == null || refreshToken.isEmpty) {
        emit(const AuthState.unauthenticated());
        return;
      }

      final user = await _repository.getCurrentUser();
      emit(AuthState.authenticated(user));
    } catch (_) {
      // Clear invalid credentials and emit unauthenticated state
      await _secureStorage.deleteTokens();
      emit(const AuthState.unauthenticated());
    }
  }

  /// Requests a 6-digit OTP for the given 10-digit phone number.
  Future<void> requestOtp(String phone) async {
    emit(const AuthState.loading());

    try {
      final response = await _repository.requestOtp(phone);
      emit(AuthState.otpSent(
        phone: phone,
        message: response.message,
        expiresInSeconds: response.expiresInSeconds,
        resendCooldownSeconds: response.resendCooldownSeconds,
      ));
    } on ApiException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Verifies the OTP code, persists tokens, and establishes authenticated session.
  Future<void> verifyOtp(String phone, String otp) async {
    emit(const AuthState.loading());

    try {
      final authResponse = await _repository.verifyOtp(phone, otp);

      // Persist access and refresh tokens securely
      await _secureStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      // Fetch authoritative current user profile
      try {
        final currentUser = await _repository.getCurrentUser();
        emit(AuthState.authenticated(currentUser));
      } catch (_) {
        // Fallback to user contained in auth response if /me fails transiently
        emit(AuthState.authenticated(authResponse.user));
      }
    } on ApiException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Updates the authenticated user's profile full name.
  Future<void> updateProfile(String fullName) async {
    try {
      await _repository.updateProfile(fullName);
      final updatedUser = await _repository.getCurrentUser();
      emit(AuthState.authenticated(updatedUser));
    } catch (_) {
      rethrow;
    }
  }

  /// Logs out the user, revokes refresh token server-side, and clears local storage.
  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _repository.logout(refreshToken);
      }
    } catch (_) {
      // Ignore network failures during logout — local tokens MUST still be deleted
    } finally {
      await _secureStorage.deleteTokens();
      emit(const AuthState.unauthenticated());
    }
  }
}

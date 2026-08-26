import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

enum AuthStatus {
  initial,
  checkingSession,
  unauthenticated,
  otpSent,
  loading,
  authenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? phone;
  final String? message;
  final int? expiresInSeconds;
  final int? resendCooldownSeconds;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phone,
    this.message,
    this.expiresInSeconds,
    this.resendCooldownSeconds,
    this.errorMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.checkingSession() : this(status: AuthStatus.checkingSession);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.otpSent({
    required String phone,
    required String message,
    required int expiresInSeconds,
    required int resendCooldownSeconds,
  }) : this(
          status: AuthStatus.otpSent,
          phone: phone,
          message: message,
          expiresInSeconds: expiresInSeconds,
          resendCooldownSeconds: resendCooldownSeconds,
        );

  const AuthState.authenticated(UserModel user)
      : this(
          status: AuthStatus.authenticated,
          user: user,
        );

  const AuthState.error(String message)
      : this(
          status: AuthStatus.error,
          errorMessage: message,
        );

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? phone,
    String? message,
    int? expiresInSeconds,
    int? resendCooldownSeconds,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phone: phone ?? this.phone,
      message: message ?? this.message,
      expiresInSeconds: expiresInSeconds ?? this.expiresInSeconds,
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isCheckingSession => status == AuthStatus.checkingSession;
  bool get isOtpSent => status == AuthStatus.otpSent;
  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;

  @override
  List<Object?> get props => [
        status,
        user,
        phone,
        message,
        expiresInSeconds,
        resendCooldownSeconds,
        errorMessage,
      ];
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/otp_request_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/user_model.dart';
import 'package:wovzo_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wovzo_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:wovzo_mobile/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:wovzo_mobile/features/home/presentation/screens/home_placeholder_screen.dart';

import '../../../../core/storage/secure_storage_service_test.dart';

class MockAuthRepository implements AuthRepository {
  bool requestOtpCalled = false;
  bool verifyOtpCalled = false;
  String? lastPhone;
  String? lastOtp;

  @override
  Future<OtpSentResponseModel> requestOtp(String phone) async {
    requestOtpCalled = true;
    lastPhone = phone;
    return const OtpSentResponseModel(
      message: 'OTP sent successfully.',
      expiresInSeconds: 300,
      resendCooldownSeconds: 60,
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp(String phone, String otp) async {
    verifyOtpCalled = true;
    lastPhone = phone;
    lastOtp = otp;
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
  Future<UserModel> getCurrentUser() async {
    return const UserModel(userId: 'u1', role: 'Customer');
  }

  @override
  Future<void> logout(String refreshToken) async {}
}

void main() {
  group('Auth UI Screen Tests', () {
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

    Widget makeTestableWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: child,
        ),
      );
    }

    testWidgets('LoginScreen renders Wovzo branding, Sign in header, Enter Email or Phone input, and Get OTP button', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));

      expect(find.text('Wovzo'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Start managing your store by signing in'), findsOneWidget);
      expect(find.text('Enter Email or Phone'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Get OTP'), findsOneWidget);
      expect(find.text('New here? '), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('LoginScreen toggles between Sign in and Sign Up modes', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));

      // Initially Sign in mode
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Start managing your store by signing in'), findsOneWidget);

      // Tap Sign Up toggle link
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Switches to Sign Up mode
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Create an account to get started'), findsOneWidget);
      expect(find.text('Have an account? '), findsOneWidget);

      // Tap Sign in toggle link
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      // Switches back to Sign in mode
      expect(find.text('Start managing your store by signing in'), findsOneWidget);
    });

    testWidgets('LoginScreen shows validation error for short phone number', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.text('Get OTP'));
      await tester.pump();

      expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
      expect(repository.requestOtpCalled, isFalse);
    });

    testWidgets('LoginScreen submits requestOtp on valid 10-digit number', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.tap(find.text('Get OTP'));
      await tester.pumpAndSettle();

      expect(repository.requestOtpCalled, isTrue);
      expect(repository.lastPhone, '9876543210');
    });

    testWidgets('OtpVerificationScreen renders 6 inputs and Verify button', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const OtpVerificationScreen(phone: '9876543210', resendCooldownSeconds: 60),
      ));

      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.text('Enter the 6-digit code sent to +91 9876543210'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
      expect(find.text('Verify & Proceed'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen triggers verifyOtp when 6 digits entered', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const OtpVerificationScreen(phone: '9876543210', resendCooldownSeconds: 60),
      ));

      final textFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
      }
      await tester.pump();

      await tester.tap(find.text('Verify & Proceed'));
      await tester.pumpAndSettle();

      expect(repository.verifyOtpCalled, isTrue);
      expect(repository.lastPhone, '9876543210');
      expect(repository.lastOtp, '123456');
    });

    testWidgets('HomePlaceholderScreen renders welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePlaceholderScreen()));

      expect(find.text('Welcome to Wovzo Store'), findsOneWidget);
      expect(find.text('You are successfully authenticated.'), findsOneWidget);
    });
  });
}

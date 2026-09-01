import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/otp_request_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/user_model.dart';
import 'package:wovzo_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wovzo_mobile/features/auth/presentation/screens/business_onboarding_screen.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';
import 'package:wovzo_mobile/features/merchant_settings/domain/repositories/merchant_settings_repository.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/cubit/merchant_settings_cubit.dart';

import '../../../../core/storage/secure_storage_service_test.dart';

class MockAuthRepository implements AuthRepository {
  bool updateProfileCalled = false;
  String? lastFullName;
  bool shouldFailUpdateProfile = false;

  @override
  Future<OtpSentResponseModel> requestOtp(String phone) async {
    return const OtpSentResponseModel(
      message: 'OTP sent successfully.',
      expiresInSeconds: 300,
      resendCooldownSeconds: 60,
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp(String phone, String otp) async {
    return const AuthResponseModel(
      accessToken: 'access_123',
      accessTokenExpiresAt: '2026-08-26T22:00:00Z',
      refreshToken: 'refresh_456',
      refreshTokenExpiresAt: '2026-09-26T22:00:00Z',
      isNewUser: false,
      user: UserModel(userId: 'u1', role: 'SuperAdmin'),
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    return UserModel(userId: 'u1', role: 'SuperAdmin', displayName: lastFullName ?? 'John Doe');
  }

  @override
  Future<void> updateProfile(String fullName) async {
    updateProfileCalled = true;
    lastFullName = fullName;
    if (shouldFailUpdateProfile) {
      throw Exception('Failed to update profile');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {}
}

class MockMerchantSettingsRepository implements MerchantSettingsRepository {
  bool updateStoreSettingsCalled = false;
  StoreSettingsModel? lastSettings;
  bool shouldFailUpdateSettings = false;

  @override
  Future<StoreSettingsModel> getStoreSettings() async {
    return StoreSettingsModel(
      storeName: 'Test Store',
      codEnabled: false,
      minOrderAmountForCod: 0,
      defaultCurrency: 'INR',
      flatDeliveryCharge: 0,
      estimatedDeliveryDays: 0,
      returnWindowDays: 0,
      replaceWindowDays: 0,
      returnAllowed: false,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) async {
    updateStoreSettingsCalled = true;
    lastSettings = settings;
    if (shouldFailUpdateSettings) {
      throw Exception('Failed to update store settings');
    }
    return settings;
  }
}

void main() {
  group('BusinessOnboardingScreen Widget Tests', () {
    late MockAuthRepository authRepository;
    late MockMerchantSettingsRepository settingsRepository;
    late MemorySecureStorageService storage;
    late AuthCubit authCubit;
    late MerchantSettingsCubit settingsCubit;

    setUp(() {
      authRepository = MockAuthRepository();
      settingsRepository = MockMerchantSettingsRepository();
      storage = MemorySecureStorageService();
      authCubit = AuthCubit(repository: authRepository, secureStorage: storage);
      settingsCubit = MerchantSettingsCubit(repository: settingsRepository);
    });

    tearDown(() {
      authCubit.close();
      settingsCubit.close();
    });

    Widget makeTestableWidget({VoidCallback? onSuccess}) {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<MerchantSettingsCubit>.value(value: settingsCubit),
          ],
          child: BusinessOnboardingScreen(onSuccess: onSuccess),
        ),
      );
    }

    testWidgets('1. Screen, header and required fields render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text("Let’s begin to set you up!"), findsOneWidget);
      expect(find.text("Please add your business information to get started"), findsOneWidget);
      expect(find.text('Your name *'), findsOneWidget);
      expect(find.text('Business Name *'), findsOneWidget);
      expect(find.text('Business Category'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('What do you want to do first?'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('2. INR (₹) is default currency', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('INR (₹)'), findsOneWidget);
    });

    testWidgets('3. Category picker dropdown allows selection', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.text('Fashion & Apparel'), findsOneWidget);

      await tester.tap(find.text('Fashion & Apparel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Electronics & Gadgets').last);
      await tester.pumpAndSettle();

      expect(find.text('Electronics & Gadgets'), findsOneWidget);
    });

    testWidgets('4. Intent selection works', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.text("Not sure — I’ll explore both"), findsOneWidget);

      await tester.tap(find.text('Create invoices'));
      await tester.pumpAndSettle();

      expect(find.text('Create invoices'), findsOneWidget);
    });

    testWidgets('5. Shows validation errors when required fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your business name'), findsOneWidget);
      expect(authRepository.updateProfileCalled, isFalse);
      expect(settingsRepository.updateStoreSettingsCalled, isFalse);
    });

    testWidgets('6. Successful submission calls profile update and store update', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool successCalled = false;
      await tester.pumpWidget(makeTestableWidget(onSuccess: () {
        successCalled = true;
      }));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Merchant');
      await tester.enterText(textFields.at(1), 'Wovzo Store');

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pump();
      await tester.pump();

      expect(authRepository.updateProfileCalled, isTrue);
      expect(authRepository.lastFullName, 'John Merchant');
      expect(settingsRepository.updateStoreSettingsCalled, isTrue);
      expect(settingsRepository.lastSettings?.storeName, 'Wovzo Store');
      expect(settingsRepository.lastSettings?.defaultCurrency, 'INR');
      expect(successCalled, isTrue);
    });

    testWidgets('7. API failure keeps user on screen and preserves entered values', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      authRepository.shouldFailUpdateProfile = true;

      await tester.pumpWidget(makeTestableWidget());

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Merchant');
      await tester.enterText(textFields.at(1), 'Wovzo Store');

      await tester.ensureVisible(find.text('Register'));
      await tester.tap(find.text('Register'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Failed to update profile'), findsOneWidget);
      expect(find.text('John Merchant'), findsOneWidget);
      expect(find.text('Wovzo Store'), findsOneWidget);
    });
  });
}

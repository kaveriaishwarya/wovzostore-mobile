import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';
import 'package:wovzo_mobile/features/merchant_settings/domain/repositories/merchant_settings_repository.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/cubit/merchant_settings_cubit.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/screens/merchant_settings_screen.dart';

class FakeMerchantSettingsRepository implements MerchantSettingsRepository {
  bool shouldFailGet = false;
  bool shouldFailUpdate = false;
  int getCallsCount = 0;
  int updateCallsCount = 0;
  Completer<StoreSettingsModel>? getCompleter;
  Completer<StoreSettingsModel>? updateCompleter;

  StoreSettingsModel currentSettings = StoreSettingsModel(
    storeName: 'Original Store Name',
    logoUrl: 'https://example.com/logo.png',
    supportEmail: 'support@wovzo.com',
    supportPhone: '9876543210',
    codEnabled: true,
    minOrderAmountForCod: 150.0,
    defaultCurrency: 'INR',
    freeDeliveryThreshold: 499.0,
    flatDeliveryCharge: 40.0,
    estimatedDeliveryDays: 4,
    servicablePinCodes: '110001, 110002',
    returnWindowDays: 7,
    replaceWindowDays: 7,
    returnAllowed: true,
    policyText: 'Standard return policy text',
    createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
    updatedAt: DateTime.parse('2026-01-02T00:00:00.000Z'),
  );

  @override
  Future<StoreSettingsModel> getStoreSettings() async {
    getCallsCount++;
    if (getCompleter != null) {
      return getCompleter!.future;
    }
    if (shouldFailGet) {
      throw Exception('Failed to load store settings from server');
    }
    return currentSettings;
  }

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) async {
    updateCallsCount++;
    if (updateCompleter != null) {
      return updateCompleter!.future;
    }
    if (shouldFailUpdate) {
      throw Exception('Server error saving settings');
    }
    currentSettings = settings;
    return currentSettings;
  }
}

void main() {
  late FakeMerchantSettingsRepository repository;
  late MerchantSettingsCubit cubit;

  setUp(() {
    repository = FakeMerchantSettingsRepository();
    cubit = MerchantSettingsCubit(repository: repository);
  });

  tearDown(() {
    cubit.close();
  });

  Widget createWidgetUnderTest({MerchantSettingsCubit? activeCubit}) {
    return MaterialApp(
      home: MerchantSettingsScreen(
        cubit: activeCubit ?? cubit,
      ),
    );
  }

  group('MerchantSettingsScreen Widget Tests', () {
    testWidgets('displays loading indicator initially while loading settings', (tester) async {
      repository.getCompleter = Completer<StoreSettingsModel>();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Render first frame with loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      repository.getCompleter!.complete(repository.currentSettings);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Store Settings'), findsOneWidget);
      expect(find.text('Original Store Name'), findsOneWidget);
    });

    testWidgets('displays error state and retry button when initial load fails', (tester) async {
      repository.shouldFailGet = true;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Exception: Failed to load store settings from server'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry with fixed failure
      repository.shouldFailGet = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Original Store Name'), findsOneWidget);
      expect(find.text('Exception: Failed to load store settings from server'), findsNothing);
    });

    testWidgets('renders all sections and populates form fields with loaded data', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check section titles
      expect(find.text('General Settings'), findsOneWidget);
      expect(find.text('Delivery & Shipping Configuration'), findsOneWidget);
      expect(find.text('Return & Replacement Policy'), findsOneWidget);

      // Check populated fields
      expect(find.text('Original Store Name'), findsOneWidget);
      expect(find.text('https://example.com/logo.png'), findsOneWidget);
      expect(find.text('support@wovzo.com'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);
      expect(find.text('INR'), findsOneWidget);
      expect(find.text('40.0'), findsOneWidget);
      expect(find.text('499.0'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('110001, 110002'), findsOneWidget);
      expect(find.text('7'), findsNWidgets(2)); // returnWindowDays and replaceWindowDays
      expect(find.text('Standard return policy text'), findsOneWidget);
    });

    testWidgets('validates required fields on submission', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clear store name
      await tester.enterText(find.byKey(const Key('store_name_input')), '');
      await tester.ensureVisible(find.byKey(const Key('save_settings_button')));
      await tester.tap(find.byKey(const Key('save_settings_button')));
      await tester.pumpAndSettle();

      expect(find.text('Store name is required'), findsOneWidget);
      expect(repository.updateCallsCount, 0);
    });

    testWidgets('saves modified settings and displays success feedback', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Modify store name
      await tester.enterText(find.byKey(const Key('store_name_input')), 'Updated Store Co.');
      // Modify flat delivery charge
      await tester.enterText(find.byKey(const Key('flat_delivery_charge_input')), '60.0');

      await tester.ensureVisible(find.byKey(const Key('save_settings_button')));
      await tester.tap(find.byKey(const Key('save_settings_button')));
      await tester.pumpAndSettle();

      expect(repository.updateCallsCount, 1);
      expect(repository.currentSettings.storeName, 'Updated Store Co.');
      expect(repository.currentSettings.flatDeliveryCharge, 60.0);
      expect(find.text('Store settings updated successfully'), findsOneWidget);
    });

    testWidgets('displays error snackbar when save update fails', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      repository.shouldFailUpdate = true;

      await tester.ensureVisible(find.byKey(const Key('save_settings_button')));
      await tester.tap(find.byKey(const Key('save_settings_button')));
      await tester.pumpAndSettle();

      expect(repository.updateCallsCount, 1);
      expect(find.text('Exception: Server error saving settings'), findsOneWidget);
    });

    testWidgets('prevents duplicate save submissions while request is in flight', (tester) async {
      repository.updateCompleter = Completer<StoreSettingsModel>();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('save_settings_button')));

      // Tap save once
      await tester.tap(find.byKey(const Key('save_settings_button')));
      await tester.pump(); // Start submitting, button enters submitting state

      expect(find.text('Saving Settings...'), findsOneWidget);

      // Attempt second tap while in-flight
      await tester.tap(find.byKey(const Key('save_settings_button')));
      await tester.pump();

      // Complete async update
      repository.updateCompleter!.complete(repository.currentSettings);
      await tester.pumpAndSettle();

      // Only one update call should have been executed
      expect(repository.updateCallsCount, 1);
      expect(find.text('Store settings updated successfully'), findsOneWidget);
    });
  });
}

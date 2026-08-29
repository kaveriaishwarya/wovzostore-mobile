import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';
import 'package:wovzo_mobile/features/merchant_settings/domain/repositories/merchant_settings_repository.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/cubit/merchant_settings_cubit.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/screens/merchant_settings_screen.dart';

class FakeMerchantSettingsRepository implements MerchantSettingsRepository {
  StoreSettingsModel currentSettings = StoreSettingsModel(
    storeName: 'WOVZO Test Store',
    codEnabled: true,
    minOrderAmountForCod: 0.0,
    defaultCurrency: 'INR',
    flatDeliveryCharge: 40.0,
    estimatedDeliveryDays: 3,
    returnWindowDays: 7,
    replaceWindowDays: 7,
    returnAllowed: true,
    gstin: '27AAAAA0000A1Z5',
    legalName: 'Wovzo Enterprise Pvt Ltd',
    panNumber: 'AAAAA0000A',
    stateCode: '27',
    stateName: 'Maharashtra',
    bankName: 'HDFC Bank',
    bankAccountNumber: '502000123456',
    bankIfscCode: 'HDFC0001234',
    invoicePrefix: 'INV-',
    createdAt: DateTime(2026, 1, 1),
  );

  int updateCallsCount = 0;

  @override
  Future<StoreSettingsModel> getStoreSettings() async {
    return currentSettings;
  }

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) async {
    updateCallsCount++;
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

  Widget buildWidget({bool isReadOnly = false}) {
    return MaterialApp(
      home: MerchantSettingsScreen(
        cubit: cubit,
        isReadOnly: isReadOnly,
      ),
    );
  }

  group('MerchantSettingsScreen GST & Role Protection Widget Tests', () {
    testWidgets('renders GSTIN, Legal Name, State, and Bank inputs when loaded', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('GST & Business Identity Configuration'), findsOneWidget);
      expect(find.text('Bank Account Details (Invoice Display)'), findsOneWidget);
      expect(find.byKey(const Key('gstin_input')), findsOneWidget);
      expect(find.byKey(const Key('legal_name_input')), findsOneWidget);
      expect(find.byKey(const Key('bank_name_input')), findsOneWidget);

      expect(find.widgetWithText(TextFormField, '27AAAAA0000A1Z5'), findsWidgets);
      expect(find.widgetWithText(TextFormField, 'Wovzo Enterprise Pvt Ltd'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'HDFC Bank'), findsOneWidget);
    });

    testWidgets('shows view-only lock banner and disables save button when isReadOnly is true', (tester) async {
      await tester.pumpWidget(buildWidget(isReadOnly: true));
      await tester.pumpAndSettle();

      expect(find.textContaining('View-Only Access'), findsOneWidget);

      final saveButtonFinder = find.byKey(const Key('save_settings_button'));
      expect(saveButtonFinder, findsOneWidget);

      final filledButton = tester.widget<FilledButton>(saveButtonFinder);
      expect(filledButton.onPressed, isNull);
    });

    testWidgets('validates 15-character GSTIN format when editing as admin', (tester) async {
      await tester.pumpWidget(buildWidget(isReadOnly: false));
      await tester.pumpAndSettle();

      final gstinFinder = find.byKey(const Key('gstin_input'));
      await tester.enterText(gstinFinder, 'INVALID_GST');

      final saveButtonFinder = find.byKey(const Key('save_settings_button'));
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('GSTIN must be exactly 15 characters'), findsOneWidget);
      expect(repository.updateCallsCount, 0);
    });
  });
}

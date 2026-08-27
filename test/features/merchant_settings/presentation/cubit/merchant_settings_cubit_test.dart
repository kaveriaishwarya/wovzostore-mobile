import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';
import 'package:wovzo_mobile/features/merchant_settings/domain/repositories/merchant_settings_repository.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/cubit/merchant_settings_cubit.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/cubit/merchant_settings_state.dart';

class MockMerchantSettingsRepository implements MerchantSettingsRepository {
  bool shouldFail = false;

  final sampleSettings = StoreSettingsModel(
    storeName: 'Wovzo Store',
    codEnabled: true,
    minOrderAmountForCod: 0,
    defaultCurrency: 'INR',
    flatDeliveryCharge: 0,
    estimatedDeliveryDays: 0,
    returnWindowDays: 0,
    replaceWindowDays: 0,
    returnAllowed: true,
    createdAt: DateTime.now(),
  );

  @override
  Future<StoreSettingsModel> getStoreSettings() async {
    if (shouldFail) throw Exception('Failed');
    return sampleSettings;
  }

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) async {
    if (shouldFail) throw Exception('Failed');
    return sampleSettings;
  }
}

void main() {
  late MerchantSettingsCubit cubit;
  late MockMerchantSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockMerchantSettingsRepository();
    cubit = MerchantSettingsCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be MerchantSettingsInitial', () {
    expect(cubit.state, equals(MerchantSettingsInitial()));
  });

  test('should emit Loading then Loaded when loadSettings is successful', () async {
    expect(cubit.state, equals(MerchantSettingsInitial()));
    final future = cubit.loadSettings();
    expect(cubit.state, equals(MerchantSettingsLoading()));
    await future;
    expect(cubit.state, isA<MerchantSettingsLoaded>());
    expect((cubit.state as MerchantSettingsLoaded).settings.storeName, 'Wovzo Store');
  });

  test('should emit Loading then Error when loadSettings fails', () async {
    mockRepository.shouldFail = true;
    final future = cubit.loadSettings();
    expect(cubit.state, equals(MerchantSettingsLoading()));
    await future;
    expect(cubit.state, isA<MerchantSettingsError>());
    expect((cubit.state as MerchantSettingsError).message, 'Exception: Failed');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/datasources/merchant_settings_remote_datasource.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';
import 'package:wovzo_mobile/features/merchant_settings/data/repositories/merchant_settings_repository_impl.dart';

class MockMerchantSettingsRemoteDataSource implements MerchantSettingsRemoteDataSource {
  bool getStoreSettingsCalled = false;
  final tStoreSettingsModel = StoreSettingsModel(
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
    getStoreSettingsCalled = true;
    return tStoreSettingsModel;
  }

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) async {
    return settings;
  }
}

void main() {
  late MerchantSettingsRepositoryImpl repository;
  late MockMerchantSettingsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockMerchantSettingsRemoteDataSource();
    repository = MerchantSettingsRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getStoreSettings', () {
    test('should return data when remote call is successful', () async {
      final result = await repository.getStoreSettings();
      expect(result, equals(mockRemoteDataSource.tStoreSettingsModel));
      expect(mockRemoteDataSource.getStoreSettingsCalled, isTrue);
    });
  });
}

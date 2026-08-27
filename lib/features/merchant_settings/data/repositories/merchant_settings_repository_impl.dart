import '../../domain/repositories/merchant_settings_repository.dart';
import '../datasources/merchant_settings_remote_datasource.dart';
import '../models/store_settings_model.dart';

class MerchantSettingsRepositoryImpl implements MerchantSettingsRepository {
  final MerchantSettingsRemoteDataSource remoteDataSource;

  MerchantSettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<StoreSettingsModel> getStoreSettings() {
    return remoteDataSource.getStoreSettings();
  }

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) {
    return remoteDataSource.updateStoreSettings(settings);
  }
}

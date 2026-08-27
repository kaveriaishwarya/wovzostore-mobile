import '../../data/models/store_settings_model.dart';

abstract class MerchantSettingsRepository {
  Future<StoreSettingsModel> getStoreSettings();
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings);
}

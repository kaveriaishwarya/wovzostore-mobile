import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/merchant_settings_repository.dart';
import '../../data/models/store_settings_model.dart';
import 'merchant_settings_state.dart';

class MerchantSettingsCubit extends Cubit<MerchantSettingsState> {
  final MerchantSettingsRepository repository;

  MerchantSettingsCubit({required this.repository}) : super(MerchantSettingsInitial());

  Future<void> loadSettings() async {
    emit(MerchantSettingsLoading());
    try {
      final settings = await repository.getStoreSettings();
      emit(MerchantSettingsLoaded(settings: settings));
    } catch (e) {
      emit(MerchantSettingsError(message: e.toString()));
    }
  }

  Future<void> updateSettings(StoreSettingsModel settings) async {
    emit(MerchantSettingsLoading());
    try {
      final updatedSettings = await repository.updateStoreSettings(settings);
      emit(MerchantSettingsUpdateSuccess(settings: updatedSettings));
      emit(MerchantSettingsLoaded(settings: updatedSettings));
    } catch (e) {
      emit(MerchantSettingsError(message: e.toString()));
    }
  }
}

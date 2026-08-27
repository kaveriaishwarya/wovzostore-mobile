import 'package:equatable/equatable.dart';
import '../../data/models/store_settings_model.dart';

abstract class MerchantSettingsState extends Equatable {
  const MerchantSettingsState();

  @override
  List<Object?> get props => [];
}

class MerchantSettingsInitial extends MerchantSettingsState {}

class MerchantSettingsLoading extends MerchantSettingsState {}

class MerchantSettingsLoaded extends MerchantSettingsState {
  final StoreSettingsModel settings;

  const MerchantSettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class MerchantSettingsError extends MerchantSettingsState {
  final String message;

  const MerchantSettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MerchantSettingsUpdateSuccess extends MerchantSettingsState {
  final StoreSettingsModel settings;

  const MerchantSettingsUpdateSuccess({required this.settings});

  @override
  List<Object?> get props => [settings];
}

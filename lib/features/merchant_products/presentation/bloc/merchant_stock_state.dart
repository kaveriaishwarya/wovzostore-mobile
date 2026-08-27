import 'package:equatable/equatable.dart';

enum MerchantStockStatus { initial, updating, success, error }

class MerchantStockState extends Equatable {
  final MerchantStockStatus status;
  final String? errorMessage;

  const MerchantStockState({
    this.status = MerchantStockStatus.initial,
    this.errorMessage,
  });

  bool get isUpdating => status == MerchantStockStatus.updating;
  bool get isSuccess => status == MerchantStockStatus.success;
  bool get isError => status == MerchantStockStatus.error;

  MerchantStockState copyWith({
    MerchantStockStatus? status,
    String? errorMessage,
  }) {
    return MerchantStockState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

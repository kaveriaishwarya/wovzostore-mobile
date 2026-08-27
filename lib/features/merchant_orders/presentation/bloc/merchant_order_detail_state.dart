import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

enum MerchantOrderDetailStatus { initial, loading, success, updating, error }

class MerchantOrderDetailState extends Equatable {
  final MerchantOrderDetailStatus status;
  final OrderModel? order;
  final String? errorMessage;

  const MerchantOrderDetailState({
    this.status = MerchantOrderDetailStatus.initial,
    this.order,
    this.errorMessage,
  });

  bool get isLoading => status == MerchantOrderDetailStatus.loading;
  bool get isUpdating => status == MerchantOrderDetailStatus.updating;
  bool get isSuccess => status == MerchantOrderDetailStatus.success;
  bool get isError => status == MerchantOrderDetailStatus.error;

  MerchantOrderDetailState copyWith({
    MerchantOrderDetailStatus? status,
    OrderModel? order,
    String? errorMessage,
  }) {
    return MerchantOrderDetailState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, order, errorMessage];
}

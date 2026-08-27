import 'package:equatable/equatable.dart';
import '../../../merchant_orders/data/models/order_model.dart';
import '../../data/models/merchant_customer_details_model.dart';

enum MerchantCustomerDetailStatus { initial, loading, success, updating, error }

class MerchantCustomerDetailState extends Equatable {
  final MerchantCustomerDetailStatus status;
  final MerchantCustomerDetailsModel? customer;
  final List<OrderModel> orders;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const MerchantCustomerDetailState({
    this.status = MerchantCustomerDetailStatus.initial,
    this.customer,
    this.orders = const [],
    this.errorMessage,
    this.actionSuccessMessage,
  });

  bool get isLoading => status == MerchantCustomerDetailStatus.loading;
  bool get isSuccess => status == MerchantCustomerDetailStatus.success;
  bool get isUpdating => status == MerchantCustomerDetailStatus.updating;
  bool get isError => status == MerchantCustomerDetailStatus.error;

  MerchantCustomerDetailState copyWith({
    MerchantCustomerDetailStatus? status,
    MerchantCustomerDetailsModel? customer,
    List<OrderModel>? orders,
    String? errorMessage,
    String? actionSuccessMessage,
    bool clearActionSuccessMessage = false,
  }) {
    return MerchantCustomerDetailState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      actionSuccessMessage: clearActionSuccessMessage
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        customer,
        orders,
        errorMessage,
        actionSuccessMessage,
      ];
}

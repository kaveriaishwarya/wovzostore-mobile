import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

enum MerchantOrderDetailStatus { initial, loading, success, updating, error }

class MerchantOrderDetailState extends Equatable {
  final MerchantOrderDetailStatus status;
  final OrderModel? order;
  final String? errorMessage;
  final bool isInvoiceLoading;
  final Uint8List? invoiceBytes;
  final String? invoiceError;

  const MerchantOrderDetailState({
    this.status = MerchantOrderDetailStatus.initial,
    this.order,
    this.errorMessage,
    this.isInvoiceLoading = false,
    this.invoiceBytes,
    this.invoiceError,
  });

  bool get isLoading => status == MerchantOrderDetailStatus.loading;
  bool get isUpdating => status == MerchantOrderDetailStatus.updating;
  bool get isSuccess => status == MerchantOrderDetailStatus.success;
  bool get isError => status == MerchantOrderDetailStatus.error;

  MerchantOrderDetailState copyWith({
    MerchantOrderDetailStatus? status,
    OrderModel? order,
    String? errorMessage,
    bool? isInvoiceLoading,
    Uint8List? invoiceBytes,
    bool clearInvoiceBytes = false,
    String? invoiceError,
  }) {
    return MerchantOrderDetailState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage,
      isInvoiceLoading: isInvoiceLoading ?? this.isInvoiceLoading,
      invoiceBytes: clearInvoiceBytes ? null : (invoiceBytes ?? this.invoiceBytes),
      invoiceError: invoiceError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        order,
        errorMessage,
        isInvoiceLoading,
        invoiceBytes,
        invoiceError,
      ];
}

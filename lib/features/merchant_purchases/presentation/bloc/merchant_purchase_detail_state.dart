import 'package:equatable/equatable.dart';
import '../../data/models/purchase_order_model.dart';

abstract class MerchantPurchaseDetailState extends Equatable {
  const MerchantPurchaseDetailState();

  @override
  List<Object?> get props => [];
}

class MerchantPurchaseDetailInitial extends MerchantPurchaseDetailState {
  const MerchantPurchaseDetailInitial();
}

class MerchantPurchaseDetailLoading extends MerchantPurchaseDetailState {
  const MerchantPurchaseDetailLoading();
}

class MerchantPurchaseDetailLoaded extends MerchantPurchaseDetailState {
  final PurchaseOrderModel purchase;
  final bool isSubmitting;
  final String? actionError;
  final String? actionSuccessMessage;

  const MerchantPurchaseDetailLoaded({
    required this.purchase,
    this.isSubmitting = false,
    this.actionError,
    this.actionSuccessMessage,
  });

  MerchantPurchaseDetailLoaded copyWith({
    PurchaseOrderModel? purchase,
    bool? isSubmitting,
    String? actionError,
    bool clearActionError = false,
    String? actionSuccessMessage,
    bool clearActionSuccess = false,
  }) {
    return MerchantPurchaseDetailLoaded(
      purchase: purchase ?? this.purchase,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      actionSuccessMessage: clearActionSuccess
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        purchase,
        isSubmitting,
        actionError,
        actionSuccessMessage,
      ];
}

class MerchantPurchaseDetailError extends MerchantPurchaseDetailState {
  final String message;

  const MerchantPurchaseDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

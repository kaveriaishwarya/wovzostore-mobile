import 'package:equatable/equatable.dart';
import '../../data/models/purchase_order_model.dart';

abstract class MerchantPurchaseState extends Equatable {
  const MerchantPurchaseState();

  @override
  List<Object?> get props => [];
}

class MerchantPurchaseInitial extends MerchantPurchaseState {
  const MerchantPurchaseInitial();
}

class MerchantPurchaseLoading extends MerchantPurchaseState {
  const MerchantPurchaseLoading();
}

class MerchantPurchaseLoaded extends MerchantPurchaseState {
  final List<PurchaseOrderModel> purchases;
  final int totalCount;
  final int page;
  final bool hasMore;
  final String? supplierIdFilter;
  final PurchaseOrderStatus? statusFilter;
  final String? search;
  final bool isActionSubmitting;
  final String? actionError;
  final String? actionSuccessMessage;

  const MerchantPurchaseLoaded({
    required this.purchases,
    required this.totalCount,
    required this.page,
    required this.hasMore,
    this.supplierIdFilter,
    this.statusFilter,
    this.search,
    this.isActionSubmitting = false,
    this.actionError,
    this.actionSuccessMessage,
  });

  MerchantPurchaseLoaded copyWith({
    List<PurchaseOrderModel>? purchases,
    int? totalCount,
    int? page,
    bool? hasMore,
    String? supplierIdFilter,
    bool clearSupplierFilter = false,
    PurchaseOrderStatus? statusFilter,
    bool clearStatusFilter = false,
    String? search,
    bool? isActionSubmitting,
    String? actionError,
    bool clearActionError = false,
    String? actionSuccessMessage,
    bool clearActionSuccess = false,
  }) {
    return MerchantPurchaseLoaded(
      purchases: purchases ?? this.purchases,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      supplierIdFilter: clearSupplierFilter
          ? null
          : (supplierIdFilter ?? this.supplierIdFilter),
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      search: search ?? this.search,
      isActionSubmitting: isActionSubmitting ?? this.isActionSubmitting,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      actionSuccessMessage: clearActionSuccess
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        purchases,
        totalCount,
        page,
        hasMore,
        supplierIdFilter,
        statusFilter,
        search,
        isActionSubmitting,
        actionError,
        actionSuccessMessage,
      ];
}

class MerchantPurchaseError extends MerchantPurchaseState {
  final String message;

  const MerchantPurchaseError({required this.message});

  @override
  List<Object?> get props => [message];
}

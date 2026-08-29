import 'package:equatable/equatable.dart';
import '../../data/models/supplier_model.dart';

abstract class MerchantSupplierState extends Equatable {
  const MerchantSupplierState();

  @override
  List<Object?> get props => [];
}

class MerchantSupplierInitial extends MerchantSupplierState {
  const MerchantSupplierInitial();
}

class MerchantSupplierLoading extends MerchantSupplierState {
  const MerchantSupplierLoading();
}

class MerchantSupplierLoaded extends MerchantSupplierState {
  final List<SupplierModel> suppliers;
  final int totalCount;
  final int page;
  final bool hasMore;
  final String? search;
  final bool? isActiveFilter;
  final bool isActionSubmitting;
  final String? actionError;
  final String? actionSuccessMessage;

  const MerchantSupplierLoaded({
    required this.suppliers,
    required this.totalCount,
    required this.page,
    required this.hasMore,
    this.search,
    this.isActiveFilter,
    this.isActionSubmitting = false,
    this.actionError,
    this.actionSuccessMessage,
  });

  MerchantSupplierLoaded copyWith({
    List<SupplierModel>? suppliers,
    int? totalCount,
    int? page,
    bool? hasMore,
    String? search,
    bool? isActiveFilter,
    bool clearActiveFilter = false,
    bool? isActionSubmitting,
    String? actionError,
    bool clearActionError = false,
    String? actionSuccessMessage,
    bool clearActionSuccess = false,
  }) {
    return MerchantSupplierLoaded(
      suppliers: suppliers ?? this.suppliers,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      isActiveFilter: clearActiveFilter ? null : (isActiveFilter ?? this.isActiveFilter),
      isActionSubmitting: isActionSubmitting ?? this.isActionSubmitting,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      actionSuccessMessage: clearActionSuccess ? null : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        suppliers,
        totalCount,
        page,
        hasMore,
        search,
        isActiveFilter,
        isActionSubmitting,
        actionError,
        actionSuccessMessage,
      ];
}

class MerchantSupplierError extends MerchantSupplierState {
  final String message;

  const MerchantSupplierError({required this.message});

  @override
  List<Object?> get props => [message];
}

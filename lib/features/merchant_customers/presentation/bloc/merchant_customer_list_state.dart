import 'package:equatable/equatable.dart';
import '../../data/models/merchant_customer_model.dart';

enum MerchantCustomerListStatus { initial, loading, success, error }

class MerchantCustomerListState extends Equatable {
  final MerchantCustomerListStatus status;
  final List<MerchantCustomerModel> customers;
  final int page;
  final int pageSize;
  final bool hasMore;
  final bool? statusFilter;
  final String? searchQuery;
  final String? errorMessage;

  const MerchantCustomerListState({
    this.status = MerchantCustomerListStatus.initial,
    this.customers = const [],
    this.page = 1,
    this.pageSize = 20,
    this.hasMore = false,
    this.statusFilter,
    this.searchQuery,
    this.errorMessage,
  });

  bool get isLoading => status == MerchantCustomerListStatus.loading;
  bool get isSuccess => status == MerchantCustomerListStatus.success;
  bool get isError => status == MerchantCustomerListStatus.error;

  MerchantCustomerListState copyWith({
    MerchantCustomerListStatus? status,
    List<MerchantCustomerModel>? customers,
    int? page,
    int? pageSize,
    bool? hasMore,
    bool? statusFilter,
    bool clearStatusFilter = false,
    String? searchQuery,
    bool clearSearchQuery = false,
    String? errorMessage,
  }) {
    return MerchantCustomerListState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customers,
        page,
        pageSize,
        hasMore,
        statusFilter,
        searchQuery,
        errorMessage,
      ];
}

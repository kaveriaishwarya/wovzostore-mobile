import 'package:equatable/equatable.dart';
import '../../data/models/order_list_model.dart';

enum MerchantOrderListStatus { initial, loading, loadingMore, success, error }

class MerchantOrderListState extends Equatable {
  final MerchantOrderListStatus status;
  final List<OrderListModel> orders;
  final int totalCount;
  final int page;
  final int pageSize;
  final int? statusFilter;
  final String? search;
  final String? errorMessage;

  const MerchantOrderListState({
    this.status = MerchantOrderListStatus.initial,
    this.orders = const [],
    this.totalCount = 0,
    this.page = 1,
    this.pageSize = 20,
    this.statusFilter,
    this.search,
    this.errorMessage,
  });

  bool get isLoading => status == MerchantOrderListStatus.loading;
  bool get isLoadingMore => status == MerchantOrderListStatus.loadingMore;
  bool get isSuccess => status == MerchantOrderListStatus.success;
  bool get isError => status == MerchantOrderListStatus.error;
  bool get hasMore => orders.length < totalCount;

  MerchantOrderListState copyWith({
    MerchantOrderListStatus? status,
    List<OrderListModel>? orders,
    int? totalCount,
    int? page,
    int? pageSize,
    int? statusFilter,
    bool clearStatusFilter = false,
    String? search,
    bool clearSearch = false,
    String? errorMessage,
  }) {
    return MerchantOrderListState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      search: clearSearch ? null : (search ?? this.search),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        totalCount,
        page,
        pageSize,
        statusFilter,
        search,
        errorMessage,
      ];
}

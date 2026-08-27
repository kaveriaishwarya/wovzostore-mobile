import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/merchant_order_repository.dart';
import '../../data/models/order_list_model.dart';
import 'merchant_order_list_state.dart';

class MerchantOrderListCubit extends Cubit<MerchantOrderListState> {
  final MerchantOrderRepository _repository;

  MerchantOrderListCubit({required MerchantOrderRepository repository})
      : _repository = repository,
        super(const MerchantOrderListState());

  Future<void> loadOrders({
    int? statusFilter,
    String? search,
    int? pageSize,
  }) async {
    final effectivePageSize = pageSize ?? state.pageSize;
    emit(state.copyWith(
      status: MerchantOrderListStatus.loading,
      statusFilter: statusFilter,
      clearStatusFilter: statusFilter == null,
      search: search,
      clearSearch: search == null,
      pageSize: effectivePageSize,
      page: 1,
    ));

    try {
      final result = await _repository.getOrders(
        page: 1,
        pageSize: effectivePageSize,
        status: statusFilter ?? state.statusFilter,
        search: search ?? state.search,
      );

      emit(state.copyWith(
        status: MerchantOrderListStatus.success,
        orders: result.data,
        totalCount: result.totalCount,
        page: 1,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantOrderListStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantOrderListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(status: MerchantOrderListStatus.loadingMore));

    try {
      final result = await _repository.getOrders(
        page: nextPage,
        pageSize: state.pageSize,
        status: state.statusFilter,
        search: state.search,
      );

      final updatedOrders = List<OrderListModel>.from(state.orders)..addAll(result.data);

      emit(state.copyWith(
        status: MerchantOrderListStatus.success,
        orders: updatedOrders,
        totalCount: result.totalCount,
        page: nextPage,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantOrderListStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantOrderListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> filterByStatus(int? status) async {
    await loadOrders(statusFilter: status, search: state.search);
  }

  Future<void> searchOrders(String query) async {
    await loadOrders(statusFilter: state.statusFilter, search: query.isEmpty ? null : query);
  }

  Future<void> refresh() async {
    await loadOrders(statusFilter: state.statusFilter, search: state.search);
  }
}

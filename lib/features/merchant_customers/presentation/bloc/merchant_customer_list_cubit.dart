import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/merchant_customer_repository.dart';
import 'merchant_customer_list_state.dart';

class MerchantCustomerListCubit extends Cubit<MerchantCustomerListState> {
  final MerchantCustomerRepository _repository;

  MerchantCustomerListCubit({required MerchantCustomerRepository repository})
      : _repository = repository,
        super(const MerchantCustomerListState());

  Future<void> loadCustomers({
    bool refresh = false,
    bool? statusFilter,
    String? searchQuery,
  }) async {
    final newStatusFilter = statusFilter ?? state.statusFilter;
    final newSearchQuery = searchQuery ?? state.searchQuery;
    final currentPage = refresh ? 1 : state.page;

    emit(state.copyWith(
      status: MerchantCustomerListStatus.loading,
      statusFilter: newStatusFilter,
      searchQuery: newSearchQuery,
      page: currentPage,
    ));

    try {
      final pagedResult = await _repository.getCustomers(
        page: currentPage,
        pageSize: state.pageSize,
        status: newStatusFilter,
        search: newSearchQuery,
      );

      final combined = refresh
          ? pagedResult.data
          : [...state.customers, ...pagedResult.data];

      emit(state.copyWith(
        status: MerchantCustomerListStatus.success,
        customers: combined,
        hasMore: pagedResult.hasNextPage,
        page: currentPage + 1,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerListStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> search(String query) async {
    await loadCustomers(
      refresh: true,
      searchQuery: query.trim(),
    );
  }

  Future<void> filterByStatus(bool? status) async {
    if (status == null) {
      emit(state.copyWith(clearStatusFilter: true));
    }
    await loadCustomers(
      refresh: true,
      statusFilter: status,
    );
  }
}

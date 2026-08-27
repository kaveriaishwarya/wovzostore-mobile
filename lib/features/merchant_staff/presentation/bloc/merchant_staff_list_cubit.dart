import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/merchant_staff_repository.dart';
import 'merchant_staff_list_state.dart';

class MerchantStaffListCubit extends Cubit<MerchantStaffListState> {
  final MerchantStaffRepository repository;

  MerchantStaffListCubit({required this.repository}) : super(MerchantStaffListInitial());

  Future<void> loadStaff({
    int page = 1,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    emit(MerchantStaffListLoading());
    try {
      final pagedResult = await repository.getStaff(
        page: page,
        pageSize: 20,
        search: search,
        role: role,
        isActive: isActive,
      );

      emit(MerchantStaffListLoaded(
        staff: pagedResult.data,
        pageNumber: pagedResult.pageNumber,
        totalPages: pagedResult.totalPages,
        totalCount: pagedResult.totalCount,
        hasNextPage: pagedResult.hasNextPage,
        searchQuery: search,
        roleFilter: role,
        activeFilter: isActive,
      ));
    } catch (e) {
      emit(MerchantStaffListError(e.toString()));
    }
  }

  Future<void> refresh() async {
    if (state is MerchantStaffListLoaded) {
      final currentState = state as MerchantStaffListLoaded;
      await loadStaff(
        page: 1,
        search: currentState.searchQuery,
        role: currentState.roleFilter,
        isActive: currentState.activeFilter,
      );
    } else {
      await loadStaff(page: 1);
    }
  }
}

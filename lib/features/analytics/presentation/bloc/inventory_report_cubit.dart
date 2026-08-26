import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_status.dart';
import 'inventory_report_state.dart';

class InventoryReportCubit extends Cubit<InventoryReportState> {
  final AnalyticsRepository repository;

  InventoryReportCubit({required this.repository})
      : super(const InventoryReportState());

  Future<void> loadReport() async {
    emit(state.copyWith(status: AnalyticsStatus.loading, errorMessage: null));
    try {
      final report = await repository.getInventoryReport(
        lowStockOnly: state.lowStockOnly,
        categoryId: state.categoryId,
        page: state.page,
        pageSize: state.pageSize,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
      );
      emit(state.copyWith(
        status: AnalyticsStatus.success,
        report: report,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AnalyticsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void changePage(int newPage) {
    if (newPage == state.page) return;
    emit(state.copyWith(page: newPage));
    loadReport();
  }

  void changeSorting(String sortBy, String sortDirection) {
    emit(state.copyWith(sortBy: sortBy, sortDirection: sortDirection, page: 1));
    loadReport();
  }

  void updateFilters({
    bool? lowStockOnly,
    String? categoryId,
    bool clearCategory = false,
  }) {
    emit(state.copyWith(
      lowStockOnly: lowStockOnly ?? state.lowStockOnly,
      categoryId: categoryId,
      clearCategory: clearCategory,
      page: 1, // Filter change resets page to 1
    ));
    loadReport();
  }

  void reload() => loadReport();
}

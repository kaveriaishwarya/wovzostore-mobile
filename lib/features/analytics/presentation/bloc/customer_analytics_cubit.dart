import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_status.dart';
import 'customer_analytics_state.dart';

class CustomerAnalyticsCubit extends Cubit<CustomerAnalyticsState> {
  final AnalyticsRepository repository;

  CustomerAnalyticsCubit({
    required this.repository,
    String? startDate,
    String? endDate,
  }) : super(CustomerAnalyticsState(
          startDate: startDate ?? _defaultStartDate(),
          endDate: endDate ?? _defaultEndDate(),
        ));

  static String _defaultEndDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _defaultStartDate() {
    final start = DateTime.now().subtract(const Duration(days: 29));
    return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadReport() async {
    emit(state.copyWith(status: AnalyticsStatus.loading, errorMessage: null));
    try {
      final report = await repository.getCustomerAnalyticsReport(
        startDate: state.startDate,
        endDate: state.endDate,
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

  void updateDateRange({required String startDate, required String endDate}) {
    emit(state.copyWith(
      startDate: startDate,
      endDate: endDate,
      page: 1, // Filter change resets page to 1
    ));
    loadReport();
  }

  void reload() => loadReport();
}

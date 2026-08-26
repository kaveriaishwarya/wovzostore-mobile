import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_status.dart';
import 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final AnalyticsRepository repository;

  SalesCubit({required this.repository, String? startDate, String? endDate})
      : super(SalesState(
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
      final report = await repository.getSalesReport(
        startDate: state.startDate,
        endDate: state.endDate,
        interval: state.interval,
        status: state.orderStatus,
        paymentMethod: state.paymentMethod,
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

  void updateDateRange({required String startDate, required String endDate}) {
    emit(state.copyWith(startDate: startDate, endDate: endDate));
    loadReport();
  }

  void updateInterval(int? interval) {
    emit(state.copyWith(interval: interval));
    loadReport();
  }

  void reload() => loadReport();
}

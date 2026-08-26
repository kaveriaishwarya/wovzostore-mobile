import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_status.dart';
import 'category_brand_state.dart';

class CategoryBrandCubit extends Cubit<CategoryBrandState> {
  final AnalyticsRepository repository;

  CategoryBrandCubit({
    required this.repository,
    String? startDate,
    String? endDate,
  }) : super(CategoryBrandState(
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
      final categoriesFuture = repository.getCategoryPerformanceReport(
        startDate: state.startDate,
        endDate: state.endDate,
      );
      final brandsFuture = repository.getBrandPerformanceReport(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      final results = await Future.wait([categoriesFuture, brandsFuture]);

      emit(state.copyWith(
        status: AnalyticsStatus.success,
        categories: results[0] as dynamic,
        brands: results[1] as dynamic,
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

  void reload() => loadReport();
}

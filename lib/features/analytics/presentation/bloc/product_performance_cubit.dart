import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_status.dart';
import 'product_performance_state.dart';

class ProductPerformanceCubit extends Cubit<ProductPerformanceState> {
  final AnalyticsRepository repository;

  ProductPerformanceCubit({
    required this.repository,
    String? startDate,
    String? endDate,
  }) : super(ProductPerformanceState(
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
      final pagedData = await repository.getProductPerformanceReport(
        startDate: state.startDate,
        endDate: state.endDate,
        categoryId: state.categoryId,
        brandId: state.brandId,
        page: state.page,
        pageSize: state.pageSize,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
      );
      emit(state.copyWith(
        status: AnalyticsStatus.success,
        pagedData: pagedData,
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
    String? startDate,
    String? endDate,
    String? categoryId,
    bool clearCategory = false,
    String? brandId,
    bool clearBrand = false,
  }) {
    emit(state.copyWith(
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
      categoryId: categoryId,
      clearCategory: clearCategory,
      brandId: brandId,
      clearBrand: clearBrand,
      page: 1, // Filter change resets page to 1
    ));
    loadReport();
  }

  Future<void> exportReport(dynamic exportService) async {
    if (state.isExporting) return;
    emit(state.copyWith(isExporting: true));
    try {
      final bytes = await repository.exportProductPerformanceReport(
        startDate: state.startDate,
        endDate: state.endDate,
        categoryId: state.categoryId,
        brandId: state.brandId,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
      );
      final fileName = exportService.generateProductFileName(state.startDate, state.endDate);
      final filePath = await exportService.saveCsvFile(bytes: bytes, fileName: fileName);
      await exportService.shareCsvFile(filePath: filePath, title: 'Export Product Performance');
    } finally {
      emit(state.copyWith(isExporting: false));
    }
  }

  void reload() => loadReport();
}

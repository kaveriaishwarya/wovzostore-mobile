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

  Future<void> exportCategoryReport(dynamic exportService) async {
    if (state.isExporting) return;
    emit(state.copyWith(isExporting: true));
    try {
      final bytes = await repository.exportCategoryPerformanceReport(
        startDate: state.startDate,
        endDate: state.endDate,
      );
      final fileName = exportService.generateCategoryFileName(state.startDate, state.endDate);
      final filePath = await exportService.saveCsvFile(bytes: bytes, fileName: fileName);
      await exportService.shareCsvFile(filePath: filePath, title: 'Export Category Performance');
    } finally {
      emit(state.copyWith(isExporting: false));
    }
  }

  Future<void> exportBrandReport(dynamic exportService) async {
    if (state.isExporting) return;
    emit(state.copyWith(isExporting: true));
    try {
      final bytes = await repository.exportBrandPerformanceReport(
        startDate: state.startDate,
        endDate: state.endDate,
      );
      final fileName = exportService.generateBrandFileName(state.startDate, state.endDate);
      final filePath = await exportService.saveCsvFile(bytes: bytes, fileName: fileName);
      await exportService.shareCsvFile(filePath: filePath, title: 'Export Brand Performance');
    } finally {
      emit(state.copyWith(isExporting: false));
    }
  }

  void reload() => loadReport();
}

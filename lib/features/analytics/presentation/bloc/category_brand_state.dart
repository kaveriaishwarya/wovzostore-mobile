import '../../data/models/category_performance_model.dart';
import '../../data/models/brand_performance_model.dart';
import 'analytics_status.dart';

class CategoryBrandState {
  final AnalyticsStatus status;
  final List<CategoryPerformanceModel> categories;
  final List<BrandPerformanceModel> brands;
  final String startDate;
  final String endDate;
  final String? errorMessage;

  const CategoryBrandState({
    this.status = AnalyticsStatus.initial,
    this.categories = const [],
    this.brands = const [],
    required this.startDate,
    required this.endDate,
    this.errorMessage,
  });

  CategoryBrandState copyWith({
    AnalyticsStatus? status,
    List<CategoryPerformanceModel>? categories,
    List<BrandPerformanceModel>? brands,
    String? startDate,
    String? endDate,
    String? errorMessage,
  }) {
    return CategoryBrandState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      errorMessage: errorMessage,
    );
  }
}

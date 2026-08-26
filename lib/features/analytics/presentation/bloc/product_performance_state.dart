import '../../data/models/paged_result_model.dart';
import '../../data/models/product_performance_model.dart';
import 'analytics_status.dart';

class ProductPerformanceState {
  final AnalyticsStatus status;
  final PagedResult<ProductPerformanceModel>? pagedData;
  final String startDate;
  final String endDate;
  final String? categoryId;
  final String? brandId;
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortDirection;
  final String? errorMessage;

  const ProductPerformanceState({
    this.status = AnalyticsStatus.initial,
    this.pagedData,
    required this.startDate,
    required this.endDate,
    this.categoryId,
    this.brandId,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'revenue',
    this.sortDirection = 'desc',
    this.errorMessage,
  });

  ProductPerformanceState copyWith({
    AnalyticsStatus? status,
    PagedResult<ProductPerformanceModel>? pagedData,
    String? startDate,
    String? endDate,
    String? categoryId,
    bool clearCategory = false,
    String? brandId,
    bool clearBrand = false,
    int? page,
    int? pageSize,
    String? sortBy,
    String? sortDirection,
    String? errorMessage,
  }) {
    return ProductPerformanceState(
      status: status ?? this.status,
      pagedData: pagedData ?? this.pagedData,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      brandId: clearBrand ? null : (brandId ?? this.brandId),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      errorMessage: errorMessage,
    );
  }
}

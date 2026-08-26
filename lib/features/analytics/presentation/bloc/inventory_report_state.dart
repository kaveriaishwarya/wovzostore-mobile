import '../../data/models/inventory_report_model.dart';
import 'analytics_status.dart';

class InventoryReportState {
  final AnalyticsStatus status;
  final InventoryReportModel? report;
  final bool lowStockOnly;
  final String? categoryId;
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortDirection;
  final String? errorMessage;

  const InventoryReportState({
    this.status = AnalyticsStatus.initial,
    this.report,
    this.lowStockOnly = false,
    this.categoryId,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'stock',
    this.sortDirection = 'asc',
    this.errorMessage,
  });

  InventoryReportState copyWith({
    AnalyticsStatus? status,
    InventoryReportModel? report,
    bool? lowStockOnly,
    String? categoryId,
    bool clearCategory = false,
    int? page,
    int? pageSize,
    String? sortBy,
    String? sortDirection,
    String? errorMessage,
  }) {
    return InventoryReportState(
      status: status ?? this.status,
      report: report ?? this.report,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      errorMessage: errorMessage,
    );
  }
}

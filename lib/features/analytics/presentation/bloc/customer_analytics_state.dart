import '../../data/models/customer_analytics_model.dart';
import 'analytics_status.dart';

class CustomerAnalyticsState {
  final AnalyticsStatus status;
  final CustomerAnalyticsReportModel? report;
  final String startDate;
  final String endDate;
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortDirection;
  final bool isExporting;
  final String? errorMessage;

  const CustomerAnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.report,
    required this.startDate,
    required this.endDate,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'revenue',
    this.sortDirection = 'desc',
    this.isExporting = false,
    this.errorMessage,
  });

  CustomerAnalyticsState copyWith({
    AnalyticsStatus? status,
    CustomerAnalyticsReportModel? report,
    String? startDate,
    String? endDate,
    int? page,
    int? pageSize,
    String? sortBy,
    String? sortDirection,
    bool? isExporting,
    String? errorMessage,
  }) {
    return CustomerAnalyticsState(
      status: status ?? this.status,
      report: report ?? this.report,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      isExporting: isExporting ?? this.isExporting,
      errorMessage: errorMessage,
    );
  }
}

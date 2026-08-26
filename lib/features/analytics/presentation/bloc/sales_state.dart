import '../../data/models/sales_report_model.dart';
import 'analytics_status.dart';

class SalesState {
  final AnalyticsStatus status;
  final SalesReportModel? report;
  final String startDate;
  final String endDate;
  final int? interval;
  final int? orderStatus;
  final int? paymentMethod;
  final bool isExporting;
  final String? errorMessage;

  const SalesState({
    this.status = AnalyticsStatus.initial,
    this.report,
    required this.startDate,
    required this.endDate,
    this.interval = 0, // Daily default
    this.orderStatus,
    this.paymentMethod,
    this.isExporting = false,
    this.errorMessage,
  });

  SalesState copyWith({
    AnalyticsStatus? status,
    SalesReportModel? report,
    String? startDate,
    String? endDate,
    int? interval,
    int? orderStatus,
    int? paymentMethod,
    bool? isExporting,
    String? errorMessage,
  }) {
    return SalesState(
      status: status ?? this.status,
      report: report ?? this.report,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      interval: interval ?? this.interval,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isExporting: isExporting ?? this.isExporting,
      errorMessage: errorMessage,
    );
  }
}

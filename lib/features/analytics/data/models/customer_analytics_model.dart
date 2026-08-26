import 'paged_result_model.dart';

/// Summary metrics matching backend `CustomerAnalyticsDto`.
class CustomerAnalyticsSummaryModel {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final double repeatPurchaseRate;
  final double revenueFromNewCustomers;
  final double revenueFromReturningCustomers;

  const CustomerAnalyticsSummaryModel({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.repeatPurchaseRate,
    required this.revenueFromNewCustomers,
    required this.revenueFromReturningCustomers,
  });

  factory CustomerAnalyticsSummaryModel.fromJson(Map<String, dynamic> json) =>
      CustomerAnalyticsSummaryModel(
        totalCustomers: json['totalCustomers'] as int? ?? 0,
        newCustomers: json['newCustomers'] as int? ?? 0,
        returningCustomers: json['returningCustomers'] as int? ?? 0,
        repeatPurchaseRate:
            (json['repeatPurchaseRate'] as num?)?.toDouble() ?? 0.0,
        revenueFromNewCustomers:
            (json['revenueFromNewCustomers'] as num?)?.toDouble() ?? 0.0,
        revenueFromReturningCustomers:
            (json['revenueFromReturningCustomers'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'totalCustomers': totalCustomers,
        'newCustomers': newCustomers,
        'returningCustomers': returningCustomers,
        'repeatPurchaseRate': repeatPurchaseRate,
        'revenueFromNewCustomers': revenueFromNewCustomers,
        'revenueFromReturningCustomers': revenueFromReturningCustomers,
      };
}

/// Top customer item matching backend `CustomerPerformanceDto`.
class CustomerPerformanceModel {
  final String customerId;
  final String displayName;
  final int orderCount;
  final double revenue;
  final DateTime? lastOrderDate;

  const CustomerPerformanceModel({
    required this.customerId,
    required this.displayName,
    required this.orderCount,
    required this.revenue,
    this.lastOrderDate,
  });

  factory CustomerPerformanceModel.fromJson(Map<String, dynamic> json) =>
      CustomerPerformanceModel(
        customerId: json['customerId'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        orderCount: json['orderCount'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
        lastOrderDate: json['lastOrderDate'] != null
            ? DateTime.tryParse(json['lastOrderDate'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'displayName': displayName,
        'orderCount': orderCount,
        'revenue': revenue,
        'lastOrderDate': lastOrderDate?.toIso8601String(),
      };
}

/// Complete customer analytics report matching backend `CustomerAnalyticsReportDto`.
class CustomerAnalyticsReportModel {
  final CustomerAnalyticsSummaryModel summary;
  final PagedResult<CustomerPerformanceModel> topCustomers;

  const CustomerAnalyticsReportModel({
    required this.summary,
    required this.topCustomers,
  });

  factory CustomerAnalyticsReportModel.fromJson(Map<String, dynamic> json) =>
      CustomerAnalyticsReportModel(
        summary: json['summary'] != null
            ? CustomerAnalyticsSummaryModel.fromJson(
                json['summary'] as Map<String, dynamic>)
            : const CustomerAnalyticsSummaryModel(
                totalCustomers: 0,
                newCustomers: 0,
                returningCustomers: 0,
                repeatPurchaseRate: 0.0,
                revenueFromNewCustomers: 0.0,
                revenueFromReturningCustomers: 0.0,
              ),
        topCustomers: json['topCustomers'] != null
            ? PagedResult.fromJson(
                json['topCustomers'] as Map<String, dynamic>,
                (item) => CustomerPerformanceModel.fromJson(item),
              )
            : const PagedResult(
                data: [],
                pageNumber: 1,
                pageSize: 20,
                totalCount: 0,
                totalPages: 0,
                hasPreviousPage: false,
                hasNextPage: false,
              ),
      );

  Map<String, dynamic> toJson() => {
        'summary': summary.toJson(),
        'topCustomers': topCustomers.toJson((item) => item.toJson()),
      };
}

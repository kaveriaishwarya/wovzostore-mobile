/// Model representing single period trend in a sales report.
class SalesTrendModel {
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int orderCount;
  final double grossSales;
  final double netSales;

  const SalesTrendModel({
    this.periodStart,
    this.periodEnd,
    required this.orderCount,
    required this.grossSales,
    required this.netSales,
  });

  factory SalesTrendModel.fromJson(Map<String, dynamic> json) => SalesTrendModel(
        periodStart: json['periodStart'] != null
            ? DateTime.tryParse(json['periodStart'] as String)
            : null,
        periodEnd: json['periodEnd'] != null
            ? DateTime.tryParse(json['periodEnd'] as String)
            : null,
        orderCount: json['orderCount'] as int? ?? 0,
        grossSales: (json['grossSales'] as num?)?.toDouble() ?? 0.0,
        netSales: (json['netSales'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'periodStart': periodStart?.toIso8601String(),
        'periodEnd': periodEnd?.toIso8601String(),
        'orderCount': orderCount,
        'grossSales': grossSales,
        'netSales': netSales,
      };
}

/// Model representing complete Sales Report matching backend `SalesReportDto`.
class SalesReportModel {
  final DateTime? startDate;
  final DateTime? endDate;
  final double grossSales;
  final double netSales;
  final int orderCount;
  final double averageOrderValue;
  final double discountAmount;
  final double taxAmount;
  final double shippingAmount;
  final double refundAmount;
  final int cancelledOrderCount;
  final List<SalesTrendModel> trend;

  const SalesReportModel({
    this.startDate,
    this.endDate,
    required this.grossSales,
    required this.netSales,
    required this.orderCount,
    required this.averageOrderValue,
    required this.discountAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.refundAmount,
    required this.cancelledOrderCount,
    required this.trend,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) =>
      SalesReportModel(
        startDate: json['startDate'] != null
            ? DateTime.tryParse(json['startDate'] as String)
            : null,
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'] as String)
            : null,
        grossSales: (json['grossSales'] as num?)?.toDouble() ?? 0.0,
        netSales: (json['netSales'] as num?)?.toDouble() ?? 0.0,
        orderCount: json['orderCount'] as int? ?? 0,
        averageOrderValue:
            (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
        shippingAmount: (json['shippingAmount'] as num?)?.toDouble() ?? 0.0,
        refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
        cancelledOrderCount: json['cancelledOrderCount'] as int? ?? 0,
        trend: (json['trend'] as List<dynamic>?)
                ?.map(
                    (e) => SalesTrendModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'grossSales': grossSales,
        'netSales': netSales,
        'orderCount': orderCount,
        'averageOrderValue': averageOrderValue,
        'discountAmount': discountAmount,
        'taxAmount': taxAmount,
        'shippingAmount': shippingAmount,
        'refundAmount': refundAmount,
        'cancelledOrderCount': cancelledOrderCount,
        'trend': trend.map((e) => e.toJson()).toList(),
      };
}

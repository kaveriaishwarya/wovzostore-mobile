class AnalyticsSnapshotModel {
  final String id;
  final int period;
  final String periodStart;
  final String periodEnd;
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final int cancelledOrders;
  final double refundAmount;
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final double conversionRate;
  final double inventoryValue;
  final int lowStockCount;
  final double averageRating;
  final int reviewCount;
  final String createdAtUtc;
  final String? updatedAtUtc;

  const AnalyticsSnapshotModel({
    required this.id,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.cancelledOrders,
    required this.refundAmount,
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.conversionRate,
    required this.inventoryValue,
    required this.lowStockCount,
    required this.averageRating,
    required this.reviewCount,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  factory AnalyticsSnapshotModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSnapshotModel(
      id: json['id'] as String? ?? '',
      period: (json['period'] as num?)?.toInt() ?? 0,
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      newCustomers: (json['newCustomers'] as num?)?.toInt() ?? 0,
      returningCustomers: (json['returningCustomers'] as num?)?.toInt() ?? 0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
      inventoryValue: (json['inventoryValue'] as num?)?.toDouble() ?? 0.0,
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      createdAtUtc: json['createdAtUtc'] as String? ?? '',
      updatedAtUtc: json['updatedAtUtc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'cancelledOrders': cancelledOrders,
      'refundAmount': refundAmount,
      'totalCustomers': totalCustomers,
      'newCustomers': newCustomers,
      'returningCustomers': returningCustomers,
      'conversionRate': conversionRate,
      'inventoryValue': inventoryValue,
      'lowStockCount': lowStockCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAtUtc': createdAtUtc,
      'updatedAtUtc': updatedAtUtc,
    };
  }
}

class DashboardSummaryModel {
  final AnalyticsSnapshotModel? latestDaily;
  final AnalyticsSnapshotModel? latestWeekly;
  final AnalyticsSnapshotModel? latestMonthly;

  const DashboardSummaryModel({
    this.latestDaily,
    this.latestWeekly,
    this.latestMonthly,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      latestDaily: json['latestDaily'] != null
          ? AnalyticsSnapshotModel.fromJson(json['latestDaily'] as Map<String, dynamic>)
          : null,
      latestWeekly: json['latestWeekly'] != null
          ? AnalyticsSnapshotModel.fromJson(json['latestWeekly'] as Map<String, dynamic>)
          : null,
      latestMonthly: json['latestMonthly'] != null
          ? AnalyticsSnapshotModel.fromJson(json['latestMonthly'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestDaily': latestDaily?.toJson(),
      'latestWeekly': latestWeekly?.toJson(),
      'latestMonthly': latestMonthly?.toJson(),
    };
  }
}

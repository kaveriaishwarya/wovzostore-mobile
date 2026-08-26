/// Model representing brand performance item matching backend `BrandPerformanceDto`.
class BrandPerformanceModel {
  final String? brandId;
  final String brandName;
  final int unitsSold;
  final double revenue;

  const BrandPerformanceModel({
    this.brandId,
    required this.brandName,
    required this.unitsSold,
    required this.revenue,
  });

  factory BrandPerformanceModel.fromJson(Map<String, dynamic> json) =>
      BrandPerformanceModel(
        brandId: json['brandId'] as String?,
        brandName: json['brandName'] as String? ?? '',
        unitsSold: json['unitsSold'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'brandId': brandId,
        'brandName': brandName,
        'unitsSold': unitsSold,
        'revenue': revenue,
      };
}

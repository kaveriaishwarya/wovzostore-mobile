/// Model representing product performance item matching backend `ProductPerformanceDto`.
class ProductPerformanceModel {
  final String productId;
  final String productName;
  final String? variantId;
  final String? variantName;
  final int unitsSold;
  final double revenue;
  final double averageSellingPrice;

  const ProductPerformanceModel({
    required this.productId,
    required this.productName,
    this.variantId,
    this.variantName,
    required this.unitsSold,
    required this.revenue,
    required this.averageSellingPrice,
  });

  factory ProductPerformanceModel.fromJson(Map<String, dynamic> json) =>
      ProductPerformanceModel(
        productId: json['productId'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        variantId: json['variantId'] as String?,
        variantName: json['variantName'] as String?,
        unitsSold: json['unitsSold'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
        averageSellingPrice:
            (json['averageSellingPrice'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'variantId': variantId,
        'variantName': variantName,
        'unitsSold': unitsSold,
        'revenue': revenue,
        'averageSellingPrice': averageSellingPrice,
      };
}

/// Model representing category performance item matching backend `CategoryPerformanceDto`.
class CategoryPerformanceModel {
  final String categoryId;
  final String categoryName;
  final int unitsSold;
  final double revenue;

  const CategoryPerformanceModel({
    required this.categoryId,
    required this.categoryName,
    required this.unitsSold,
    required this.revenue,
  });

  factory CategoryPerformanceModel.fromJson(Map<String, dynamic> json) =>
      CategoryPerformanceModel(
        categoryId: json['categoryId'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        unitsSold: json['unitsSold'] as int? ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'unitsSold': unitsSold,
        'revenue': revenue,
      };
}

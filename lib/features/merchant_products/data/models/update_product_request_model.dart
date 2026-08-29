class UpdateProductRequestModel {
  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final double basePrice;
  final String? brandId;
  final String? description;
  final String? shortDescription;
  final String? tags;
  final bool isFeatured;
  final String? hsnCode;
  final double taxRatePercentage;
  final bool isTaxInclusive;

  const UpdateProductRequestModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.basePrice,
    this.brandId,
    this.description,
    this.shortDescription,
    this.tags,
    this.isFeatured = false,
    this.hsnCode,
    this.taxRatePercentage = 0.0,
    this.isTaxInclusive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'categoryId': categoryId,
      'basePrice': basePrice,
      if (brandId != null && brandId!.isNotEmpty) 'brandId': brandId,
      if (description != null) 'description': description,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (tags != null) 'tags': tags,
      'isFeatured': isFeatured,
      if (hsnCode != null && hsnCode!.isNotEmpty) 'hsnCode': hsnCode,
      'taxRatePercentage': taxRatePercentage,
      'isTaxInclusive': isTaxInclusive,
    };
  }
}

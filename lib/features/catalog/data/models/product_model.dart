import 'product_image_model.dart';
import 'product_variant_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? shortDescription;
  final String categoryId;
  final String? brandId;
  final String? brand;
  final int status;
  final double basePrice;
  final String? tags;
  final bool isActive;
  final bool isFeatured;
  final String? hsnCode;
  final double taxRatePercentage;
  final bool isTaxInclusive;
  final List<ProductVariantModel> variants;
  final List<ProductImageModel> images;

  const ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.shortDescription,
    required this.categoryId,
    this.brandId,
    this.brand,
    required this.status,
    required this.basePrice,
    this.tags,
    required this.isActive,
    required this.isFeatured,
    this.hsnCode,
    this.taxRatePercentage = 0.0,
    this.isTaxInclusive = false,
    this.variants = const [],
    this.images = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      shortDescription: json['shortDescription'] as String?,
      categoryId: json['categoryId'] as String? ?? '',
      brandId: json['brandId'] as String?,
      brand: json['brand'] as String?,
      status: (json['status'] as num?)?.toInt() ?? 0,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      tags: json['tags'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      hsnCode: json['hsnCode'] as String?,
      taxRatePercentage: (json['taxRatePercentage'] as num?)?.toDouble() ?? 0.0,
      isTaxInclusive: json['isTaxInclusive'] as bool? ?? false,
      variants: json['variants'] != null
          ? (json['variants'] as List<dynamic>)
              .map((item) => ProductVariantModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
      images: json['images'] != null
          ? (json['images'] as List<dynamic>)
              .map((item) => ProductImageModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'shortDescription': shortDescription,
      'categoryId': categoryId,
      'brandId': brandId,
      'brand': brand,
      'status': status,
      'basePrice': basePrice,
      'tags': tags,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'hsnCode': hsnCode,
      'taxRatePercentage': taxRatePercentage,
      'isTaxInclusive': isTaxInclusive,
      'variants': variants.map((v) => v.toJson()).toList(),
      'images': images.map((i) => i.toJson()).toList(),
    };
  }

  ProductImageModel? get primaryImage {
    return images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.isNotEmpty
          ? images.first
          : const ProductImageModel(
              id: '',
              productId: '',
              imageUrl: '',
              sortOrder: 0,
              isPrimary: false,
            ),
    );
  }
}

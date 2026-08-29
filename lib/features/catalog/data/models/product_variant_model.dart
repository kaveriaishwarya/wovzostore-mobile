class ProductVariantModel {
  final String id;
  final String productId;
  final String sku;
  final String? barcode;
  final String name;
  final double price;
  final double? compareAtPrice;
  final double? weight;
  final String? dimensions;
  final String? imageUrl;
  final String? attributes;
  final bool isActive;
  final int stockQuantity;

  const ProductVariantModel({
    required this.id,
    required this.productId,
    required this.sku,
    this.barcode,
    required this.name,
    required this.price,
    this.compareAtPrice,
    this.weight,
    this.dimensions,
    this.imageUrl,
    this.attributes,
    required this.isActive,
    required this.stockQuantity,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      sku: json['sku'] as String? ?? json['SKU'] as String? ?? '',
      barcode: json['barcode'] as String?,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
      imageUrl: json['imageUrl'] as String?,
      attributes: json['attributes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sku': sku,
      'barcode': barcode,
      'name': name,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'weight': weight,
      'dimensions': dimensions,
      'imageUrl': imageUrl,
      'attributes': attributes,
      'isActive': isActive,
      'stockQuantity': stockQuantity,
    };
  }
}

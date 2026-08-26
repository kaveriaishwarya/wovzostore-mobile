class ProductImageModel {
  final String id;
  final String productId;
  final String imageUrl;
  final String? altText;
  final int sortOrder;
  final bool isPrimary;

  const ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    this.altText,
    required this.sortOrder,
    required this.isPrimary,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      altText: json['altText'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
      'altText': altText,
      'sortOrder': sortOrder,
      'isPrimary': isPrimary,
    };
  }
}

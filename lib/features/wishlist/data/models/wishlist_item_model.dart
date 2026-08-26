class WishlistItemModel {
  final String id;
  final String productId;
  final String variantId;
  final String addedAtUtc;
  final String productName;
  final String? productImageUrl;
  final String variantName;
  final double price;
  final double? compareAtPrice;
  final bool isAvailable;

  const WishlistItemModel({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.addedAtUtc,
    required this.productName,
    this.productImageUrl,
    required this.variantName,
    required this.price,
    this.compareAtPrice,
    required this.isAvailable,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      variantId: json['variantId'] as String? ?? '',
      addedAtUtc: json['addedAtUtc'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productImageUrl: json['productImageUrl'] as String?,
      variantName: json['variantName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'addedAtUtc': addedAtUtc,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'variantName': variantName,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'isAvailable': isAvailable,
    };
  }
}

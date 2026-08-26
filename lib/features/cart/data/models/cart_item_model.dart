class CartItemModel {
  final String id;
  final String productId;
  final String productVariantId;
  final String sku;
  final String productName;
  final String variantName;
  final int quantity;
  final double unitPrice;
  final double? comparePrice;
  final double lineTotal;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productVariantId,
    required this.sku,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.unitPrice,
    this.comparePrice,
    required this.lineTotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String? ?? '',
      sku: json['sku'] as String? ?? json['SKU'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      variantName: json['variantName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      comparePrice: (json['comparePrice'] as num?)?.toDouble(),
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productVariantId': productVariantId,
      'sku': sku,
      'productName': productName,
      'variantName': variantName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'comparePrice': comparePrice,
      'lineTotal': lineTotal,
    };
  }
}

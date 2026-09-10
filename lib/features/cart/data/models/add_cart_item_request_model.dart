class AddCartItemRequestModel {
  final String productVariantId;
  final String productId;
  final String skuSnapshot;
  final String productNameSnapshot;
  final String variantNameSnapshot;
  final double unitPriceSnapshot;
  final double? comparePriceSnapshot;
  final int quantity;

  const AddCartItemRequestModel({
    required this.productVariantId,
    required this.productId,
    required this.skuSnapshot,
    required this.productNameSnapshot,
    required this.variantNameSnapshot,
    required this.unitPriceSnapshot,
    this.comparePriceSnapshot,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productVariantId': productVariantId,
      'productId': productId,
      'skuSnapshot': skuSnapshot,
      'productNameSnapshot': productNameSnapshot,
      'variantNameSnapshot': variantNameSnapshot,
      'unitPriceSnapshot': unitPriceSnapshot,
      'comparePriceSnapshot': comparePriceSnapshot,
      'quantity': quantity,
    };
  }
}

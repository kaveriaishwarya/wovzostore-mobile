class AddWishlistItemRequestModel {
  final String productId;
  final String variantId;
  final String? notes;

  const AddWishlistItemRequestModel({
    required this.productId,
    required this.variantId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variantId': variantId,
      'notes': notes,
    };
  }
}

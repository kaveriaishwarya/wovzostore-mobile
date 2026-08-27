import 'package:equatable/equatable.dart';

class PosCartItemModel extends Equatable {
  final String productVariantId;
  final String productId;
  final String sku;
  final String productName;
  final String variantName;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;

  const PosCartItemModel({
    required this.productVariantId,
    required this.productId,
    required this.sku,
    required this.productName,
    required this.variantName,
    required this.unitPrice,
    this.quantity = 1,
    this.imageUrl,
  });

  double get lineTotal => unitPrice * quantity;

  PosCartItemModel copyWith({
    String? productVariantId,
    String? productId,
    String? sku,
    String? productName,
    String? variantName,
    double? unitPrice,
    int? quantity,
    String? imageUrl,
  }) {
    return PosCartItemModel(
      productVariantId: productVariantId ?? this.productVariantId,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productVariantId': productVariantId,
      'productId': productId,
      'sku': sku,
      'productName': productName,
      'variantName': variantName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
      'imageUrl': imageUrl,
    };
  }

  factory PosCartItemModel.fromJson(Map<String, dynamic> json) {
    return PosCartItemModel(
      productVariantId: json['productVariantId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      variantName: json['variantName'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        productVariantId,
        productId,
        sku,
        productName,
        variantName,
        unitPrice,
        quantity,
        imageUrl,
      ];
}

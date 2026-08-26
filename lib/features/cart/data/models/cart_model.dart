import 'cart_item_model.dart';

class CartModel {
  final String id;
  final String customerId;
  final int status;
  final int totalQuantity;
  final double subtotal;
  final double discountTotal;
  final double grandTotal;
  final List<CartItemModel> items;

  const CartModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.totalQuantity,
    required this.subtotal,
    required this.discountTotal,
    required this.grandTotal,
    this.items = const [],
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (json['discountTotal'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'status': status,
      'totalQuantity': totalQuantity,
      'subtotal': subtotal,
      'discountTotal': discountTotal,
      'grandTotal': grandTotal,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

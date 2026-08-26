import 'wishlist_item_model.dart';

class WishlistModel {
  final String id;
  final String customerId;
  final String? createdAtUtc;
  final String? updatedAtUtc;
  final int itemCount;
  final List<WishlistItemModel> items;

  const WishlistModel({
    required this.id,
    required this.customerId,
    this.createdAtUtc,
    this.updatedAtUtc,
    required this.itemCount,
    this.items = const [],
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      createdAtUtc: json['createdAtUtc'] as String?,
      updatedAtUtc: json['updatedAtUtc'] as String?,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => WishlistItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'createdAtUtc': createdAtUtc,
      'updatedAtUtc': updatedAtUtc,
      'itemCount': itemCount,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

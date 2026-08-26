import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/add_wishlist_item_request_model.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/wishlist_model.dart';

void main() {
  group('Wishlist Models Serialization Tests', () {
    test('WishlistItemModel.fromJson parses JSON correctly', () {
      final json = {
        'id': 'w_item1',
        'productId': 'p1',
        'variantId': 'v1',
        'addedAtUtc': '2026-08-26T00:00:00Z',
        'productName': 'Leather Jacket',
        'productImageUrl': 'https://example.com/j.jpg',
        'variantName': 'Brown / L',
        'price': 249.99,
        'compareAtPrice': 299.99,
        'isAvailable': true,
      };

      final item = WishlistItemModel.fromJson(json);
      expect(item.id, 'w_item1');
      expect(item.productName, 'Leather Jacket');
      expect(item.price, 249.99);
      expect(item.isAvailable, isTrue);
    });

    test('WishlistModel.fromJson parses nested wishlist items', () {
      final json = {
        'id': 'w1',
        'customerId': 'cust1',
        'itemCount': 1,
        'items': [
          {
            'id': 'w_item1',
            'productId': 'p1',
            'variantId': 'v1',
            'addedAtUtc': '2026-08-26T00:00:00Z',
            'productName': 'Leather Jacket',
            'variantName': 'Brown / L',
            'price': 249.99,
            'isAvailable': true,
          }
        ],
      };

      final wishlist = WishlistModel.fromJson(json);
      expect(wishlist.id, 'w1');
      expect(wishlist.itemCount, 1);
      expect(wishlist.items.length, 1);
      expect(wishlist.items.first.productName, 'Leather Jacket');
    });

    test('AddWishlistItemRequestModel.toJson serializes correctly', () {
      const request = AddWishlistItemRequestModel(
        productId: 'p1',
        variantId: 'v1',
        notes: 'Birthday gift',
      );

      final json = request.toJson();
      expect(json['productId'], 'p1');
      expect(json['variantId'], 'v1');
      expect(json['notes'], 'Birthday gift');
    });
  });
}

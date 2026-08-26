import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/cart/data/models/add_cart_item_request_model.dart';
import 'package:wovzo_mobile/features/cart/data/models/cart_item_model.dart';
import 'package:wovzo_mobile/features/cart/data/models/cart_model.dart';

void main() {
  group('Cart Models Serialization & Null Safety Tests', () {
    test('CartItemModel.fromJson parses JSON correctly', () {
      final json = {
        'id': 'item1',
        'productId': 'p1',
        'productVariantId': 'v1',
        'sku': 'SKU-001',
        'productName': 'Running Shoes',
        'variantName': 'Red / 10',
        'quantity': 2,
        'unitPrice': 99.99,
        'comparePrice': 129.99,
        'lineTotal': 199.98,
      };

      final item = CartItemModel.fromJson(json);
      expect(item.id, 'item1');
      expect(item.sku, 'SKU-001');
      expect(item.quantity, 2);
      expect(item.unitPrice, 99.99);
      expect(item.comparePrice, 129.99);
      expect(item.lineTotal, 199.98);
    });

    test('CartModel.fromJson parses nested items correctly', () {
      final json = {
        'id': 'cart1',
        'customerId': 'cust1',
        'status': 1,
        'totalQuantity': 2,
        'subtotal': 199.98,
        'discountTotal': 0.0,
        'grandTotal': 199.98,
        'items': [
          {
            'id': 'item1',
            'productId': 'p1',
            'productVariantId': 'v1',
            'sku': 'SKU-001',
            'productName': 'Running Shoes',
            'variantName': 'Red / 10',
            'quantity': 2,
            'unitPrice': 99.99,
            'lineTotal': 199.98,
          }
        ],
      };

      final cart = CartModel.fromJson(json);
      expect(cart.id, 'cart1');
      expect(cart.customerId, 'cust1');
      expect(cart.totalQuantity, 2);
      expect(cart.items.length, 1);
      expect(cart.items.first.productName, 'Running Shoes');
    });

    test('AddCartItemRequestModel.toJson serializes correct JSON body', () {
      const request = AddCartItemRequestModel(
        customerId: 'cust1',
        productVariantId: 'v1',
        productId: 'p1',
        skuSnapshot: 'SKU-001',
        productNameSnapshot: 'Running Shoes',
        variantNameSnapshot: 'Red / 10',
        unitPriceSnapshot: 99.99,
        comparePriceSnapshot: 129.99,
        quantity: 2,
      );

      final json = request.toJson();
      expect(json['customerId'], 'cust1');
      expect(json['productVariantId'], 'v1');
      expect(json['quantity'], 2);
      expect(json['unitPriceSnapshot'], 99.99);
    });
  });
}

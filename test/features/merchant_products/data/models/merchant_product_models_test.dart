import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/create_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/inventory_adjustment_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/update_product_request_model.dart';

void main() {
  group('Merchant Product Models Serialization Tests', () {
    test('CreateProductRequestModel serializes correctly to JSON', () {
      const model = CreateProductRequestModel(
        name: 'Cotton T-Shirt',
        categoryId: 'cat-123',
        basePrice: 499.0,
        slug: 'cotton-tshirt',
        description: '100% Cotton Premium T-Shirt',
        isFeatured: true,
        initialVariants: [
          AddVariantRequestModel(
            sku: 'TS-RED-M',
            name: 'Red Medium',
            price: 499.0,
            compareAtPrice: 699.0,
          )
        ],
      );

      final json = model.toJson();
      expect(json['name'], 'Cotton T-Shirt');
      expect(json['categoryId'], 'cat-123');
      expect(json['basePrice'], 499.0);
      expect(json['isFeatured'], true);
      expect((json['initialVariants'] as List).length, 1);
    });

    test('UpdateProductRequestModel serializes correctly to JSON', () {
      const model = UpdateProductRequestModel(
        id: 'prod-123',
        name: 'Updated T-Shirt',
        slug: 'updated-tshirt',
        categoryId: 'cat-123',
        basePrice: 599.0,
      );

      final json = model.toJson();
      expect(json['id'], 'prod-123');
      expect(json['name'], 'Updated T-Shirt');
      expect(json['basePrice'], 599.0);
    });

    test('SetInventoryQuantityRequestModel serializes correctly to JSON', () {
      const model = SetInventoryQuantityRequestModel(quantity: 50);
      final json = model.toJson();
      expect(json['quantity'], 50);
    });

    test('AdjustInventoryQuantityRequestModel serializes correctly to JSON', () {
      const model = AdjustInventoryQuantityRequestModel(adjustment: -5);
      final json = model.toJson();
      expect(json['adjustment'], -5);
    });
  });
}

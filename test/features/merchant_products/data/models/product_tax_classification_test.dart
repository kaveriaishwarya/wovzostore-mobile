import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/create_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/update_product_request_model.dart';

void main() {
  group('Product GST Tax Classification Model Mapping Tests', () {
    test('ProductModel parses and serializes GST tax fields', () {
      final json = {
        'id': 'prod-123',
        'name': 'Casual Cotton Shirt',
        'slug': 'casual-cotton-shirt',
        'categoryId': 'cat-1',
        'status': 1,
        'basePrice': 1000.0,
        'isActive': true,
        'isFeatured': false,
        'hsnCode': '6205',
        'taxRatePercentage': 18.0,
        'isTaxInclusive': true,
      };

      final model = ProductModel.fromJson(json);

      expect(model.id, 'prod-123');
      expect(model.hsnCode, '6205');
      expect(model.taxRatePercentage, 18.0);
      expect(model.isTaxInclusive, true);

      final serialized = model.toJson();
      expect(serialized['hsnCode'], '6205');
      expect(serialized['taxRatePercentage'], 18.0);
      expect(serialized['isTaxInclusive'], true);
    });

    test('CreateProductRequestModel includes GST parameters in JSON', () {
      const request = CreateProductRequestModel(
        name: 'New Jeans',
        categoryId: 'cat-2',
        basePrice: 1500.0,
        hsnCode: '6203',
        taxRatePercentage: 12.0,
        isTaxInclusive: false,
      );

      final json = request.toJson();

      expect(json['name'], 'New Jeans');
      expect(json['hsnCode'], '6203');
      expect(json['taxRatePercentage'], 12.0);
      expect(json['isTaxInclusive'], false);
    });

    test('UpdateProductRequestModel includes GST parameters in JSON', () {
      const request = UpdateProductRequestModel(
        id: 'prod-123',
        name: 'Updated Jeans',
        slug: 'updated-jeans',
        categoryId: 'cat-2',
        basePrice: 1600.0,
        hsnCode: '6203',
        taxRatePercentage: 12.0,
        isTaxInclusive: true,
      );

      final json = request.toJson();

      expect(json['id'], 'prod-123');
      expect(json['hsnCode'], '6203');
      expect(json['taxRatePercentage'], 12.0);
      expect(json['isTaxInclusive'], true);
    });
  });
}

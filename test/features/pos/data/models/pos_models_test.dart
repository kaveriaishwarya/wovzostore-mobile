import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_cart_item_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_customer_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_sale_result_model.dart';

void main() {
  group('POS Models Tests', () {
    test('PosCartItemModel calculates lineTotal and serializes correctly', () {
      const item = PosCartItemModel(
        productVariantId: 'var-1',
        productId: 'prod-1',
        sku: 'SKU-001',
        productName: 'Sample Product',
        variantName: 'Size M',
        unitPrice: 250.0,
        quantity: 2,
      );

      expect(item.lineTotal, 500.0);
      final json = item.toJson();
      expect(json['lineTotal'], 500.0);

      final deserialized = PosCartItemModel.fromJson(json);
      expect(deserialized.lineTotal, 500.0);
    });

    test('PosCustomerModel.walkIn default value', () {
      expect(PosCustomerModel.walkIn.fullName, 'Walk-In Customer');
      expect(PosCustomerModel.walkIn.id, '00000000-0000-0000-0000-000000000000');
    });

    test('PosSaleResultModel serialization', () {
      final json = {
        'orderId': 'ord-999',
        'orderNumber': 'WVZ-POS-001',
        'grandTotal': 1200.0,
        'paymentMethod': 1,
        'paymentMethodName': 'Cash',
        'createdAt': '2026-08-28T00:00:00.000Z',
      };

      final result = PosSaleResultModel.fromJson(json);
      expect(result.orderId, 'ord-999');
      expect(result.grandTotal, 1200.0);
      expect(result.paymentMethodName, 'Cash');
    });
  });
}

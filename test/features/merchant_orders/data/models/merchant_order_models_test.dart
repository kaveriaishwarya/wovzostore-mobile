import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_list_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_transition_request_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/tax_invoice_dto.dart';

void main() {
  group('Merchant Order Models Serialization Tests', () {
    test('OrderListModel.fromJson parses JSON correctly', () {
      final json = {
        'id': 'ord-123',
        'orderNumber': 'WVZ-20260828-0001',
        'customerId': 'cust-456',
        'status': 2,
        'statusName': 'Confirmed',
        'paymentStatus': 1,
        'paymentStatusName': 'Paid',
        'paymentMethod': 1,
        'paymentMethodName': 'Online',
        'grandTotal': 1499.50,
        'currency': 'INR',
        'createdAt': '2026-08-28T00:00:00.000Z',
      };

      final model = OrderListModel.fromJson(json);
      expect(model.id, 'ord-123');
      expect(model.orderNumber, 'WVZ-20260828-0001');
      expect(model.status, 2);
      expect(model.statusName, 'Confirmed');
      expect(model.grandTotal, 1499.50);
    });

    test('OrderModel.fromJson parses nested order items and status history', () {
      final json = {
        'id': 'ord-123',
        'orderNumber': 'WVZ-20260828-0001',
        'customerId': 'cust-456',
        'checkoutId': 'chk-789',
        'status': 2,
        'statusName': 'Confirmed',
        'paymentStatus': 1,
        'paymentStatusName': 'Paid',
        'paymentMethod': 1,
        'paymentMethodName': 'Online',
        'summary': {
          'subtotal': 1400.0,
          'discountTotal': 0.0,
          'shippingFee': 99.5,
          'taxAmount': 0.0,
          'grandTotal': 1499.5,
          'currency': 'INR',
        },
        'shippingAddress': {
          'fullName': 'John Doe',
          'phoneNumber': '9876543210',
          'line1': '123 Main Street',
          'city': 'Bangalore',
          'state': 'Karnataka',
          'pinCode': '560001',
          'country': 'India',
        },
        'items': [
          {
            'id': 'item-1',
            'orderId': 'ord-123',
            'productVariantId': 'var-1',
            'productId': 'prod-1',
            'sku': 'SKU-001',
            'productName': 'Blue Shirt',
            'variantName': 'Size M',
            'unitPrice': 700.0,
            'quantity': 2,
            'lineTotal': 1400.0,
          }
        ],
        'statusHistory': [
          {
            'id': 'hist-1',
            'orderId': 'ord-123',
            'status': 2,
            'statusName': 'Confirmed',
            'comment': 'Order confirmed by store manager',
            'changedAt': '2026-08-28T00:00:00.000Z',
          }
        ],
        'createdAt': '2026-08-28T00:00:00.000Z',
      };

      final model = OrderModel.fromJson(json);
      expect(model.id, 'ord-123');
      expect(model.items.length, 1);
      expect(model.items.first.productName, 'Blue Shirt');
      expect(model.statusHistory.length, 1);
      expect(model.shippingAddress?.fullName, 'John Doe');
    });

    test('OrderStatusTransitionRequestModel serializes correctly to JSON', () {
      const request = OrderStatusTransitionRequestModel(
        comment: 'Packed and verified',
        adminId: 'admin-1',
      );
      final json = request.toJson();
      expect(json['comment'], 'Packed and verified');
      expect(json['adminId'], 'admin-1');
    });

    test('CancelOrderRequestModel serializes correctly to JSON', () {
      const request = CancelOrderRequestModel(reason: 'Out of stock');
      final json = request.toJson();
      expect(json['reason'], 'Out of stock');
    });

    test('TaxInvoiceDto instantiates and holds backend DTO values', () {
      final now = DateTime.now();
      final dto = TaxInvoiceDto(
        orderId: 'ord-123',
        orderNumber: 'WVZ-0001',
        invoiceNumber: 'INV-20260828-WVZ-0001',
        invoiceDate: now,
        contentType: 'text/html; charset=utf-8',
        fileBytes: Uint8List.fromList([1, 2, 3]),
        htmlContent: '<html>Test</html>',
      );

      expect(dto.orderId, 'ord-123');
      expect(dto.invoiceNumber, 'INV-20260828-WVZ-0001');
      expect(dto.contentType, 'text/html; charset=utf-8');
      expect(dto.fileBytes.length, 3);
      expect(dto.htmlContent, '<html>Test</html>');
    });
  });
}

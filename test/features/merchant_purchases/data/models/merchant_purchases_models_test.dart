import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/supplier_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/purchase_order_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/stock_movement_model.dart';

void main() {
  group('SupplierModel', () {
    test('fromJson and toJson should parse correctly', () {
      final json = {
        'id': 'sup-101',
        'name': 'Acme Corp',
        'contactPerson': 'John Doe',
        'email': 'john@acme.com',
        'phone': '9876543210',
        'address': '123 Main St',
        'gstin': '27AAAAA0000A1Z5',
        'isActive': true,
        'createdAt': '2026-08-29T10:00:00.000Z',
        'updatedAt': '2026-08-29T12:00:00.000Z',
      };

      final model = SupplierModel.fromJson(json);

      expect(model.id, 'sup-101');
      expect(model.name, 'Acme Corp');
      expect(model.contactPerson, 'John Doe');
      expect(model.email, 'john@acme.com');
      expect(model.phone, '9876543210');
      expect(model.address, '123 Main St');
      expect(model.gstin, '27AAAAA0000A1Z5');
      expect(model.isActive, true);

      final backToJson = model.toJson();
      expect(backToJson['id'], 'sup-101');
      expect(backToJson['name'], 'Acme Corp');
    });

    test('CreateSupplierRequestModel and UpdateSupplierRequestModel toJson', () {
      const createReq = CreateSupplierRequestModel(
        name: 'Acme Corp',
        contactPerson: 'John',
        email: 'john@acme.com',
        phone: '9876543210',
        address: '123 Main St',
        gstin: '27AAAAA0000A1Z5',
      );
      final json = createReq.toJson();
      expect(json['name'], 'Acme Corp');
      expect(json['gstin'], '27AAAAA0000A1Z5');

      const updateReq = UpdateSupplierRequestModel(
        name: 'Acme Inc',
      );
      expect(updateReq.toJson()['name'], 'Acme Inc');
    });
  });

  group('PurchaseOrderModel & Items', () {
    test('PurchaseOrderStatus enum values mapping', () {
      expect(PurchaseOrderStatus.fromValue(1), PurchaseOrderStatus.draft);
      expect(PurchaseOrderStatus.fromValue(2), PurchaseOrderStatus.ordered);
      expect(PurchaseOrderStatus.fromValue(3), PurchaseOrderStatus.partiallyReceived);
      expect(PurchaseOrderStatus.fromValue(4), PurchaseOrderStatus.received);
      expect(PurchaseOrderStatus.fromValue(5), PurchaseOrderStatus.cancelled);
      expect(PurchaseOrderStatus.fromValue(999), PurchaseOrderStatus.draft);
    });

    test('PurchaseOrderModel fromJson and toJson', () {
      final json = {
        'id': 'po-201',
        'orderNumber': 'WVZ-PO-20260829-0001',
        'supplierId': 'sup-101',
        'supplierName': 'Acme Corp',
        'status': 2,
        'statusName': 'Ordered',
        'totalAmount': 15000.0,
        'expectedDeliveryDate': '2026-09-05T00:00:00.000Z',
        'notes': 'Rush Order',
        'createdByAdminId': 'admin-1',
        'items': [
          {
            'id': 'item-1',
            'productVariantId': 'var-1',
            'variantName': 'Red M',
            'sku': 'TSHIRT-RED-M',
            'quantityOrdered': 50,
            'quantityReceived': 20,
            'unitCost': 300.0,
            'totalCost': 15000.0,
            'isFullyReceived': false,
          }
        ],
        'createdAt': '2026-08-29T10:00:00.000Z',
      };

      final model = PurchaseOrderModel.fromJson(json);

      expect(model.id, 'po-201');
      expect(model.orderNumber, 'WVZ-PO-20260829-0001');
      expect(model.supplierId, 'sup-101');
      expect(model.status, PurchaseOrderStatus.ordered);
      expect(model.totalAmount, 15000.0);
      expect(model.items.length, 1);
      expect(model.items.first.quantityOrdered, 50);
      expect(model.items.first.quantityReceived, 20);

      final backToJson = model.toJson();
      expect(backToJson['id'], 'po-201');
      expect(backToJson['status'], 2);
    });

    test('Request models toJson serialization', () {
      const createPoReq = CreatePurchaseOrderRequestModel(
        supplierId: 'sup-101',
        notes: 'Test PO',
        items: [
          CreatePurchaseOrderItemRequestModel(
            productVariantId: 'var-1',
            quantityOrdered: 50,
            unitCost: 300.0,
          )
        ],
      );
      expect(createPoReq.toJson()['supplierId'], 'sup-101');
      expect((createPoReq.toJson()['items'] as List).length, 1);

      const receiveReq = ReceivePurchaseItemsRequestModel(
        items: [
          ReceivePurchaseItemRequestModel(
            itemId: 'item-1',
            quantityToReceive: 20,
          )
        ],
        notes: 'Batch 1 received',
      );
      expect(receiveReq.toJson()['notes'], 'Batch 1 received');

      const cancelReq = CancelPurchaseOrderRequestModel(reason: 'Out of budget');
      expect(cancelReq.toJson()['reason'], 'Out of budget');
    });
  });

  group('StockMovementModel', () {
    test('StockMovementType enum mapping and StockMovementModel fromJson', () {
      expect(StockMovementType.fromValue(1), StockMovementType.purchase);
      expect(StockMovementType.fromValue(2), StockMovementType.sale);
      expect(StockMovementType.fromValue(3), StockMovementType.adjustment);
      expect(StockMovementType.fromValue(4), StockMovementType.returnType);

      final json = {
        'id': 'sm-301',
        'productVariantId': 'var-1',
        'variantName': 'Red M',
        'sku': 'TSHIRT-RED-M',
        'movementType': 1,
        'movementTypeName': 'Purchase',
        'quantityChange': 20,
        'previousQuantity': 10,
        'newQuantity': 30,
        'referenceId': 'po-201',
        'notes': 'Received batch 1',
        'createdByAdminId': 'admin-1',
        'createdAt': '2026-08-29T10:00:00.000Z',
      };

      final model = StockMovementModel.fromJson(json);

      expect(model.id, 'sm-301');
      expect(model.movementType, StockMovementType.purchase);
      expect(model.quantityChange, 20);
      expect(model.previousQuantity, 10);
      expect(model.newQuantity, 30);
      expect(model.referenceId, 'po-201');

      final backToJson = model.toJson();
      expect(backToJson['movementType'], 1);
    });
  });
}

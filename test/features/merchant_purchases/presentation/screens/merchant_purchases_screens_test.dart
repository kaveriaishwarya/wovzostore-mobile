import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/supplier_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/purchase_order_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/stock_movement_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/domain/repositories/merchant_purchases_repository.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_supplier_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_purchase_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_purchase_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/stock_movement_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/screens/merchant_supplier_list_screen.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/screens/merchant_purchase_list_screen.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/screens/merchant_purchase_detail_screen.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/screens/goods_receiving_screen.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/screens/stock_movement_list_screen.dart';

class MockMerchantPurchasesRepository implements MerchantPurchasesRepository {
  final sampleSupplier = SupplierModel(
    id: 'sup-101',
    name: 'Acme Corp',
    contactPerson: 'John Doe',
    email: 'john@acme.com',
    phone: '9876543210',
    address: '123 Main St',
    gstin: '27AAAAA0000A1Z5',
    isActive: true,
    createdAt: DateTime.parse('2026-08-29T10:00:00.000Z'),
  );

  final samplePurchase = PurchaseOrderModel(
    id: 'po-201',
    orderNumber: 'WVZ-PO-20260829-0001',
    supplierId: 'sup-101',
    supplierName: 'Acme Corp',
    status: PurchaseOrderStatus.ordered,
    statusName: 'Ordered',
    totalAmount: 15000.0,
    expectedDeliveryDate: DateTime.parse('2026-09-05T00:00:00.000Z'),
    items: const [
      PurchaseOrderItemModel(
        id: 'item-1',
        productVariantId: 'var-1',
        variantName: 'Red M',
        sku: 'TSHIRT-RED-M',
        quantityOrdered: 50,
        quantityReceived: 10,
        unitCost: 300.0,
        totalCost: 15000.0,
        isFullyReceived: false,
      ),
    ],
    createdAt: DateTime.parse('2026-08-29T10:00:00.000Z'),
  );

  final sampleStockMovement = StockMovementModel(
    id: 'sm-301',
    productVariantId: 'var-1',
    variantName: 'Red M',
    sku: 'TSHIRT-RED-M',
    movementType: StockMovementType.purchase,
    movementTypeName: 'Purchase',
    quantityChange: 10,
    previousQuantity: 0,
    newQuantity: 10,
    referenceId: 'po-201',
    notes: 'Goods received batch 1',
    createdAt: DateTime.parse('2026-08-29T10:00:00.000Z'),
  );

  final sampleVariant = const ProductVariantModel(
    id: 'var-1',
    productId: 'prod-1',
    sku: 'TSHIRT-RED-M',
    barcode: '8901234567890',
    name: 'Red M',
    price: 500.0,
    isActive: true,
    stockQuantity: 10,
  );

  @override
  Future<PagedResult<SupplierModel>> getSuppliers({String? search, bool? isActive, int page = 1, int pageSize = 20}) async {
    return PagedResult(data: [sampleSupplier], pageNumber: page, pageSize: pageSize, totalCount: 1, totalPages: 1, hasPreviousPage: false, hasNextPage: false);
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async => sampleSupplier;

  @override
  Future<SupplierModel> createSupplier(CreateSupplierRequestModel request) async => sampleSupplier;

  @override
  Future<SupplierModel> updateSupplier(String id, UpdateSupplierRequestModel request) async => sampleSupplier;

  @override
  Future<void> activateSupplier(String id) async {}

  @override
  Future<void> deactivateSupplier(String id) async {}

  @override
  Future<PagedResult<PurchaseOrderModel>> getPurchases({String? supplierId, int? status, String? search, int page = 1, int pageSize = 20}) async {
    return PagedResult(data: [samplePurchase], pageNumber: page, pageSize: pageSize, totalCount: 1, totalPages: 1, hasPreviousPage: false, hasNextPage: false);
  }

  @override
  Future<PurchaseOrderModel> getPurchaseById(String id) async => samplePurchase;

  @override
  Future<PurchaseOrderModel> createPurchaseOrder(CreatePurchaseOrderRequestModel request) async => samplePurchase;

  @override
  Future<void> markAsOrdered(String id) async {}

  @override
  Future<PurchaseOrderModel> receiveItems(String id, ReceivePurchaseItemsRequestModel request) async => samplePurchase;

  @override
  Future<void> cancelPurchaseOrder(String id, {String? reason}) async {}

  @override
  Future<PagedResult<StockMovementModel>> getStockMovements({String? variantId, int? movementType, int page = 1, int pageSize = 20}) async {
    return PagedResult(data: [sampleStockMovement], pageNumber: page, pageSize: pageSize, totalCount: 1, totalPages: 1, hasPreviousPage: false, hasNextPage: false);
  }

  @override
  Future<ProductVariantModel> getVariantByBarcode(String barcode) async => sampleVariant;
}

void main() {
  late MockMerchantPurchasesRepository repository;

  setUp(() {
    repository = MockMerchantPurchasesRepository();
  });

  group('MerchantSupplierListScreen Widget Tests', () {
    testWidgets('renders search bar, filter chips, and supplier card', (tester) async {
      final cubit = MerchantSupplierCubit(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: MerchantSupplierListScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Suppliers'), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('add supplier button opens modal dialog', (tester) async {
      final cubit = MerchantSupplierCubit(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: MerchantSupplierListScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Add Supplier'), findsOneWidget);
      expect(find.text('Supplier Name *'), findsOneWidget);
    });
  });

  group('MerchantPurchaseListScreen Widget Tests', () {
    testWidgets('renders search bar, status chips, and purchase card', (tester) async {
      final cubit = MerchantPurchaseCubit(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: MerchantPurchaseListScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Purchase Orders'), findsOneWidget);
      expect(find.text('WVZ-PO-20260829-0001'), findsOneWidget);
      expect(find.text('Supplier: Acme Corp'), findsOneWidget);
    });
  });

  group('MerchantPurchaseDetailScreen Widget Tests', () {
    testWidgets('renders PO summary, items list, and action buttons', (tester) async {
      final cubit = MerchantPurchaseDetailCubit(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: MerchantPurchaseDetailScreen(purchaseId: 'po-201', cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Purchase Order Details'), findsOneWidget);
      expect(find.text('WVZ-PO-20260829-0001'), findsOneWidget);
      expect(find.text('Red M'), findsOneWidget);
      expect(find.text('Receive Goods'), findsOneWidget);
    });
  });

  group('GoodsReceivingScreen Widget Tests', () {
    testWidgets('renders receivable items form and submit button', (tester) async {
      final cubit = MerchantPurchaseDetailCubit(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: GoodsReceivingScreen(purchaseId: 'po-201', cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Goods Receiving'), findsOneWidget);
      expect(find.text('Confirm Goods Receiving'), findsOneWidget);
      expect(find.text('Red M'), findsOneWidget);
    });
  });

  group('StockMovementListScreen Widget Tests', () {
    testWidgets('renders movement list and filter chips', (tester) async {
      final cubit = StockMovementCubit(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: StockMovementListScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stock Movement Audit Log'), findsOneWidget);
      expect(find.text('Red M'), findsOneWidget);
      expect(find.text('Change: +10'), findsOneWidget);
    });
  });
}

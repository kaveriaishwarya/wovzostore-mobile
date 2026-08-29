import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/supplier_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/purchase_order_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/data/models/stock_movement_model.dart';
import 'package:wovzo_mobile/features/merchant_purchases/domain/repositories/merchant_purchases_repository.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_supplier_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_supplier_state.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_purchase_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_purchase_state.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_purchase_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/merchant_purchase_detail_state.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/stock_movement_cubit.dart';
import 'package:wovzo_mobile/features/merchant_purchases/presentation/bloc/stock_movement_state.dart';

class MockMerchantPurchasesRepository implements MerchantPurchasesRepository {
  bool shouldFail = false;

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
        quantityReceived: 0,
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
    quantityChange: 20,
    previousQuantity: 10,
    newQuantity: 30,
    referenceId: 'po-201',
    notes: 'Batch received',
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
    stockQuantity: 30,
  );

  @override
  Future<PagedResult<SupplierModel>> getSuppliers({
    String? search,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldFail) throw const ApiServerException(message: 'Network error');
    return PagedResult(
      data: [sampleSupplier],
      pageNumber: page,
      pageSize: pageSize,
      totalCount: 1,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    if (shouldFail) throw const ApiServerException(message: 'Supplier not found');
    return sampleSupplier;
  }

  @override
  Future<SupplierModel> createSupplier(CreateSupplierRequestModel request) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to create supplier');
    return SupplierModel(
      id: 'sup-102',
      name: request.name,
      contactPerson: request.contactPerson,
      email: request.email,
      phone: request.phone,
      address: request.address,
      gstin: request.gstin,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<SupplierModel> updateSupplier(
    String id,
    UpdateSupplierRequestModel request,
  ) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to update supplier');
    return SupplierModel(
      id: id,
      name: request.name,
      contactPerson: request.contactPerson,
      email: request.email,
      phone: request.phone,
      address: request.address,
      gstin: request.gstin,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> activateSupplier(String id) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to activate');
  }

  @override
  Future<void> deactivateSupplier(String id) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to deactivate');
  }

  @override
  Future<PagedResult<PurchaseOrderModel>> getPurchases({
    String? supplierId,
    int? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldFail) throw const ApiServerException(message: 'Network error');
    return PagedResult(
      data: [samplePurchase],
      pageNumber: page,
      pageSize: pageSize,
      totalCount: 1,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<PurchaseOrderModel> getPurchaseById(String id) async {
    if (shouldFail) throw const ApiServerException(message: 'PO not found');
    return samplePurchase;
  }

  @override
  Future<PurchaseOrderModel> createPurchaseOrder(
    CreatePurchaseOrderRequestModel request,
  ) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to create PO');
    return samplePurchase;
  }

  @override
  Future<void> markAsOrdered(String id) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to mark ordered');
  }

  @override
  Future<PurchaseOrderModel> receiveItems(
    String id,
    ReceivePurchaseItemsRequestModel request,
  ) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to receive items');
    return PurchaseOrderModel(
      id: id,
      orderNumber: samplePurchase.orderNumber,
      supplierId: samplePurchase.supplierId,
      supplierName: samplePurchase.supplierName,
      status: PurchaseOrderStatus.partiallyReceived,
      statusName: 'Partially Received',
      totalAmount: samplePurchase.totalAmount,
      items: [
        PurchaseOrderItemModel(
          id: 'item-1',
          productVariantId: 'var-1',
          variantName: 'Red M',
          sku: 'TSHIRT-RED-M',
          quantityOrdered: 50,
          quantityReceived: request.items.first.quantityToReceive,
          unitCost: 300.0,
          totalCost: 15000.0,
          isFullyReceived: false,
        )
      ],
      createdAt: samplePurchase.createdAt,
    );
  }

  @override
  Future<void> cancelPurchaseOrder(String id, {String? reason}) async {
    if (shouldFail) throw const ApiServerException(message: 'Failed to cancel PO');
  }

  @override
  Future<PagedResult<StockMovementModel>> getStockMovements({
    String? variantId,
    int? movementType,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldFail) throw const ApiServerException(message: 'Network error');
    return PagedResult(
      data: [sampleStockMovement],
      pageNumber: page,
      pageSize: pageSize,
      totalCount: 1,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<ProductVariantModel> getVariantByBarcode(String barcode) async {
    if (shouldFail) throw const ApiServerException(message: 'Barcode not found');
    return sampleVariant;
  }
}

void main() {
  late MockMerchantPurchasesRepository repository;

  setUp(() {
    repository = MockMerchantPurchasesRepository();
  });

  group('MerchantSupplierCubit', () {
    test('loadSuppliers should emit [Loading, Loaded] when successful', () async {
      final cubit = MerchantSupplierCubit(repository: repository);

      expectLater(
        cubit.stream,
        emitsInOrder([
          isA<MerchantSupplierLoading>(),
          isA<MerchantSupplierLoaded>().having((s) => s.suppliers.length, 'count', 1),
        ]),
      );

      await cubit.loadSuppliers();
    });

    test('createSupplier should update supplier list upon success', () async {
      final cubit = MerchantSupplierCubit(repository: repository);
      await cubit.loadSuppliers();

      const req = CreateSupplierRequestModel(
        name: 'New Supplier',
        email: 'new@supplier.com',
      );

      await cubit.createSupplier(req);

      final state = cubit.state as MerchantSupplierLoaded;
      expect(state.suppliers.length, 2);
      expect(state.suppliers.first.name, 'New Supplier');
      expect(state.actionSuccessMessage, contains('New Supplier'));
    });
  });

  group('MerchantPurchaseCubit', () {
    test('loadPurchases should emit [Loading, Loaded] when successful', () async {
      final cubit = MerchantPurchaseCubit(repository: repository);

      expectLater(
        cubit.stream,
        emitsInOrder([
          isA<MerchantPurchaseLoading>(),
          isA<MerchantPurchaseLoaded>().having((s) => s.purchases.length, 'count', 1),
        ]),
      );

      await cubit.loadPurchases();
    });

    test('markAsOrdered should update status to Ordered in loaded list', () async {
      final cubit = MerchantPurchaseCubit(repository: repository);
      await cubit.loadPurchases();

      await cubit.markAsOrdered('po-201');

      final state = cubit.state as MerchantPurchaseLoaded;
      expect(state.purchases.first.status, PurchaseOrderStatus.ordered);
      expect(state.actionSuccessMessage, contains('Ordered'));
    });
  });

  group('MerchantPurchaseDetailCubit (Receiving Operation)', () {
    test('loadPurchaseDetail should load PO details', () async {
      final cubit = MerchantPurchaseDetailCubit(repository: repository);

      await cubit.loadPurchaseDetail('po-201');

      expect(cubit.state, isA<MerchantPurchaseDetailLoaded>());
      final state = cubit.state as MerchantPurchaseDetailLoaded;
      expect(state.purchase.id, 'po-201');
    });

    test('receiveItems should call repository and update PO status to partiallyReceived', () async {
      final cubit = MerchantPurchaseDetailCubit(repository: repository);
      await cubit.loadPurchaseDetail('po-201');

      const receiveReq = ReceivePurchaseItemsRequestModel(
        items: [
          ReceivePurchaseItemRequestModel(itemId: 'item-1', quantityToReceive: 20),
        ],
        notes: 'Received initial batch',
      );

      await cubit.receiveItems(receiveReq);

      expect(cubit.state, isA<MerchantPurchaseDetailLoaded>());
      final state = cubit.state as MerchantPurchaseDetailLoaded;
      expect(state.purchase.status, PurchaseOrderStatus.partiallyReceived);
      expect(state.purchase.items.first.quantityReceived, 20);
      expect(state.actionSuccessMessage, contains('Items received successfully'));
    });
  });

  group('StockMovementCubit', () {
    test('loadStockMovements should load movement logs', () async {
      final cubit = StockMovementCubit(repository: repository);

      await cubit.loadStockMovements();

      expect(cubit.state, isA<StockMovementLoaded>());
      final state = cubit.state as StockMovementLoaded;
      expect(state.movements.length, 1);
      expect(state.movements.first.quantityChange, 20);
    });

    test('lookupBarcode should find variant and update state', () async {
      final cubit = StockMovementCubit(repository: repository);

      await cubit.lookupBarcode('8901234567890');

      expect(cubit.state, isA<StockMovementLoaded>());
      final state = cubit.state as StockMovementLoaded;
      expect(state.scannedVariant?.barcode, '8901234567890');
      expect(state.scannedVariant?.sku, 'TSHIRT-RED-M');
    });
  });
}

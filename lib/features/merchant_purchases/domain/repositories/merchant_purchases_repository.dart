import '../../../../features/analytics/data/models/paged_result_model.dart';
import '../../../../features/catalog/data/models/product_variant_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/models/stock_movement_model.dart';

abstract class MerchantPurchasesRepository {
  Future<PagedResult<SupplierModel>> getSuppliers({
    String? search,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  });

  Future<SupplierModel> getSupplierById(String id);

  Future<SupplierModel> createSupplier(CreateSupplierRequestModel request);

  Future<SupplierModel> updateSupplier(String id, UpdateSupplierRequestModel request);

  Future<void> activateSupplier(String id);

  Future<void> deactivateSupplier(String id);

  Future<PagedResult<PurchaseOrderModel>> getPurchases({
    String? supplierId,
    int? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  Future<PurchaseOrderModel> getPurchaseById(String id);

  Future<PurchaseOrderModel> createPurchaseOrder(CreatePurchaseOrderRequestModel request);

  Future<void> markAsOrdered(String id);

  Future<PurchaseOrderModel> receiveItems(
    String id,
    ReceivePurchaseItemsRequestModel request,
  );

  Future<void> cancelPurchaseOrder(String id, {String? reason});

  Future<PagedResult<StockMovementModel>> getStockMovements({
    String? variantId,
    int? movementType,
    int page = 1,
    int pageSize = 20,
  });

  Future<ProductVariantModel> getVariantByBarcode(String barcode);
}

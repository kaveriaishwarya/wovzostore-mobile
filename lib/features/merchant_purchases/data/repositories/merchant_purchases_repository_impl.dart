import '../../../../features/analytics/data/models/paged_result_model.dart';
import '../../../../features/catalog/data/models/product_variant_model.dart';
import '../../domain/repositories/merchant_purchases_repository.dart';
import '../datasources/merchant_purchases_remote_datasource.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';
import '../models/stock_movement_model.dart';

class MerchantPurchasesRepositoryImpl implements MerchantPurchasesRepository {
  final MerchantPurchasesRemoteDataSource remoteDataSource;

  const MerchantPurchasesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PagedResult<SupplierModel>> getSuppliers({
    String? search,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getSuppliers(
      search: search,
      isActive: isActive,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<SupplierModel> getSupplierById(String id) {
    return remoteDataSource.getSupplierById(id);
  }

  @override
  Future<SupplierModel> createSupplier(CreateSupplierRequestModel request) {
    return remoteDataSource.createSupplier(request);
  }

  @override
  Future<SupplierModel> updateSupplier(
    String id,
    UpdateSupplierRequestModel request,
  ) {
    return remoteDataSource.updateSupplier(id, request);
  }

  @override
  Future<void> activateSupplier(String id) {
    return remoteDataSource.activateSupplier(id);
  }

  @override
  Future<void> deactivateSupplier(String id) {
    return remoteDataSource.deactivateSupplier(id);
  }

  @override
  Future<PagedResult<PurchaseOrderModel>> getPurchases({
    String? supplierId,
    int? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getPurchases(
      supplierId: supplierId,
      status: status,
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<PurchaseOrderModel> getPurchaseById(String id) {
    return remoteDataSource.getPurchaseById(id);
  }

  @override
  Future<PurchaseOrderModel> createPurchaseOrder(
    CreatePurchaseOrderRequestModel request,
  ) {
    return remoteDataSource.createPurchaseOrder(request);
  }

  @override
  Future<void> markAsOrdered(String id) {
    return remoteDataSource.markAsOrdered(id);
  }

  @override
  Future<PurchaseOrderModel> receiveItems(
    String id,
    ReceivePurchaseItemsRequestModel request,
  ) {
    return remoteDataSource.receiveItems(id, request);
  }

  @override
  Future<void> cancelPurchaseOrder(String id, {String? reason}) {
    return remoteDataSource.cancelPurchaseOrder(id, reason: reason);
  }

  @override
  Future<PagedResult<StockMovementModel>> getStockMovements({
    String? variantId,
    int? movementType,
    int page = 1,
    int pageSize = 20,
  }) {
    return remoteDataSource.getStockMovements(
      variantId: variantId,
      movementType: movementType,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<ProductVariantModel> getVariantByBarcode(String barcode) {
    return remoteDataSource.getVariantByBarcode(barcode);
  }
}

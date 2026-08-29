import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../features/analytics/data/models/paged_result_model.dart';
import '../../../../features/catalog/data/models/product_variant_model.dart';
import '../models/supplier_model.dart';
import '../models/purchase_order_model.dart';
import '../models/stock_movement_model.dart';

abstract class MerchantPurchasesRemoteDataSource {
  // Supplier endpoints
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

  // Purchase Order endpoints
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

  // Stock Movement & Barcode endpoints
  Future<PagedResult<StockMovementModel>> getStockMovements({
    String? variantId,
    int? movementType,
    int page = 1,
    int pageSize = 20,
  });

  Future<ProductVariantModel> getVariantByBarcode(String barcode);
}

class MerchantPurchasesRemoteDataSourceImpl implements MerchantPurchasesRemoteDataSource {
  final Dio dio;

  const MerchantPurchasesRemoteDataSourceImpl({required this.dio});

  @override
  Future<PagedResult<SupplierModel>> getSuppliers({
    String? search,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await dio.get(
        '/api/v1/suppliers',
        queryParameters: queryParams,
      );

      return PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        SupplierModel.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    try {
      final response = await dio.get('/api/v1/suppliers/$id');
      return SupplierModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<SupplierModel> createSupplier(CreateSupplierRequestModel request) async {
    try {
      final response = await dio.post(
        '/api/v1/suppliers',
        data: request.toJson(),
      );
      return SupplierModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<SupplierModel> updateSupplier(
    String id,
    UpdateSupplierRequestModel request,
  ) async {
    try {
      final response = await dio.put(
        '/api/v1/suppliers/$id',
        data: request.toJson(),
      );
      return SupplierModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> activateSupplier(String id) async {
    try {
      await dio.post('/api/v1/suppliers/$id/activate');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> deactivateSupplier(String id) async {
    try {
      await dio.post('/api/v1/suppliers/$id/deactivate');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<PagedResult<PurchaseOrderModel>> getPurchases({
    String? supplierId,
    int? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (supplierId != null && supplierId.isNotEmpty) queryParams['supplierId'] = supplierId;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await dio.get(
        '/api/v1/purchases',
        queryParameters: queryParams,
      );

      return PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        PurchaseOrderModel.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<PurchaseOrderModel> getPurchaseById(String id) async {
    try {
      final response = await dio.get('/api/v1/purchases/$id');
      return PurchaseOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<PurchaseOrderModel> createPurchaseOrder(
    CreatePurchaseOrderRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/purchases',
        data: request.toJson(),
      );
      return PurchaseOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> markAsOrdered(String id) async {
    try {
      await dio.post('/api/v1/purchases/$id/order');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<PurchaseOrderModel> receiveItems(
    String id,
    ReceivePurchaseItemsRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/purchases/$id/receive',
        data: request.toJson(),
      );
      return PurchaseOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> cancelPurchaseOrder(String id, {String? reason}) async {
    try {
      await dio.post(
        '/api/v1/purchases/$id/cancel',
        data: reason != null ? {'reason': reason} : null,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<PagedResult<StockMovementModel>> getStockMovements({
    String? variantId,
    int? movementType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (variantId != null && variantId.isNotEmpty) queryParams['variantId'] = variantId;
      if (movementType != null) queryParams['movementType'] = movementType;

      final response = await dio.get(
        '/api/v1/inventory/stock-movements',
        queryParameters: queryParams,
      );

      return PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        StockMovementModel.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<ProductVariantModel> getVariantByBarcode(String barcode) async {
    try {
      final response = await dio.get('/api/v1/inventory/barcode/$barcode');
      return ProductVariantModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }
}

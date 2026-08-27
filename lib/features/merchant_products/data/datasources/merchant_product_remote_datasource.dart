import 'package:dio/dio.dart';
import '../../../catalog/data/models/product_image_model.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/data/models/product_variant_model.dart';
import '../models/create_product_request_model.dart';
import '../models/inventory_adjustment_request_model.dart';
import '../models/update_product_request_model.dart';

abstract class MerchantProductRemoteDataSource {
  Future<ProductModel> createProduct(CreateProductRequestModel request);
  Future<ProductModel> updateProduct(String id, UpdateProductRequestModel request);
  Future<void> publishProduct(String id);
  Future<void> unpublishProduct(String id);
  Future<void> archiveProduct(String id);
  Future<void> restoreProduct(String id);

  Future<ProductVariantModel> addVariant(String productId, AddVariantRequestModel request);
  Future<ProductVariantModel> updateVariant(String productId, String variantId, AddVariantRequestModel request);
  Future<void> removeVariant(String productId, String variantId);
  Future<void> activateVariant(String productId, String variantId);
  Future<void> deactivateVariant(String productId, String variantId);

  Future<ProductImageModel> uploadProductImage(
    String productId,
    List<int> bytes,
    String fileName, {
    String? altText,
    bool isPrimary = false,
  });
  Future<void> removeProductImage(String productId, String imageId);
  Future<void> setPrimaryImage(String productId, String imageId);

  Future<void> setInventoryQuantity(String variantId, int quantity);
  Future<void> adjustInventoryQuantity(String variantId, int adjustment);
  Future<void> updateLowStockThreshold(String variantId, int threshold);
}

class MerchantProductRemoteDataSourceImpl implements MerchantProductRemoteDataSource {
  final Dio _dio;

  MerchantProductRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) async {
    final response = await _dio.post(
      '/api/v1/catalog/products',
      data: request.toJson(),
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> updateProduct(String id, UpdateProductRequestModel request) async {
    final response = await _dio.put(
      '/api/v1/catalog/products/$id',
      data: request.toJson(),
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> publishProduct(String id) async {
    await _dio.post('/api/v1/catalog/products/$id/publish');
  }

  @override
  Future<void> unpublishProduct(String id) async {
    await _dio.post('/api/v1/catalog/products/$id/unpublish');
  }

  @override
  Future<void> archiveProduct(String id) async {
    await _dio.post('/api/v1/catalog/products/$id/archive');
  }

  @override
  Future<void> restoreProduct(String id) async {
    await _dio.post('/api/v1/catalog/products/$id/restore');
  }

  @override
  Future<ProductVariantModel> addVariant(String productId, AddVariantRequestModel request) async {
    final response = await _dio.post(
      '/api/v1/catalog/products/$productId/variants',
      data: request.toJson(),
    );
    return ProductVariantModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductVariantModel> updateVariant(String productId, String variantId, AddVariantRequestModel request) async {
    final response = await _dio.put(
      '/api/v1/catalog/products/$productId/variants/$variantId',
      data: request.toJson(),
    );
    return ProductVariantModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeVariant(String productId, String variantId) async {
    await _dio.delete('/api/v1/catalog/products/$productId/variants/$variantId');
  }

  @override
  Future<void> activateVariant(String productId, String variantId) async {
    await _dio.post('/api/v1/catalog/products/$productId/variants/$variantId/activate');
  }

  @override
  Future<void> deactivateVariant(String productId, String variantId) async {
    await _dio.post('/api/v1/catalog/products/$productId/variants/$variantId/deactivate');
  }

  @override
  Future<ProductImageModel> uploadProductImage(
    String productId,
    List<int> bytes,
    String fileName, {
    String? altText,
    bool isPrimary = false,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      if (altText != null) 'altText': altText,
      'isPrimary': isPrimary,
    });

    final response = await _dio.post(
      '/api/v1/catalog/products/$productId/images',
      data: formData,
    );
    return ProductImageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeProductImage(String productId, String imageId) async {
    await _dio.delete('/api/v1/catalog/products/$productId/images/$imageId');
  }

  @override
  Future<void> setPrimaryImage(String productId, String imageId) async {
    await _dio.put('/api/v1/catalog/products/$productId/images/$imageId/primary');
  }

  @override
  Future<void> setInventoryQuantity(String variantId, int quantity) async {
    await _dio.put(
      '/api/v1/inventory/$variantId',
      data: SetInventoryQuantityRequestModel(quantity: quantity).toJson(),
    );
  }

  @override
  Future<void> adjustInventoryQuantity(String variantId, int adjustment) async {
    await _dio.post(
      '/api/v1/inventory/$variantId/adjust',
      data: AdjustInventoryQuantityRequestModel(adjustment: adjustment).toJson(),
    );
  }

  @override
  Future<void> updateLowStockThreshold(String variantId, int threshold) async {
    await _dio.put(
      '/api/v1/inventory/$variantId/threshold',
      data: UpdateLowStockThresholdRequestModel(threshold: threshold).toJson(),
    );
  }
}

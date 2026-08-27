import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../catalog/data/models/product_image_model.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/data/models/product_variant_model.dart';
import '../../domain/repositories/merchant_product_repository.dart';
import '../datasources/merchant_product_remote_datasource.dart';
import '../models/create_product_request_model.dart';
import '../models/update_product_request_model.dart';

class MerchantProductRepositoryImpl implements MerchantProductRepository {
  final MerchantProductRemoteDataSource _remoteDataSource;

  MerchantProductRepositoryImpl({required MerchantProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiServerException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) =>
      _guard(() => _remoteDataSource.createProduct(request));

  @override
  Future<ProductModel> updateProduct(String id, UpdateProductRequestModel request) =>
      _guard(() => _remoteDataSource.updateProduct(id, request));

  @override
  Future<void> publishProduct(String id) =>
      _guard(() => _remoteDataSource.publishProduct(id));

  @override
  Future<void> unpublishProduct(String id) =>
      _guard(() => _remoteDataSource.unpublishProduct(id));

  @override
  Future<void> archiveProduct(String id) =>
      _guard(() => _remoteDataSource.archiveProduct(id));

  @override
  Future<void> restoreProduct(String id) =>
      _guard(() => _remoteDataSource.restoreProduct(id));

  @override
  Future<ProductVariantModel> addVariant(String productId, AddVariantRequestModel request) =>
      _guard(() => _remoteDataSource.addVariant(productId, request));

  @override
  Future<ProductVariantModel> updateVariant(String productId, String variantId, AddVariantRequestModel request) =>
      _guard(() => _remoteDataSource.updateVariant(productId, variantId, request));

  @override
  Future<void> removeVariant(String productId, String variantId) =>
      _guard(() => _remoteDataSource.removeVariant(productId, variantId));

  @override
  Future<void> activateVariant(String productId, String variantId) =>
      _guard(() => _remoteDataSource.activateVariant(productId, variantId));

  @override
  Future<void> deactivateVariant(String productId, String variantId) =>
      _guard(() => _remoteDataSource.deactivateVariant(productId, variantId));

  @override
  Future<ProductImageModel> uploadProductImage(
    String productId,
    List<int> bytes,
    String fileName, {
    String? altText,
    bool isPrimary = false,
  }) =>
      _guard(() => _remoteDataSource.uploadProductImage(
            productId,
            bytes,
            fileName,
            altText: altText,
            isPrimary: isPrimary,
          ));

  @override
  Future<void> removeProductImage(String productId, String imageId) =>
      _guard(() => _remoteDataSource.removeProductImage(productId, imageId));

  @override
  Future<void> setPrimaryImage(String productId, String imageId) =>
      _guard(() => _remoteDataSource.setPrimaryImage(productId, imageId));

  @override
  Future<void> setInventoryQuantity(String variantId, int quantity) =>
      _guard(() => _remoteDataSource.setInventoryQuantity(variantId, quantity));

  @override
  Future<void> adjustInventoryQuantity(String variantId, int adjustment) =>
      _guard(() => _remoteDataSource.adjustInventoryQuantity(variantId, adjustment));

  @override
  Future<void> updateLowStockThreshold(String variantId, int threshold) =>
      _guard(() => _remoteDataSource.updateLowStockThreshold(variantId, threshold));
}

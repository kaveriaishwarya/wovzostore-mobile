import '../../../catalog/data/models/product_image_model.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/data/models/product_variant_model.dart';
import '../../data/models/create_product_request_model.dart';
import '../../data/models/update_product_request_model.dart';

abstract class MerchantProductRepository {
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

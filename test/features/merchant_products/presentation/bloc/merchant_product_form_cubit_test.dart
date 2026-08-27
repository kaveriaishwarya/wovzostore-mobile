import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_image_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/create_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/update_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/domain/repositories/merchant_product_repository.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/bloc/merchant_product_form_cubit.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/bloc/merchant_product_form_state.dart';

class MockMerchantProductRepository implements MerchantProductRepository {
  bool shouldFail = false;

  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to create product');
    return ProductModel(
      id: 'p1',
      name: request.name,
      slug: request.slug ?? 'p1-slug',
      categoryId: request.categoryId,
      status: 0,
      basePrice: request.basePrice,
      isActive: false,
      isFeatured: request.isFeatured,
    );
  }

  @override
  Future<ProductModel> updateProduct(String id, UpdateProductRequestModel request) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to update product');
    return ProductModel(
      id: id,
      name: request.name,
      slug: request.slug,
      categoryId: request.categoryId,
      status: 1,
      basePrice: request.basePrice,
      isActive: true,
      isFeatured: request.isFeatured,
    );
  }

  @override
  Future<void> publishProduct(String id) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to publish product');
  }

  @override
  Future<void> unpublishProduct(String id) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to unpublish product');
  }

  @override
  Future<void> archiveProduct(String id) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to archive product');
  }

  @override
  Future<void> restoreProduct(String id) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to restore product');
  }

  @override
  Future<ProductVariantModel> addVariant(String productId, AddVariantRequestModel request) async => throw UnimplementedError();
  @override
  Future<ProductVariantModel> updateVariant(String productId, String variantId, AddVariantRequestModel request) async => throw UnimplementedError();
  @override
  Future<void> removeVariant(String productId, String variantId) async => throw UnimplementedError();
  @override
  Future<void> activateVariant(String productId, String variantId) async => throw UnimplementedError();
  @override
  Future<void> deactivateVariant(String productId, String variantId) async => throw UnimplementedError();
  @override
  Future<ProductImageModel> uploadProductImage(String productId, List<int> bytes, String fileName, {String? altText, bool isPrimary = false}) async => throw UnimplementedError();
  @override
  Future<void> removeProductImage(String productId, String imageId) async => throw UnimplementedError();
  @override
  Future<void> setPrimaryImage(String productId, String imageId) async => throw UnimplementedError();
  @override
  Future<void> setInventoryQuantity(String variantId, int quantity) async => throw UnimplementedError();
  @override
  Future<void> adjustInventoryQuantity(String variantId, int adjustment) async => throw UnimplementedError();
  @override
  Future<void> updateLowStockThreshold(String variantId, int threshold) async => throw UnimplementedError();
}

void main() {
  group('MerchantProductFormCubit Tests', () {
    late MockMerchantProductRepository repository;
    late MerchantProductFormCubit cubit;

    setUp(() {
      repository = MockMerchantProductRepository();
      cubit = MerchantProductFormCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MerchantProductFormStatus.initial', () {
      expect(cubit.state.status, MerchantProductFormStatus.initial);
    });

    test('createProduct emits submitting then success', () async {
      final states = <MerchantProductFormState>[];
      cubit.stream.listen(states.add);

      await cubit.createProduct(const CreateProductRequestModel(
        name: 'New Shirt',
        categoryId: 'c1',
        basePrice: 299.0,
      ));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, MerchantProductFormStatus.submitting);
      expect(states[1].status, MerchantProductFormStatus.success);
      expect(states[1].product?.name, 'New Shirt');
    });

    test('createProduct emits error state on failure', () async {
      repository.shouldFail = true;

      final states = <MerchantProductFormState>[];
      cubit.stream.listen(states.add);

      await cubit.createProduct(const CreateProductRequestModel(
        name: 'New Shirt',
        categoryId: 'c1',
        basePrice: 299.0,
      ));
      await Future.delayed(Duration.zero);

      expect(states.last.status, MerchantProductFormStatus.error);
      expect(states.last.errorMessage, 'Failed to create product');
    });
  });
}

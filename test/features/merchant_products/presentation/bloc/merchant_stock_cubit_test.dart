import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_image_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/create_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/update_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/domain/repositories/merchant_product_repository.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/bloc/merchant_stock_cubit.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/bloc/merchant_stock_state.dart';

class MockStockMerchantProductRepository implements MerchantProductRepository {
  bool shouldFail = false;

  @override
  Future<void> setInventoryQuantity(String variantId, int quantity) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to set quantity');
  }

  @override
  Future<void> adjustInventoryQuantity(String variantId, int adjustment) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to adjust quantity');
  }

  @override
  Future<void> updateLowStockThreshold(String variantId, int threshold) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to update threshold');
  }

  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) => throw UnimplementedError();
  @override
  Future<ProductModel> updateProduct(String id, UpdateProductRequestModel request) => throw UnimplementedError();
  @override
  Future<void> publishProduct(String id) => throw UnimplementedError();
  @override
  Future<void> unpublishProduct(String id) => throw UnimplementedError();
  @override
  Future<void> archiveProduct(String id) => throw UnimplementedError();
  @override
  Future<void> restoreProduct(String id) => throw UnimplementedError();
  @override
  Future<ProductVariantModel> addVariant(String productId, AddVariantRequestModel request) => throw UnimplementedError();
  @override
  Future<ProductVariantModel> updateVariant(String productId, String variantId, AddVariantRequestModel request) => throw UnimplementedError();
  @override
  Future<void> removeVariant(String productId, String variantId) => throw UnimplementedError();
  @override
  Future<void> activateVariant(String productId, String variantId) => throw UnimplementedError();
  @override
  Future<void> deactivateVariant(String productId, String variantId) => throw UnimplementedError();
  @override
  Future<ProductImageModel> uploadProductImage(String productId, List<int> bytes, String fileName, {String? altText, bool isPrimary = false}) => throw UnimplementedError();
  @override
  Future<void> removeProductImage(String productId, String imageId) => throw UnimplementedError();
  @override
  Future<void> setPrimaryImage(String productId, String imageId) => throw UnimplementedError();
}

void main() {
  group('MerchantStockCubit Tests', () {
    late MockStockMerchantProductRepository repository;
    late MerchantStockCubit cubit;

    setUp(() {
      repository = MockStockMerchantProductRepository();
      cubit = MerchantStockCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MerchantStockStatus.initial', () {
      expect(cubit.state.status, MerchantStockStatus.initial);
    });

    test('setQuantity emits updating then success', () async {
      final states = <MerchantStockState>[];
      cubit.stream.listen(states.add);

      await cubit.setQuantity('v1', 50);
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, MerchantStockStatus.updating);
      expect(states[1].status, MerchantStockStatus.success);
    });

    test('adjustQuantity emits updating then success', () async {
      final states = <MerchantStockState>[];
      cubit.stream.listen(states.add);

      await cubit.adjustQuantity('v1', -5);
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, MerchantStockStatus.updating);
      expect(states[1].status, MerchantStockStatus.success);
    });

    test('setQuantity emits error state on failure', () async {
      repository.shouldFail = true;

      final states = <MerchantStockState>[];
      cubit.stream.listen(states.add);

      await cubit.setQuantity('v1', 50);
      await Future.delayed(Duration.zero);

      expect(states.last.status, MerchantStockStatus.error);
      expect(states.last.errorMessage, 'Failed to set quantity');
    });
  });
}

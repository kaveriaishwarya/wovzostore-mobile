import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_image_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_list_cubit.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/create_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/update_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/domain/repositories/merchant_product_repository.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/bloc/merchant_product_form_cubit.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/bloc/merchant_stock_cubit.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/screens/merchant_product_form_screen.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/screens/merchant_product_list_screen.dart';

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<BannerModel>> getBanners() async => [];
  @override
  Future<List<CategoryModel>> getCategories() async => [
        const CategoryModel(id: 'cat1', name: 'Apparel', slug: 'apparel', sortOrder: 1, isActive: true),
      ];
  @override
  Future<List<CategoryModel>> getCategoryTree() async => [];
  @override
  Future<List<BrandModel>> getBrands() async => [
        const BrandModel(id: 'br1', name: 'Wovzo', slug: 'wovzo', isActive: true),
      ];
  @override
  Future<PagedProductsModel> getProducts({String? categoryId, String? brandId, String? search, String? sortBy, String? sortDirection, int page = 1, int pageSize = 20}) async {
    return PagedProductsModel(
      items: [
        ProductModel(
          id: 'p1',
          name: 'Merchant Shirt',
          slug: 'merchant-shirt',
          categoryId: 'cat1',
          status: 1,
          basePrice: 499.0,
          isActive: true,
          isFeatured: false,
          variants: [],
          images: [],
        ),
      ],
      totalCount: 1,
      page: 1,
      pageSize: 20,
    );
  }
  @override
  Future<ProductModel> getProductById(String id) async => throw UnimplementedError();
  @override
  Future<ProductModel> getProductBySlug(String slug) async => throw UnimplementedError();
}

class MockMerchantProductRepository implements MerchantProductRepository {
  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) async {
    return ProductModel(
      id: 'p_new',
      name: request.name,
      slug: request.slug ?? 'slug',
      categoryId: request.categoryId,
      status: 0,
      basePrice: request.basePrice,
      isActive: false,
      isFeatured: request.isFeatured,
    );
  }

  @override
  Future<ProductModel> updateProduct(String id, UpdateProductRequestModel request) async {
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
  Future<void> publishProduct(String id) async {}
  @override
  Future<void> unpublishProduct(String id) async {}
  @override
  Future<void> archiveProduct(String id) async {}
  @override
  Future<void> restoreProduct(String id) async {}
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
  Future<void> setInventoryQuantity(String variantId, int quantity) async {}
  @override
  Future<void> adjustInventoryQuantity(String variantId, int adjustment) async {}
  @override
  Future<void> updateLowStockThreshold(String variantId, int threshold) async {}
}

void main() {
  final sl = GetIt.instance;
  late MockCatalogRepository catalogRepo;
  late MockMerchantProductRepository merchantRepo;
  late ProductListCubit productListCubit;
  late MerchantProductFormCubit formCubit;
  late MerchantStockCubit stockCubit;

  setUp(() {
    sl.reset();
    catalogRepo = MockCatalogRepository();
    merchantRepo = MockMerchantProductRepository();
    productListCubit = ProductListCubit(repository: catalogRepo);
    formCubit = MerchantProductFormCubit(repository: merchantRepo);
    stockCubit = MerchantStockCubit(repository: merchantRepo);

    sl.registerLazySingleton<CatalogRepository>(() => catalogRepo);
    sl.registerLazySingleton<MerchantProductRepository>(() => merchantRepo);
    sl.registerFactory<ProductListCubit>(() => productListCubit);
    sl.registerFactory<MerchantProductFormCubit>(() => formCubit);
    sl.registerFactory<MerchantStockCubit>(() => stockCubit);
  });

  tearDown(() {
    sl.reset();
  });

  group('Merchant Product UI Screen Tests', () {
    testWidgets('MerchantProductListScreen renders search bar, category chips, and product cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantProductListScreen(
            productListCubit: productListCubit,
            catalogRepository: catalogRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Products & Stock Management'), findsOneWidget);
      expect(find.text('Merchant Shirt'), findsOneWidget);
      expect(find.text('Base Price: ₹499.00'), findsOneWidget);
      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('Apparel'), findsOneWidget);
    });

    testWidgets('MerchantProductFormScreen renders form fields and dropdowns', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantProductFormScreen(
            cubit: formCubit,
            catalogRepository: catalogRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add New Product'), findsOneWidget);
      expect(find.text('Product Name *'), findsOneWidget);
      expect(find.text('Base Price (₹) *'), findsOneWidget);
      expect(find.text('Create Product'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_image_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/create_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/data/models/update_product_request_model.dart';
import 'package:wovzo_mobile/features/merchant_products/domain/repositories/merchant_product_repository.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/bloc/merchant_product_form_cubit.dart';
import 'package:wovzo_mobile/features/merchant_products/presentation/screens/merchant_product_form_screen.dart';

class FakeMerchantProductRepository implements MerchantProductRepository {
  ProductModel? lastCreatedProduct;
  UpdateProductRequestModel? lastUpdateRequest;

  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) async {
    final created = ProductModel(
      id: 'prod-new',
      name: request.name,
      slug: request.slug ?? 'slug',
      categoryId: request.categoryId,
      status: 0,
      basePrice: request.basePrice,
      isActive: false,
      isFeatured: request.isFeatured,
      hsnCode: request.hsnCode,
      taxRatePercentage: request.taxRatePercentage,
      isTaxInclusive: request.isTaxInclusive,
    );
    lastCreatedProduct = created;
    return created;
  }

  @override
  Future<ProductModel> updateProduct(String id, UpdateProductRequestModel request) async {
    lastUpdateRequest = request;
    return ProductModel(
      id: id,
      name: request.name,
      slug: request.slug,
      categoryId: request.categoryId,
      status: 1,
      basePrice: request.basePrice,
      isActive: true,
      isFeatured: request.isFeatured,
      hsnCode: request.hsnCode,
      taxRatePercentage: request.taxRatePercentage,
      isTaxInclusive: request.isTaxInclusive,
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

class FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<CategoryModel>> getCategories() async {
    return const [
      CategoryModel(id: 'cat-1', name: 'Apparel', slug: 'apparel', sortOrder: 1, isActive: true),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategoryTree() async => [];

  @override
  Future<List<BrandModel>> getBrands() async {
    return const [
      BrandModel(id: 'brand-1', name: 'Wovzo Apparel', slug: 'wovzo-apparel', isActive: true),
    ];
  }

  @override
  Future<PagedProductsModel> getProducts({String? categoryId, String? brandId, String? search, String? sortBy, String? sortDirection, int page = 1, int pageSize = 20}) async {
    return const PagedProductsModel(items: [], totalCount: 0, page: 1, pageSize: 20);
  }

  @override
  Future<ProductModel> getProductById(String id) async => throw UnimplementedError();

  @override
  Future<ProductModel> getProductBySlug(String slug) async => throw UnimplementedError();

  @override
  Future<List<BannerModel>> getBanners() async => [];
}

void main() {
  late FakeMerchantProductRepository mockProductRepo;
  late FakeCatalogRepository mockCatalogRepo;
  late MerchantProductFormCubit cubit;

  const sampleProduct = ProductModel(
    id: 'prod-101',
    name: 'Denim Jacket',
    slug: 'denim-jacket',
    categoryId: 'cat-1',
    status: 1,
    basePrice: 2499.0,
    isActive: true,
    isFeatured: false,
    hsnCode: '6203',
    taxRatePercentage: 12.0,
    isTaxInclusive: true,
  );

  setUp(() {
    mockProductRepo = FakeMerchantProductRepository();
    mockCatalogRepo = FakeCatalogRepository();
    cubit = MerchantProductFormCubit(repository: mockProductRepo);
  });

  tearDown(() {
    cubit.close();
  });

  Widget buildWidget({ProductModel? existingProduct}) {
    return MaterialApp(
      home: MerchantProductFormScreen(
        existingProduct: existingProduct,
        cubit: cubit,
        catalogRepository: mockCatalogRepo,
      ),
    );
  }

  group('MerchantProductFormScreen GST Tax Classification Widget Tests', () {
    testWidgets('renders HSN code, Tax Rate percentage, and Tax-Inclusive switch', (tester) async {
      await tester.pumpWidget(buildWidget(existingProduct: sampleProduct));
      await tester.pumpAndSettle();

      expect(find.text('GST & Tax Classification'), findsOneWidget);
      expect(find.byKey(const Key('hsn_code_input')), findsOneWidget);
      expect(find.byKey(const Key('tax_rate_input')), findsOneWidget);
      expect(find.byKey(const Key('is_tax_inclusive_switch')), findsOneWidget);

      expect(find.text('6203'), findsOneWidget);
      expect(find.text('12.0'), findsOneWidget);
    });

    testWidgets('toggles tax-inclusive switch state', (tester) async {
      await tester.pumpWidget(buildWidget(existingProduct: sampleProduct));
      await tester.pumpAndSettle();

      final switchFinder = find.byKey(const Key('is_tax_inclusive_switch'));
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<SwitchListTile>(switchFinder);
      expect(switchWidget.value, isFalse);
    });
  });
}

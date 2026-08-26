import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_details_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/screens/product_details_screen.dart';

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<BannerModel>> getBanners() async => const [];
  @override
  Future<List<CategoryModel>> getCategories() async => const [];
  @override
  Future<List<CategoryModel>> getCategoryTree() async => const [];
  @override
  Future<List<BrandModel>> getBrands() async => const [];
  @override
  Future<PagedProductsModel> getProducts({String? categoryId, String? brandId, String? search, String? sortBy, String? sortDirection, int page = 1, int pageSize = 20}) async => throw UnimplementedError();

  @override
  Future<ProductModel> getProductById(String id) async {
    return const ProductModel(
      id: 'p100',
      name: 'Smart Watch Pro',
      slug: 'smart-watch-pro',
      description: 'Full feature smartwatch with heart rate monitor.',
      categoryId: 'c1',
      brand: 'TechCorp',
      status: 1,
      basePrice: 299.0,
      isActive: true,
      isFeatured: true,
      variants: [
        ProductVariantModel(id: 'v1', productId: 'p100', sku: 'SKU-BLACK', name: 'Black Edition', price: 299.0, isActive: true, stockQuantity: 10),
      ],
    );
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async => throw UnimplementedError();
}

void main() {
  group('ProductDetailsScreen Widget Tests', () {
    late MockCatalogRepository repository;
    late ProductDetailsCubit cubit;

    setUp(() {
      repository = MockCatalogRepository();
      cubit = ProductDetailsCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders product details, pricing, variants, and Add to Cart button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductDetailsCubit>.value(
            value: cubit,
            child: const ProductDetailsScreen(productId: 'p100'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Smart Watch Pro'), findsOneWidget);
      expect(find.text('TECHCORP'), findsOneWidget);
      expect(find.text('₹299.00'), findsOneWidget);
      expect(find.text('Select Variant'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
    });
  });
}

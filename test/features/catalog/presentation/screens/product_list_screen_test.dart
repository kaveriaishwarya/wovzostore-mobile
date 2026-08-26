import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_list_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/screens/product_list_screen.dart';

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
  Future<PagedProductsModel> getProducts({
    String? categoryId,
    String? brandId,
    String? search,
    String? sortBy,
    String? sortDirection,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PagedProductsModel(
      items: [
        ProductModel(id: 'p1', name: 'Running Shoes', slug: 'running-shoes', categoryId: 'c1', status: 1, basePrice: 129.99, isActive: true, isFeatured: false),
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

void main() {
  group('ProductListScreen Widget Tests', () {
    late MockCatalogRepository repository;
    late ProductListCubit cubit;

    setUp(() {
      repository = MockCatalogRepository();
      cubit = ProductListCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders search bar and product cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductListCubit>.value(
            value: cubit,
            child: const ProductListScreen(categoryName: 'Footwear'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Footwear'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Running Shoes'), findsOneWidget);
      expect(find.text('₹129.99'), findsOneWidget);
    });
  });
}

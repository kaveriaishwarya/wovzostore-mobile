import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/catalog_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/screens/categories_screen.dart';

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<BannerModel>> getBanners() async => const [];
  @override
  Future<List<CategoryModel>> getCategories() async => const [];

  @override
  Future<List<CategoryModel>> getCategoryTree() async {
    return const [
      CategoryModel(
        id: 'c1',
        name: 'Fashion',
        slug: 'fashion',
        sortOrder: 1,
        isActive: true,
        children: [
          CategoryModel(id: 'c2', name: 'Menswear', slug: 'menswear', sortOrder: 1, isActive: true),
        ],
      ),
    ];
  }

  @override
  Future<List<BrandModel>> getBrands() async => const [];
  @override
  Future<PagedProductsModel> getProducts({String? categoryId, String? brandId, String? search, String? sortBy, String? sortDirection, int page = 1, int pageSize = 20}) async => throw UnimplementedError();
  @override
  Future<ProductModel> getProductById(String id) async => throw UnimplementedError();
  @override
  Future<ProductModel> getProductBySlug(String slug) async => throw UnimplementedError();
}

void main() {
  group('CategoriesScreen Widget Tests', () {
    late MockCatalogRepository repository;
    late CatalogCubit cubit;

    setUp(() {
      repository = MockCatalogRepository();
      cubit = CatalogCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders category hierarchy tree', (WidgetTester tester) async {
      await cubit.loadCatalog();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CatalogCubit>.value(
            value: cubit,
            child: const CategoriesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('Fashion'), findsOneWidget);

      await tester.tap(find.text('Fashion'));
      await tester.pumpAndSettle();

      expect(find.text('Menswear'), findsOneWidget);
    });
  });
}

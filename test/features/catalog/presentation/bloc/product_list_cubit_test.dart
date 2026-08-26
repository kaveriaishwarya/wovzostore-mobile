import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_list_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_list_state.dart';

class MockCatalogRepository implements CatalogRepository {
  bool getProductsShouldFail = false;
  int requestedPage = 1;
  String? requestedCategory;

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
    requestedPage = page;
    requestedCategory = categoryId;

    if (getProductsShouldFail) {
      throw const ApiNetworkException(message: 'Connection failed.');
    }

    if (page == 1) {
      return const PagedProductsModel(
        items: [
          ProductModel(id: 'p1', name: 'Product 1', slug: 'p-1', categoryId: 'c1', status: 1, basePrice: 10, isActive: true, isFeatured: false),
          ProductModel(id: 'p2', name: 'Product 2', slug: 'p-2', categoryId: 'c1', status: 1, basePrice: 20, isActive: true, isFeatured: false),
        ],
        totalCount: 3,
        page: 1,
        pageSize: 2,
      );
    } else {
      return const PagedProductsModel(
        items: [
          ProductModel(id: 'p3', name: 'Product 3', slug: 'p-3', categoryId: 'c1', status: 1, basePrice: 30, isActive: true, isFeatured: false),
        ],
        totalCount: 3,
        page: 2,
        pageSize: 2,
      );
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async => throw UnimplementedError();

  @override
  Future<ProductModel> getProductBySlug(String slug) async => throw UnimplementedError();
}

void main() {
  group('ProductListCubit Tests', () {
    late MockCatalogRepository repository;
    late ProductListCubit cubit;

    setUp(() {
      repository = MockCatalogRepository();
      cubit = ProductListCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is ProductListStatus.initial', () {
      expect(cubit.state.status, ProductListStatus.initial);
    });

    test('loadProducts fetches page 1 items successfully', () async {
      final states = <ProductListState>[];
      cubit.stream.listen(states.add);

      await cubit.loadProducts(pageSize: 2);
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, ProductListStatus.loading);
      expect(states[1].status, ProductListStatus.success);
      expect(states[1].products.length, 2);
      expect(states[1].page, 1);
      expect(states[1].hasMore, isTrue);
    });

    test('loadNextPage appends items and updates page count', () async {
      await cubit.loadProducts(pageSize: 2);

      final states = <ProductListState>[];
      cubit.stream.listen(states.add);

      await cubit.loadNextPage();
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, ProductListStatus.loadingMore);
      expect(states[1].status, ProductListStatus.success);
      expect(states[1].products.length, 3);
      expect(states[1].page, 2);
      expect(states[1].hasMore, isFalse);
    });

    test('loadNextPage does nothing if no more pages exist', () async {
      await cubit.loadProducts(pageSize: 2);
      await cubit.loadNextPage();

      final states = <ProductListState>[];
      cubit.stream.listen(states.add);

      await cubit.loadNextPage();
      await Future.delayed(Duration.zero);

      expect(states, isEmpty);
    });

    test('updateFilters resets page to 1 and fetches new filter data', () async {
      await cubit.loadProducts(pageSize: 2);
      await cubit.loadNextPage();
      expect(cubit.state.page, 2);

      await cubit.updateFilters(categoryId: 'cat_new');
      await Future.delayed(Duration.zero);

      expect(cubit.state.page, 1);
      expect(repository.requestedCategory, 'cat_new');
    });

    test('loadProducts emits error state on failure', () async {
      repository.getProductsShouldFail = true;

      final states = <ProductListState>[];
      cubit.stream.listen(states.add);

      await cubit.loadProducts();
      await Future.delayed(Duration.zero);

      expect(states.last.status, ProductListStatus.error);
      expect(states.last.errorMessage, 'Connection failed.');
    });
  });
}

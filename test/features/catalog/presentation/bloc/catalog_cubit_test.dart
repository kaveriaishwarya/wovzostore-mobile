import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/catalog_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/catalog_state.dart';

class MockCatalogRepository implements CatalogRepository {
  bool loadShouldFail = false;

  @override
  Future<List<BannerModel>> getBanners() async {
    if (loadShouldFail) throw const ApiNetworkException(message: 'Network offline.');
    return const [BannerModel(id: 'b1', title: 'B1', imageUrl: 'img1', linkType: 0, sortOrder: 1, isActive: true)];
  }

  @override
  Future<List<CategoryModel>> getCategories() async => const [];

  @override
  Future<List<CategoryModel>> getCategoryTree() async {
    if (loadShouldFail) throw const ApiNetworkException(message: 'Network offline.');
    return const [CategoryModel(id: 'c1', name: 'Cat1', slug: 'cat-1', sortOrder: 1, isActive: true)];
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    if (loadShouldFail) throw const ApiNetworkException(message: 'Network offline.');
    return const [BrandModel(id: 'br1', name: 'Brand1', slug: 'brand-1', isActive: true)];
  }

  @override
  Future<PagedProductsModel> getProducts({String? categoryId, String? brandId, String? search, String? sortBy, String? sortDirection, int page = 1, int pageSize = 20}) async => const PagedProductsModel(items: [], totalCount: 0, page: 1, pageSize: 20);

  @override
  Future<ProductModel> getProductById(String id) async => throw UnimplementedError();

  @override
  Future<ProductModel> getProductBySlug(String slug) async => throw UnimplementedError();
}

void main() {
  group('CatalogCubit Tests', () {
    late MockCatalogRepository repository;
    late CatalogCubit cubit;

    setUp(() {
      repository = MockCatalogRepository();
      cubit = CatalogCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is CatalogStatus.initial', () {
      expect(cubit.state.status, CatalogStatus.initial);
    });

    test('loadCatalog emits loading then success', () async {
      final states = <CatalogState>[];
      cubit.stream.listen(states.add);

      await cubit.loadCatalog();
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, CatalogStatus.loading);
      expect(states[1].status, CatalogStatus.success);
      expect(states[1].banners.length, 1);
      expect(states[1].categoryTree.length, 1);
      expect(states[1].brands.length, 1);
    });

    test('loadCatalog emits error state on network failure', () async {
      repository.loadShouldFail = true;

      final states = <CatalogState>[];
      cubit.stream.listen(states.add);

      await cubit.loadCatalog();
      await Future.delayed(Duration.zero);

      expect(states.last.status, CatalogStatus.error);
      expect(states.last.errorMessage, 'Network offline.');
    });
  });
}

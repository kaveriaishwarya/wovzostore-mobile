import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_details_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_details_state.dart';

class MockCatalogRepository implements CatalogRepository {
  bool getByIdShouldFail = false;
  bool getBySlugShouldFail = false;

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
    if (getByIdShouldFail) throw const ApiNotFoundException(message: 'Product not found.');
    return ProductModel(id: id, name: 'Product $id', slug: 'p-$id', categoryId: 'c1', status: 1, basePrice: 99.0, isActive: true, isFeatured: false);
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    if (getBySlugShouldFail) throw const ApiNotFoundException(message: 'Product not found.');
    return ProductModel(id: 'p_slug', name: 'Slug Product', slug: slug, categoryId: 'c1', status: 1, basePrice: 99.0, isActive: true, isFeatured: false);
  }
}

void main() {
  group('ProductDetailsCubit Tests', () {
    late MockCatalogRepository repository;
    late ProductDetailsCubit cubit;

    setUp(() {
      repository = MockCatalogRepository();
      cubit = ProductDetailsCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is ProductDetailsStatus.initial', () {
      expect(cubit.state.status, ProductDetailsStatus.initial);
    });

    test('loadProductById emits loading then success', () async {
      final states = <ProductDetailsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadProductById('p100');
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, ProductDetailsStatus.loading);
      expect(states[1].status, ProductDetailsStatus.success);
      expect(states[1].product?.id, 'p100');
    });

    test('loadProductBySlug emits loading then success', () async {
      final states = <ProductDetailsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadProductBySlug('wireless-mouse');
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, ProductDetailsStatus.loading);
      expect(states[1].status, ProductDetailsStatus.success);
      expect(states[1].product?.slug, 'wireless-mouse');
    });

    test('loadProductById emits error on 404 failure', () async {
      repository.getByIdShouldFail = true;

      final states = <ProductDetailsState>[];
      cubit.stream.listen(states.add);

      await cubit.loadProductById('missing_id');
      await Future.delayed(Duration.zero);

      expect(states.last.status, ProductDetailsStatus.error);
      expect(states.last.errorMessage, 'Product not found.');
    });
  });
}

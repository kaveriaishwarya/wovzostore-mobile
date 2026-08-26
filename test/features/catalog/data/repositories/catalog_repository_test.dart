import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';

class FakeCatalogRemoteDataSource implements CatalogRemoteDataSource {
  bool shouldThrowDioException = false;
  int dioStatusCode = 404;

  @override
  Future<List<BannerModel>> getBanners({bool includeInactive = false}) async {
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/catalog/banners'),
        type: DioExceptionType.connectionTimeout,
      );
    }
    return const [
      BannerModel(id: 'b1', title: 'Banner 1', imageUrl: 'url1', linkType: 0, sortOrder: 1, isActive: true),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategories({bool includeInactive = false}) async {
    return const [
      CategoryModel(id: 'c1', name: 'Cat 1', slug: 'cat-1', sortOrder: 1, isActive: true),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategoryTree({bool includeInactive = false}) async {
    return const [
      CategoryModel(id: 'c1', name: 'Cat 1', slug: 'cat-1', sortOrder: 1, isActive: true),
    ];
  }

  @override
  Future<List<BrandModel>> getBrands({bool includeInactive = false}) async {
    return const [
      BrandModel(id: 'br1', name: 'Brand 1', slug: 'brand-1', isActive: true),
    ];
  }

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
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/catalog/products'),
        type: DioExceptionType.connectionError,
      );
    }
    return const PagedProductsModel(
      items: [
        ProductModel(id: 'p1', name: 'Product 1', slug: 'p-1', categoryId: 'c1', status: 1, basePrice: 20.0, isActive: true, isFeatured: false),
      ],
      totalCount: 1,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/catalog/products/$id'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/catalog/products/$id'),
          statusCode: dioStatusCode,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return ProductModel(id: id, name: 'Product $id', slug: 'p-$id', categoryId: 'c1', status: 1, basePrice: 30.0, isActive: true, isFeatured: false);
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    if (shouldThrowDioException) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/catalog/products/slug/$slug'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/catalog/products/slug/$slug'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return ProductModel(id: 'p_slug', name: 'Slug Product', slug: slug, categoryId: 'c1', status: 1, basePrice: 30.0, isActive: true, isFeatured: false);
  }
}

void main() {
  group('CatalogRepositoryImpl Tests', () {
    late FakeCatalogRemoteDataSource fakeDataSource;
    late CatalogRepository repository;

    setUp(() {
      fakeDataSource = FakeCatalogRemoteDataSource();
      repository = CatalogRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('getBanners delegates to datasource and returns list', () async {
      final banners = await repository.getBanners();
      expect(banners.length, 1);
      expect(banners.first.title, 'Banner 1');
    });

    test('getBanners maps DioException to ApiTimeoutException', () async {
      fakeDataSource.shouldThrowDioException = true;

      expect(
        () => repository.getBanners(),
        throwsA(isA<ApiTimeoutException>()),
      );
    });

    test('getProducts maps connection error to ApiNetworkException', () async {
      fakeDataSource.shouldThrowDioException = true;

      expect(
        () => repository.getProducts(),
        throwsA(isA<ApiNetworkException>()),
      );
    });

    test('getProductById maps 404 response to ApiNotFoundException', () async {
      fakeDataSource.shouldThrowDioException = true;
      fakeDataSource.dioStatusCode = 404;

      expect(
        () => repository.getProductById('invalid_id'),
        throwsA(isA<ApiNotFoundException>()),
      );
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/catalog/data/datasources/catalog_remote_datasource.dart';

void main() {
  group('CatalogRemoteDataSource Tests', () {
    late Dio dio;
    late CatalogRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://localhost:7291'));
      dataSource = CatalogRemoteDataSourceImpl(dio: dio);
    });

    test('getBanners sends GET /api/v1/catalog/banners', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/catalog/banners');

          return ResponseBody.fromString(
            '[{"id": "b1", "title": "Promo 1", "imageUrl": "url1", "linkType": 0, "sortOrder": 1, "isActive": true}]',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final banners = await dataSource.getBanners();
      expect(banners.length, 1);
      expect(banners.first.title, 'Promo 1');
    });

    test('getCategoryTree sends GET /api/v1/catalog/categories/tree', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/catalog/categories/tree');

          return ResponseBody.fromString(
            '[{"id": "c1", "name": "Fashion", "slug": "fashion", "sortOrder": 1, "isActive": true, "children": []}]',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final tree = await dataSource.getCategoryTree();
      expect(tree.length, 1);
      expect(tree.first.name, 'Fashion');
    });

    test('getProducts sends GET /api/v1/catalog/products with page/filter params', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/catalog/products');
          expect(options.queryParameters['categoryId'], 'cat_100');
          expect(options.queryParameters['page'], 1);

          return ResponseBody.fromString(
            '{"items": [{"id": "p10", "name": "Shirt", "slug": "shirt", "categoryId": "cat_100", "status": 1, "basePrice": 49.9, "isActive": true, "isFeatured": false}], "totalCount": 1, "page": 1, "pageSize": 20}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final paged = await dataSource.getProducts(categoryId: 'cat_100', page: 1);
      expect(paged.items.length, 1);
      expect(paged.items.first.name, 'Shirt');
    });

    test('getProductBySlug sends GET /api/v1/catalog/products/slug/{slug}', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/catalog/products/slug/blue-jeans');

          return ResponseBody.fromString(
            '{"id": "p20", "name": "Blue Jeans", "slug": "blue-jeans", "categoryId": "c1", "status": 1, "basePrice": 89.9, "isActive": true, "isFeatured": false}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final product = await dataSource.getProductBySlug('blue-jeans');
      expect(product.id, 'p20');
      expect(product.name, 'Blue Jeans');
    });
  });
}

class _MockHttpAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

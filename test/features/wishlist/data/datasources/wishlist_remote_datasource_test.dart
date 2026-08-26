import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/add_wishlist_item_request_model.dart';

void main() {
  group('WishlistRemoteDataSource Tests', () {
    late Dio dio;
    late WishlistRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://localhost:7291'));
      dataSource = WishlistRemoteDataSourceImpl(dio: dio);
    });

    test('getWishlist sends GET /api/v1/wishlist/my', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/wishlist/my');

          return ResponseBody.fromString(
            '{"id": "w1", "customerId": "cust1", "itemCount": 0, "items": []}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final wishlist = await dataSource.getWishlist();
      expect(wishlist.id, 'w1');
      expect(wishlist.customerId, 'cust1');
    });

    test('addWishlistItem sends POST /api/v1/wishlist/my/items', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'POST');
          expect(options.path, '/api/v1/wishlist/my/items');

          return ResponseBody.fromString(
            '{"id": "w1", "customerId": "cust1", "itemCount": 1, "items": []}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      const request = AddWishlistItemRequestModel(
        productId: 'p1',
        variantId: 'v1',
      );

      final wishlist = await dataSource.addWishlistItem(request);
      expect(wishlist.itemCount, 1);
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

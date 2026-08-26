import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:wovzo_mobile/features/cart/data/models/add_cart_item_request_model.dart';

void main() {
  group('CartRemoteDataSource Tests', () {
    late Dio dio;
    late CartRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://localhost:7291'));
      dataSource = CartRemoteDataSourceImpl(dio: dio);
    });

    test('getCart sends GET /api/v1/cart/{customerId}', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/cart/cust1');

          return ResponseBody.fromString(
            '{"id": "c1", "customerId": "cust1", "status": 1, "totalQuantity": 1, "subtotal": 50.0, "discountTotal": 0.0, "grandTotal": 50.0, "items": []}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      final cart = await dataSource.getCart('cust1');
      expect(cart.id, 'c1');
      expect(cart.customerId, 'cust1');
    });

    test('addCartItem sends POST /api/v1/cart/items', () async {
      dio.httpClientAdapter = _MockHttpAdapter(
        (options) {
          expect(options.method, 'POST');
          expect(options.path, '/api/v1/cart/items');

          return ResponseBody.fromString(
            '{"id": "c1", "customerId": "cust1", "status": 1, "totalQuantity": 2, "subtotal": 100.0, "discountTotal": 0.0, "grandTotal": 100.0, "items": []}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      const request = AddCartItemRequestModel(
        customerId: 'cust1',
        productVariantId: 'v1',
        productId: 'p1',
        skuSnapshot: 'SKU1',
        productNameSnapshot: 'P1',
        variantNameSnapshot: 'V1',
        unitPriceSnapshot: 50.0,
        quantity: 2,
      );

      final cart = await dataSource.addCartItem(request);
      expect(cart.totalQuantity, 2);
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

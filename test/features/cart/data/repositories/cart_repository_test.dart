import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:wovzo_mobile/features/cart/data/models/add_cart_item_request_model.dart';
import 'package:wovzo_mobile/features/cart/data/models/cart_model.dart';
import 'package:wovzo_mobile/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:wovzo_mobile/features/cart/domain/repositories/cart_repository.dart';

class FakeCartRemoteDataSource implements CartRemoteDataSource {
  bool shouldThrow = false;

  @override
  Future<CartModel> getCart(String customerId) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/cart/$customerId'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/cart/$customerId'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return CartModel(id: 'c1', customerId: customerId, status: 1, totalQuantity: 1, subtotal: 10, discountTotal: 0, grandTotal: 10);
  }

  @override
  Future<CartModel> addCartItem(AddCartItemRequestModel request) async => throw UnimplementedError();

  @override
  Future<CartModel> updateCartItemQuantity({required String customerId, required String productVariantId, required int quantity}) async => throw UnimplementedError();

  @override
  Future<CartModel> removeCartItem({required String customerId, required String productVariantId}) async => throw UnimplementedError();

  @override
  Future<CartModel> clearCart(String customerId) async => throw UnimplementedError();
}

void main() {
  group('CartRepositoryImpl Tests', () {
    late FakeCartRemoteDataSource fakeDataSource;
    late CartRepository repository;

    setUp(() {
      fakeDataSource = FakeCartRemoteDataSource();
      repository = CartRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('getCart delegates to datasource', () async {
      final cart = await repository.getCart('cust1');
      expect(cart.customerId, 'cust1');
    });

    test('getCart maps 404 response to ApiNotFoundException', () async {
      fakeDataSource.shouldThrow = true;

      expect(
        () => repository.getCart('invalid_cust'),
        throwsA(isA<ApiNotFoundException>()),
      );
    });
  });
}

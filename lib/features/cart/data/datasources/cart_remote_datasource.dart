import 'package:dio/dio.dart';
import '../models/add_cart_item_request_model.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart(String customerId);
  Future<CartModel> addCartItem(AddCartItemRequestModel request);
  Future<CartModel> updateCartItemQuantity({
    required String customerId,
    required String productVariantId,
    required int quantity,
  });
  Future<CartModel> removeCartItem({
    required String customerId,
    required String productVariantId,
  });
  Future<CartModel> clearCart(String customerId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio _dio;

  CartRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<CartModel> getCart(String customerId) async {
    final response = await _dio.get('/api/v1/cart/$customerId');
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> addCartItem(AddCartItemRequestModel request) async {
    final response = await _dio.post(
      '/api/v1/cart/items',
      data: request.toJson(),
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> updateCartItemQuantity({
    required String customerId,
    required String productVariantId,
    required int quantity,
  }) async {
    final response = await _dio.put(
      '/api/v1/cart/items/$productVariantId',
      data: {
        'customerId': customerId,
        'quantity': quantity,
      },
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> removeCartItem({
    required String customerId,
    required String productVariantId,
  }) async {
    final response = await _dio.delete(
      '/api/v1/cart/items/$productVariantId',
      data: {
        'customerId': customerId,
      },
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> clearCart(String customerId) async {
    final response = await _dio.delete('/api/v1/cart/$customerId');
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }
}

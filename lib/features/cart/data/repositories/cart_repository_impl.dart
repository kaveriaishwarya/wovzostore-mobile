import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/add_cart_item_request_model.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepositoryImpl({
    required CartRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<CartModel> getCart() async {
    try {
      return await _remoteDataSource.getCart();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CartModel> addCartItem(AddCartItemRequestModel request) async {
    try {
      return await _remoteDataSource.addCartItem(request);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CartModel> updateCartItemQuantity({
    required String productVariantId,
    required int quantity,
  }) async {
    try {
      return await _remoteDataSource.updateCartItemQuantity(
        productVariantId: productVariantId,
        quantity: quantity,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CartModel> removeCartItem({
    required String productVariantId,
  }) async {
    try {
      return await _remoteDataSource.removeCartItem(
        productVariantId: productVariantId,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CartModel> clearCart() async {
    try {
      return await _remoteDataSource.clearCart();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

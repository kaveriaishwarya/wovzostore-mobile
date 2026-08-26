import 'package:dio/dio.dart';
import '../models/add_wishlist_item_request_model.dart';
import '../models/wishlist_model.dart';

abstract class WishlistRemoteDataSource {
  Future<WishlistModel> getWishlist();
  Future<WishlistModel> addWishlistItem(AddWishlistItemRequestModel request);
  Future<WishlistModel> removeWishlistItem(String wishlistItemId);
  Future<void> clearWishlist();
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio _dio;

  WishlistRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<WishlistModel> getWishlist() async {
    final response = await _dio.get('/api/v1/wishlist/my');
    return WishlistModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<WishlistModel> addWishlistItem(AddWishlistItemRequestModel request) async {
    final response = await _dio.post(
      '/api/v1/wishlist/my/items',
      data: request.toJson(),
    );
    return WishlistModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<WishlistModel> removeWishlistItem(String wishlistItemId) async {
    final response = await _dio.delete('/api/v1/wishlist/my/items/$wishlistItemId');
    return WishlistModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> clearWishlist() async {
    await _dio.post('/api/v1/wishlist/my/clear');
  }
}

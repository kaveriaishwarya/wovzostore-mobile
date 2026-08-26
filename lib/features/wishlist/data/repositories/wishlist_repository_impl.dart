import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';
import '../models/add_wishlist_item_request_model.dart';
import '../models/wishlist_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl({required WishlistRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<WishlistModel> getWishlist() async {
    try {
      return await _remoteDataSource.getWishlist();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<WishlistModel> addWishlistItem(AddWishlistItemRequestModel request) async {
    try {
      return await _remoteDataSource.addWishlistItem(request);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<WishlistModel> removeWishlistItem(String wishlistItemId) async {
    try {
      return await _remoteDataSource.removeWishlistItem(wishlistItemId);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> clearWishlist() async {
    try {
      await _remoteDataSource.clearWishlist();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

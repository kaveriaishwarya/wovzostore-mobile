import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/add_wishlist_item_request_model.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/wishlist_model.dart';
import 'package:wovzo_mobile/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:wovzo_mobile/features/wishlist/domain/repositories/wishlist_repository.dart';

class FakeWishlistRemoteDataSource implements WishlistRemoteDataSource {
  bool shouldThrow = false;

  @override
  Future<WishlistModel> getWishlist() async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/wishlist/my'),
        type: DioExceptionType.connectionTimeout,
      );
    }
    return const WishlistModel(id: 'w1', customerId: 'cust1', itemCount: 0);
  }

  @override
  Future<WishlistModel> addWishlistItem(AddWishlistItemRequestModel request) async => throw UnimplementedError();

  @override
  Future<WishlistModel> removeWishlistItem(String wishlistItemId) async => throw UnimplementedError();

  @override
  Future<void> clearWishlist() async => throw UnimplementedError();
}

void main() {
  group('WishlistRepositoryImpl Tests', () {
    late FakeWishlistRemoteDataSource fakeDataSource;
    late WishlistRepository repository;

    setUp(() {
      fakeDataSource = FakeWishlistRemoteDataSource();
      repository = WishlistRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('getWishlist delegates to remote datasource', () async {
      final wishlist = await repository.getWishlist();
      expect(wishlist.id, 'w1');
    });

    test('getWishlist maps connection timeout to ApiTimeoutException', () async {
      fakeDataSource.shouldThrow = true;

      expect(
        () => repository.getWishlist(),
        throwsA(isA<ApiTimeoutException>()),
      );
    });
  });
}

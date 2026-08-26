import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/add_wishlist_item_request_model.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:wovzo_mobile/features/wishlist/data/models/wishlist_model.dart';
import 'package:wovzo_mobile/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:wovzo_mobile/features/wishlist/presentation/bloc/wishlist_cubit.dart';
import 'package:wovzo_mobile/features/wishlist/presentation/bloc/wishlist_state.dart';

class MockWishlistRepository implements WishlistRepository {
  bool loadShouldFail = false;
  bool addShouldFail = false;
  bool removeShouldFail = false;

  @override
  Future<WishlistModel> getWishlist() async {
    if (loadShouldFail) throw const ApiTimeoutException(message: 'Request timeout');
    return const WishlistModel(
      id: 'w1',
      customerId: 'cust1',
      itemCount: 1,
      items: [
        WishlistItemModel(id: 'wi1', productId: 'p1', variantId: 'v1', addedAtUtc: '2026-08-26', productName: 'P1', variantName: 'V1', price: 100, isAvailable: true),
      ],
    );
  }

  @override
  Future<WishlistModel> addWishlistItem(AddWishlistItemRequestModel request) async {
    if (addShouldFail) throw const ApiNetworkException(message: 'Network error');
    return WishlistModel(
      id: 'w1',
      customerId: 'cust1',
      itemCount: 1,
      items: [
        WishlistItemModel(id: 'wi1', productId: request.productId, variantId: request.variantId, addedAtUtc: '2026-08-26', productName: 'P1', variantName: 'V1', price: 100, isAvailable: true),
      ],
    );
  }

  @override
  Future<WishlistModel> removeWishlistItem(String wishlistItemId) async {
    if (removeShouldFail) throw const ApiNetworkException(message: 'Remove error');
    return const WishlistModel(id: 'w1', customerId: 'cust1', itemCount: 0, items: []);
  }

  @override
  Future<void> clearWishlist() async {}
}

void main() {
  group('WishlistCubit Tests', () {
    late MockWishlistRepository repository;
    late WishlistCubit cubit;

    setUp(() {
      repository = MockWishlistRepository();
      cubit = WishlistCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is WishlistStatus.initial', () {
      expect(cubit.state.status, WishlistStatus.initial);
    });

    test('loadWishlist emits loading then success', () async {
      final states = <WishlistState>[];
      cubit.stream.listen(states.add);

      await cubit.loadWishlist();
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, WishlistStatus.loading);
      expect(states[1].status, WishlistStatus.success);
      expect(states[1].containsProduct('p1'), isTrue);
    });

    test('loadWishlist emits error state on failure', () async {
      repository.loadShouldFail = true;

      final states = <WishlistState>[];
      cubit.stream.listen(states.add);

      await cubit.loadWishlist();
      await Future.delayed(Duration.zero);

      expect(states.last.status, WishlistStatus.error);
      expect(states.last.errorMessage, 'Request timeout');
    });

    test('addItem emits updating then success', () async {
      const request = AddWishlistItemRequestModel(productId: 'p1', variantId: 'v1');

      final states = <WishlistState>[];
      cubit.stream.listen(states.add);

      await cubit.addItem(request);
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, WishlistStatus.updating);
      expect(states[1].status, WishlistStatus.success);
      expect(states[1].itemCount, 1);
    });

    test('removeItem emits updating then success', () async {
      final states = <WishlistState>[];
      cubit.stream.listen(states.add);

      await cubit.removeItem('wi1');
      await Future.delayed(Duration.zero);

      expect(states.last.status, WishlistStatus.success);
      expect(states.last.itemCount, 0);
    });
  });
}

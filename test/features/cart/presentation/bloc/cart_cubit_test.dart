import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/cart/data/models/add_cart_item_request_model.dart';
import 'package:wovzo_mobile/features/cart/data/models/cart_model.dart';
import 'package:wovzo_mobile/features/cart/domain/repositories/cart_repository.dart';
import 'package:wovzo_mobile/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:wovzo_mobile/features/cart/presentation/bloc/cart_state.dart';

class MockCartRepository implements CartRepository {
  bool loadShouldFail = false;
  bool addShouldFail = false;
  bool updateShouldFail = false;
  bool removeShouldFail = false;
  bool clearShouldFail = false;

  @override
  Future<CartModel> getCart(String customerId) async {
    if (loadShouldFail) throw const ApiNotFoundException(message: 'Cart not found');
    return CartModel(id: 'c1', customerId: customerId, status: 1, totalQuantity: 1, subtotal: 50, discountTotal: 0, grandTotal: 50);
  }

  @override
  Future<CartModel> addCartItem(AddCartItemRequestModel request) async {
    if (addShouldFail) throw const ApiNetworkException(message: 'Network error');
    return CartModel(id: 'c1', customerId: request.customerId, status: 1, totalQuantity: request.quantity, subtotal: 100, discountTotal: 0, grandTotal: 100);
  }

  @override
  Future<CartModel> updateCartItemQuantity({required String customerId, required String productVariantId, required int quantity}) async {
    if (updateShouldFail) throw const ApiNetworkException(message: 'Update error');
    return CartModel(id: 'c1', customerId: customerId, status: 1, totalQuantity: quantity, subtotal: 150, discountTotal: 0, grandTotal: 150);
  }

  @override
  Future<CartModel> removeCartItem({required String customerId, required String productVariantId}) async {
    if (removeShouldFail) throw const ApiNetworkException(message: 'Remove error');
    return CartModel(id: 'c1', customerId: customerId, status: 1, totalQuantity: 0, subtotal: 0, discountTotal: 0, grandTotal: 0);
  }

  @override
  Future<CartModel> clearCart(String customerId) async {
    if (clearShouldFail) throw const ApiNetworkException(message: 'Clear error');
    return CartModel(id: 'c1', customerId: customerId, status: 1, totalQuantity: 0, subtotal: 0, discountTotal: 0, grandTotal: 0);
  }
}

void main() {
  group('CartCubit Tests', () {
    late MockCartRepository repository;
    late CartCubit cubit;

    setUp(() {
      repository = MockCartRepository();
      cubit = CartCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is CartStatus.initial', () {
      expect(cubit.state.status, CartStatus.initial);
    });

    test('loadCart emits loading then success', () async {
      final states = <CartState>[];
      cubit.stream.listen(states.add);

      await cubit.loadCart('cust1');
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, CartStatus.loading);
      expect(states[1].status, CartStatus.success);
      expect(states[1].cart?.customerId, 'cust1');
    });

    test('loadCart emits error on failure', () async {
      repository.loadShouldFail = true;

      final states = <CartState>[];
      cubit.stream.listen(states.add);

      await cubit.loadCart('cust1');
      await Future.delayed(Duration.zero);

      expect(states.last.status, CartStatus.error);
      expect(states.last.errorMessage, 'Cart not found');
    });

    test('addItem emits updating then success', () async {
      const request = AddCartItemRequestModel(
        customerId: 'cust1',
        productVariantId: 'v1',
        productId: 'p1',
        skuSnapshot: 'SKU1',
        productNameSnapshot: 'P1',
        variantNameSnapshot: 'V1',
        unitPriceSnapshot: 50,
        quantity: 2,
      );

      final states = <CartState>[];
      cubit.stream.listen(states.add);

      await cubit.addItem(request);
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, CartStatus.updating);
      expect(states[1].status, CartStatus.success);
      expect(states[1].cart?.totalQuantity, 2);
    });

    test('updateQuantity emits updating then success', () async {
      final states = <CartState>[];
      cubit.stream.listen(states.add);

      await cubit.updateQuantity(customerId: 'cust1', productVariantId: 'v1', quantity: 3);
      await Future.delayed(Duration.zero);

      expect(states.last.status, CartStatus.success);
      expect(states.last.cart?.totalQuantity, 3);
    });

    test('removeItem emits updating then success', () async {
      final states = <CartState>[];
      cubit.stream.listen(states.add);

      await cubit.removeItem(customerId: 'cust1', productVariantId: 'v1');
      await Future.delayed(Duration.zero);

      expect(states.last.status, CartStatus.success);
      expect(states.last.cart?.totalQuantity, 0);
    });

    test('clearCart emits updating then success', () async {
      final states = <CartState>[];
      cubit.stream.listen(states.add);

      await cubit.clearCart('cust1');
      await Future.delayed(Duration.zero);

      expect(states.last.status, CartStatus.success);
      expect(states.last.cart?.totalQuantity, 0);
    });
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/add_cart_item_request_model.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;

  CartCubit({required CartRepository repository})
      : _repository = repository,
        super(const CartState());

  Future<void> loadCart(String customerId) async {
    emit(state.copyWith(status: CartStatus.loading));

    try {
      final cart = await _repository.getCart(customerId);
      emit(state.copyWith(
        status: CartStatus.success,
        cart: cart,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addItem(AddCartItemRequestModel request) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final cart = await _repository.addCartItem(request);
      emit(state.copyWith(
        status: CartStatus.success,
        cart: cart,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateQuantity({
    required String customerId,
    required String productVariantId,
    required int quantity,
  }) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final cart = await _repository.updateCartItemQuantity(
        customerId: customerId,
        productVariantId: productVariantId,
        quantity: quantity,
      );
      emit(state.copyWith(
        status: CartStatus.success,
        cart: cart,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> removeItem({
    required String customerId,
    required String productVariantId,
  }) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final cart = await _repository.removeCartItem(
        customerId: customerId,
        productVariantId: productVariantId,
      );
      emit(state.copyWith(
        status: CartStatus.success,
        cart: cart,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> clearCart(String customerId) async {
    emit(state.copyWith(status: CartStatus.updating));

    try {
      final cart = await _repository.clearCart(customerId);
      emit(state.copyWith(
        status: CartStatus.success,
        cart: cart,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

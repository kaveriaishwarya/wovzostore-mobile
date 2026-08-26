import 'package:equatable/equatable.dart';
import '../../data/models/cart_model.dart';

enum CartStatus { initial, loading, success, updating, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartModel? cart;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.errorMessage,
  });

  bool get isLoading => status == CartStatus.loading;
  bool get isUpdating => status == CartStatus.updating;
  bool get isSuccess => status == CartStatus.success;
  bool get isError => status == CartStatus.error;
  int get itemCount => cart?.totalQuantity ?? 0;

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage];
}

import '../../data/models/add_cart_item_request_model.dart';
import '../../data/models/cart_model.dart';

abstract class CartRepository {
  Future<CartModel> getCart();
  Future<CartModel> addCartItem(AddCartItemRequestModel request);
  Future<CartModel> updateCartItemQuantity({
    required String productVariantId,
    required int quantity,
  });
  Future<CartModel> removeCartItem({
    required String productVariantId,
  });
  Future<CartModel> clearCart();
}

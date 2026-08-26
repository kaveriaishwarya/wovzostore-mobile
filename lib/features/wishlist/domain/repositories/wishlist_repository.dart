import '../../data/models/add_wishlist_item_request_model.dart';
import '../../data/models/wishlist_model.dart';

abstract class WishlistRepository {
  Future<WishlistModel> getWishlist();
  Future<WishlistModel> addWishlistItem(AddWishlistItemRequestModel request);
  Future<WishlistModel> removeWishlistItem(String wishlistItemId);
  Future<void> clearWishlist();
}

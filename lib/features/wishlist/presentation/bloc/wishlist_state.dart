import 'package:equatable/equatable.dart';
import '../../data/models/wishlist_model.dart';

enum WishlistStatus { initial, loading, success, updating, error }

class WishlistState extends Equatable {
  final WishlistStatus status;
  final WishlistModel? wishlist;
  final String? errorMessage;

  const WishlistState({
    this.status = WishlistStatus.initial,
    this.wishlist,
    this.errorMessage,
  });

  bool get isLoading => status == WishlistStatus.loading;
  bool get isUpdating => status == WishlistStatus.updating;
  bool get isSuccess => status == WishlistStatus.success;
  bool get isError => status == WishlistStatus.error;
  int get itemCount => wishlist?.itemCount ?? 0;

  bool containsProduct(String productId) {
    if (wishlist == null) return false;
    return wishlist!.items.any((item) => item.productId == productId);
  }

  String? getWishlistItemId(String productId) {
    if (wishlist == null) return null;
    try {
      return wishlist!.items.firstWhere((item) => item.productId == productId).id;
    } catch (_) {
      return null;
    }
  }

  WishlistState copyWith({
    WishlistStatus? status,
    WishlistModel? wishlist,
    String? errorMessage,
  }) {
    return WishlistState(
      status: status ?? this.status,
      wishlist: wishlist ?? this.wishlist,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, wishlist, errorMessage];
}

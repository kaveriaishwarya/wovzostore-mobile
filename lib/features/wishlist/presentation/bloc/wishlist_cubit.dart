import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/add_wishlist_item_request_model.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _repository;

  WishlistCubit({required WishlistRepository repository})
      : _repository = repository,
        super(const WishlistState());

  Future<void> loadWishlist() async {
    emit(state.copyWith(status: WishlistStatus.loading));

    try {
      final wishlist = await _repository.getWishlist();
      emit(state.copyWith(
        status: WishlistStatus.success,
        wishlist: wishlist,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addItem(AddWishlistItemRequestModel request) async {
    emit(state.copyWith(status: WishlistStatus.updating));

    try {
      final wishlist = await _repository.addWishlistItem(request);
      emit(state.copyWith(
        status: WishlistStatus.success,
        wishlist: wishlist,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> removeItem(String wishlistItemId) async {
    emit(state.copyWith(status: WishlistStatus.updating));

    try {
      final wishlist = await _repository.removeWishlistItem(wishlistItemId);
      emit(state.copyWith(
        status: WishlistStatus.success,
        wishlist: wishlist,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> clearWishlist() async {
    emit(state.copyWith(status: WishlistStatus.updating));

    try {
      await _repository.clearWishlist();
      await loadWishlist();
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

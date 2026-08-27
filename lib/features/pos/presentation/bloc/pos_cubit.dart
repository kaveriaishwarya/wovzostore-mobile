import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/data/models/product_variant_model.dart';
import '../../domain/repositories/pos_repository.dart';
import '../../data/models/pos_cart_item_model.dart';
import '../../data/models/pos_customer_model.dart';
import 'pos_state.dart';

class PosCubit extends Cubit<PosState> {
  final PosRepository _repository;

  PosCubit({required PosRepository repository})
      : _repository = repository,
        super(const PosState());

  Future<void> searchProducts(String query) async {
    emit(state.copyWith(status: PosStatus.loadingProducts));
    try {
      final result = await _repository.searchProducts(query);
      emit(state.copyWith(
        status: PosStatus.success,
        searchResults: result.data,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: PosStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PosStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void addItemFromProduct(ProductModel product, {ProductVariantModel? variant}) {
    final targetVariant = variant ?? (product.variants.isNotEmpty ? product.variants.first : null);
    if (targetVariant == null) return;

    final existingIndex = state.cartItems.indexWhere(
      (item) => item.productVariantId == targetVariant.id,
    );

    final updatedList = List<PosCartItemModel>.from(state.cartItems);

    if (existingIndex >= 0) {
      final existing = updatedList[existingIndex];
      updatedList[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      final firstImage = product.images.isNotEmpty ? product.images.first.imageUrl : null;
      updatedList.add(
        PosCartItemModel(
          productVariantId: targetVariant.id,
          productId: product.id,
          sku: targetVariant.sku,
          productName: product.name,
          variantName: targetVariant.name,
          unitPrice: targetVariant.price,
          quantity: 1,
          imageUrl: targetVariant.imageUrl ?? firstImage,
        ),
      );
    }

    emit(state.copyWith(
      status: PosStatus.success,
      cartItems: updatedList,
    ));
  }

  void updateQuantity(String variantId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(variantId);
      return;
    }

    final updatedList = state.cartItems.map((item) {
      if (item.productVariantId == variantId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(
      status: PosStatus.success,
      cartItems: updatedList,
    ));
  }

  void removeItem(String variantId) {
    final updatedList = state.cartItems
        .where((item) => item.productVariantId != variantId)
        .toList();

    emit(state.copyWith(
      status: PosStatus.success,
      cartItems: updatedList,
    ));
  }

  void selectCustomer(PosCustomerModel customer) {
    emit(state.copyWith(selectedCustomer: customer));
  }

  void selectPaymentMethod(int method, String methodName) {
    emit(state.copyWith(
      selectedPaymentMethod: method,
      selectedPaymentMethodName: methodName,
    ));
  }

  void clearCart() {
    emit(state.copyWith(
      cartItems: const [],
      selectedCustomer: PosCustomerModel.walkIn,
      clearCompletedSale: true,
    ));
  }

  Future<void> completeSale() async {
    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(status: PosStatus.submitting));
    try {
      final result = await _repository.processPosSale(
        customer: state.selectedCustomer,
        items: state.cartItems,
        paymentMethod: state.selectedPaymentMethod,
        paymentMethodName: state.selectedPaymentMethodName,
      );

      emit(state.copyWith(
        status: PosStatus.saleCompleted,
        completedSale: result,
        cartItems: const [],
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: PosStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PosStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

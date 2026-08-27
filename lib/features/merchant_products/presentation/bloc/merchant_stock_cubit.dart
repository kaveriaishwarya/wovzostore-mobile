import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/merchant_product_repository.dart';
import 'merchant_stock_state.dart';

class MerchantStockCubit extends Cubit<MerchantStockState> {
  final MerchantProductRepository _repository;

  MerchantStockCubit({required MerchantProductRepository repository})
      : _repository = repository,
        super(const MerchantStockState());

  Future<void> setQuantity(String variantId, int quantity) async {
    emit(state.copyWith(status: MerchantStockStatus.updating));
    try {
      await _repository.setInventoryQuantity(variantId, quantity);
      emit(state.copyWith(status: MerchantStockStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantStockStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> adjustQuantity(String variantId, int adjustment) async {
    emit(state.copyWith(status: MerchantStockStatus.updating));
    try {
      await _repository.adjustInventoryQuantity(variantId, adjustment);
      emit(state.copyWith(status: MerchantStockStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantStockStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> updateThreshold(String variantId, int threshold) async {
    emit(state.copyWith(status: MerchantStockStatus.updating));
    try {
      await _repository.updateLowStockThreshold(variantId, threshold);
      emit(state.copyWith(status: MerchantStockStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantStockStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

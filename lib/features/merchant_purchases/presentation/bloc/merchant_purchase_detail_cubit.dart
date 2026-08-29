import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/purchase_order_model.dart';
import '../../domain/repositories/merchant_purchases_repository.dart';
import 'merchant_purchase_detail_state.dart';

class MerchantPurchaseDetailCubit extends Cubit<MerchantPurchaseDetailState> {
  final MerchantPurchasesRepository repository;

  MerchantPurchaseDetailCubit({required this.repository})
      : super(const MerchantPurchaseDetailInitial());

  Future<void> loadPurchaseDetail(String id) async {
    emit(const MerchantPurchaseDetailLoading());
    try {
      final purchase = await repository.getPurchaseById(id);
      emit(MerchantPurchaseDetailLoaded(purchase: purchase));
    } on ApiException catch (e) {
      emit(MerchantPurchaseDetailError(message: e.message));
    } catch (e) {
      emit(MerchantPurchaseDetailError(message: e.toString()));
    }
  }

  Future<void> markAsOrdered() async {
    final currentState = state;
    if (currentState is! MerchantPurchaseDetailLoaded || currentState.isSubmitting) return;

    emit(currentState.copyWith(
      isSubmitting: true,
      clearActionError: true,
      clearActionSuccess: true,
    ));

    try {
      await repository.markAsOrdered(currentState.purchase.id);
      final updatedPurchase = await repository.getPurchaseById(currentState.purchase.id);
      emit(currentState.copyWith(
        purchase: updatedPurchase,
        isSubmitting: false,
        actionSuccessMessage: 'Purchase Order marked as Ordered.',
      ));
    } on ApiException catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        actionError: e.message,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        actionError: e.toString(),
      ));
    }
  }

  Future<void> receiveItems(ReceivePurchaseItemsRequestModel request) async {
    final currentState = state;
    if (currentState is! MerchantPurchaseDetailLoaded || currentState.isSubmitting) return;

    emit(currentState.copyWith(
      isSubmitting: true,
      clearActionError: true,
      clearActionSuccess: true,
    ));

    try {
      final updatedPurchase = await repository.receiveItems(currentState.purchase.id, request);
      emit(currentState.copyWith(
        purchase: updatedPurchase,
        isSubmitting: false,
        actionSuccessMessage: 'Items received successfully. Inventory updated.',
      ));
    } on ApiException catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        actionError: e.message,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        actionError: e.toString(),
      ));
    }
  }

  Future<void> cancelPurchaseOrder({String? reason}) async {
    final currentState = state;
    if (currentState is! MerchantPurchaseDetailLoaded || currentState.isSubmitting) return;

    emit(currentState.copyWith(
      isSubmitting: true,
      clearActionError: true,
      clearActionSuccess: true,
    ));

    try {
      await repository.cancelPurchaseOrder(currentState.purchase.id, reason: reason);
      final updatedPurchase = await repository.getPurchaseById(currentState.purchase.id);
      emit(currentState.copyWith(
        purchase: updatedPurchase,
        isSubmitting: false,
        actionSuccessMessage: 'Purchase Order cancelled.',
      ));
    } on ApiException catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        actionError: e.message,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        actionError: e.toString(),
      ));
    }
  }
}

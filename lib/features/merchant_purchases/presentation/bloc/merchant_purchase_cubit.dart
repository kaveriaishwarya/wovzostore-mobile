import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/purchase_order_model.dart';
import '../../domain/repositories/merchant_purchases_repository.dart';
import 'merchant_purchase_state.dart';

class MerchantPurchaseCubit extends Cubit<MerchantPurchaseState> {
  final MerchantPurchasesRepository repository;

  MerchantPurchaseCubit({required this.repository})
      : super(const MerchantPurchaseInitial());

  Future<void> loadPurchases({
    String? supplierId,
    PurchaseOrderStatus? status,
    String? search,
    bool refresh = false,
  }) async {
    try {
      if (refresh || state is! MerchantPurchaseLoaded) {
        emit(const MerchantPurchaseLoading());
      }

      final result = await repository.getPurchases(
        supplierId: supplierId,
        status: status?.value,
        search: search,
        page: 1,
        pageSize: 20,
      );

      emit(MerchantPurchaseLoaded(
        purchases: result.data,
        totalCount: result.totalCount,
        page: 1,
        hasMore: result.hasNextPage,
        supplierIdFilter: supplierId,
        statusFilter: status,
        search: search,
      ));
    } on ApiException catch (e) {
      emit(MerchantPurchaseError(message: e.message));
    } catch (e) {
      emit(MerchantPurchaseError(message: e.toString()));
    }
  }

  Future<void> loadMorePurchases() async {
    final currentState = state;
    if (currentState is! MerchantPurchaseLoaded ||
        !currentState.hasMore ||
        currentState.isActionSubmitting) {
      return;
    }

    try {
      final nextPage = currentState.page + 1;
      final result = await repository.getPurchases(
        supplierId: currentState.supplierIdFilter,
        status: currentState.statusFilter?.value,
        search: currentState.search,
        page: nextPage,
        pageSize: 20,
      );

      final updatedPurchases = [...currentState.purchases, ...result.data];

      emit(currentState.copyWith(
        purchases: updatedPurchases,
        totalCount: result.totalCount,
        page: nextPage,
        hasMore: result.hasNextPage,
      ));
    } catch (_) {
      // Keep current state on loadMore failure
    }
  }

  Future<void> createPurchaseOrder(CreatePurchaseOrderRequestModel request) async {
    final currentState = state;
    if (currentState is MerchantPurchaseLoaded) {
      if (currentState.isActionSubmitting) return; // Prevent duplicate submission
      emit(currentState.copyWith(
        isActionSubmitting: true,
        clearActionError: true,
        clearActionSuccess: true,
      ));
    }

    try {
      final created = await repository.createPurchaseOrder(request);
      if (currentState is MerchantPurchaseLoaded) {
        final updatedList = [created, ...currentState.purchases];
        emit(currentState.copyWith(
          purchases: updatedList,
          totalCount: currentState.totalCount + 1,
          isActionSubmitting: false,
          actionSuccessMessage: 'Purchase Order ${created.orderNumber} created in Draft status.',
        ));
      } else {
        await loadPurchases(refresh: true);
      }
    } on ApiException catch (e) {
      if (currentState is MerchantPurchaseLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.message,
        ));
      } else {
        emit(MerchantPurchaseError(message: e.message));
      }
    } catch (e) {
      if (currentState is MerchantPurchaseLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.toString(),
        ));
      } else {
        emit(MerchantPurchaseError(message: e.toString()));
      }
    }
  }

  Future<void> markAsOrdered(String id) async {
    final currentState = state;
    if (currentState is MerchantPurchaseLoaded) {
      if (currentState.isActionSubmitting) return;
      emit(currentState.copyWith(
        isActionSubmitting: true,
        clearActionError: true,
        clearActionSuccess: true,
      ));
    }

    try {
      await repository.markAsOrdered(id);
      if (currentState is MerchantPurchaseLoaded) {
        final updatedList = currentState.purchases.map((p) {
          if (p.id == id) {
            return PurchaseOrderModel(
              id: p.id,
              orderNumber: p.orderNumber,
              supplierId: p.supplierId,
              supplierName: p.supplierName,
              status: PurchaseOrderStatus.ordered,
              statusName: PurchaseOrderStatus.ordered.displayName,
              totalAmount: p.totalAmount,
              expectedDeliveryDate: p.expectedDeliveryDate,
              notes: p.notes,
              createdByAdminId: p.createdByAdminId,
              receivedAt: p.receivedAt,
              items: p.items,
              createdAt: p.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return p;
        }).toList();

        emit(currentState.copyWith(
          purchases: updatedList,
          isActionSubmitting: false,
          actionSuccessMessage: 'Purchase order marked as Ordered.',
        ));
      }
    } on ApiException catch (e) {
      if (currentState is MerchantPurchaseLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.message,
        ));
      }
    }
  }

  Future<void> cancelPurchaseOrder(String id, {String? reason}) async {
    final currentState = state;
    if (currentState is MerchantPurchaseLoaded) {
      if (currentState.isActionSubmitting) return;
      emit(currentState.copyWith(
        isActionSubmitting: true,
        clearActionError: true,
        clearActionSuccess: true,
      ));
    }

    try {
      await repository.cancelPurchaseOrder(id, reason: reason);
      if (currentState is MerchantPurchaseLoaded) {
        final updatedList = currentState.purchases.map((p) {
          if (p.id == id) {
            return PurchaseOrderModel(
              id: p.id,
              orderNumber: p.orderNumber,
              supplierId: p.supplierId,
              supplierName: p.supplierName,
              status: PurchaseOrderStatus.cancelled,
              statusName: PurchaseOrderStatus.cancelled.displayName,
              totalAmount: p.totalAmount,
              expectedDeliveryDate: p.expectedDeliveryDate,
              notes: p.notes,
              createdByAdminId: p.createdByAdminId,
              receivedAt: p.receivedAt,
              items: p.items,
              createdAt: p.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return p;
        }).toList();

        emit(currentState.copyWith(
          purchases: updatedList,
          isActionSubmitting: false,
          actionSuccessMessage: 'Purchase order cancelled.',
        ));
      }
    } on ApiException catch (e) {
      if (currentState is MerchantPurchaseLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.message,
        ));
      }
    }
  }
}

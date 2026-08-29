import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/supplier_model.dart';
import '../../domain/repositories/merchant_purchases_repository.dart';
import 'merchant_supplier_state.dart';

class MerchantSupplierCubit extends Cubit<MerchantSupplierState> {
  final MerchantPurchasesRepository repository;

  MerchantSupplierCubit({required this.repository})
      : super(const MerchantSupplierInitial());

  Future<void> loadSuppliers({
    String? search,
    bool? isActive,
    bool refresh = false,
  }) async {
    try {
      if (refresh || state is! MerchantSupplierLoaded) {
        emit(const MerchantSupplierLoading());
      }

      final result = await repository.getSuppliers(
        search: search,
        isActive: isActive,
        page: 1,
        pageSize: 20,
      );

      emit(MerchantSupplierLoaded(
        suppliers: result.data,
        totalCount: result.totalCount,
        page: 1,
        hasMore: result.hasNextPage,
        search: search,
        isActiveFilter: isActive,
      ));
    } on ApiException catch (e) {
      emit(MerchantSupplierError(message: e.message));
    } catch (e) {
      emit(MerchantSupplierError(message: e.toString()));
    }
  }

  Future<void> loadMoreSuppliers() async {
    final currentState = state;
    if (currentState is! MerchantSupplierLoaded ||
        !currentState.hasMore ||
        currentState.isActionSubmitting) {
      return;
    }

    try {
      final nextPage = currentState.page + 1;
      final result = await repository.getSuppliers(
        search: currentState.search,
        isActive: currentState.isActiveFilter,
        page: nextPage,
        pageSize: 20,
      );

      final updatedSuppliers = [...currentState.suppliers, ...result.data];

      emit(currentState.copyWith(
        suppliers: updatedSuppliers,
        totalCount: result.totalCount,
        page: nextPage,
        hasMore: result.hasNextPage,
      ));
    } catch (_) {
      // Keep current state on loadMore failure
    }
  }

  Future<void> createSupplier(CreateSupplierRequestModel request) async {
    final currentState = state;
    if (currentState is MerchantSupplierLoaded) {
      if (currentState.isActionSubmitting) return; // Prevent duplicate submission
      emit(currentState.copyWith(
        isActionSubmitting: true,
        clearActionError: true,
        clearActionSuccess: true,
      ));
    }

    try {
      final created = await repository.createSupplier(request);
      if (currentState is MerchantSupplierLoaded) {
        final updatedList = [created, ...currentState.suppliers];
        emit(currentState.copyWith(
          suppliers: updatedList,
          totalCount: currentState.totalCount + 1,
          isActionSubmitting: false,
          actionSuccessMessage: 'Supplier "${created.name}" created successfully.',
        ));
      } else {
        await loadSuppliers(refresh: true);
      }
    } on ApiException catch (e) {
      if (currentState is MerchantSupplierLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.message,
        ));
      } else {
        emit(MerchantSupplierError(message: e.message));
      }
    } catch (e) {
      if (currentState is MerchantSupplierLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.toString(),
        ));
      } else {
        emit(MerchantSupplierError(message: e.toString()));
      }
    }
  }

  Future<void> updateSupplier(String id, UpdateSupplierRequestModel request) async {
    final currentState = state;
    if (currentState is MerchantSupplierLoaded) {
      if (currentState.isActionSubmitting) return; // Prevent duplicate submission
      emit(currentState.copyWith(
        isActionSubmitting: true,
        clearActionError: true,
        clearActionSuccess: true,
      ));
    }

    try {
      final updated = await repository.updateSupplier(id, request);
      if (currentState is MerchantSupplierLoaded) {
        final updatedList = currentState.suppliers
            .map((s) => s.id == id ? updated : s)
            .toList();
        emit(currentState.copyWith(
          suppliers: updatedList,
          isActionSubmitting: false,
          actionSuccessMessage: 'Supplier "${updated.name}" updated successfully.',
        ));
      } else {
        await loadSuppliers(refresh: true);
      }
    } on ApiException catch (e) {
      if (currentState is MerchantSupplierLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.message,
        ));
      }
    } catch (e) {
      if (currentState is MerchantSupplierLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.toString(),
        ));
      }
    }
  }

  Future<void> activateSupplier(String id) async {
    final currentState = state;
    if (currentState is MerchantSupplierLoaded) {
      if (currentState.isActionSubmitting) return;
      emit(currentState.copyWith(
        isActionSubmitting: true,
        clearActionError: true,
        clearActionSuccess: true,
      ));
    }

    try {
      await repository.activateSupplier(id);
      if (currentState is MerchantSupplierLoaded) {
        final updatedList = currentState.suppliers.map((s) {
          if (s.id == id) {
            return SupplierModel(
              id: s.id,
              name: s.name,
              contactPerson: s.contactPerson,
              email: s.email,
              phone: s.phone,
              address: s.address,
              gstin: s.gstin,
              isActive: true,
              createdAt: s.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return s;
        }).toList();

        emit(currentState.copyWith(
          suppliers: updatedList,
          isActionSubmitting: false,
          actionSuccessMessage: 'Supplier activated successfully.',
        ));
      }
    } on ApiException catch (e) {
      if (currentState is MerchantSupplierLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.message,
        ));
      }
    }
  }

  Future<void> deactivateSupplier(String id) async {
    final currentState = state;
    if (currentState is MerchantSupplierLoaded) {
      if (currentState.isActionSubmitting) return;
      emit(currentState.copyWith(
        isActionSubmitting: true,
        clearActionError: true,
        clearActionSuccess: true,
      ));
    }

    try {
      await repository.deactivateSupplier(id);
      if (currentState is MerchantSupplierLoaded) {
        final updatedList = currentState.suppliers.map((s) {
          if (s.id == id) {
            return SupplierModel(
              id: s.id,
              name: s.name,
              contactPerson: s.contactPerson,
              email: s.email,
              phone: s.phone,
              address: s.address,
              gstin: s.gstin,
              isActive: false,
              createdAt: s.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return s;
        }).toList();

        emit(currentState.copyWith(
          suppliers: updatedList,
          isActionSubmitting: false,
          actionSuccessMessage: 'Supplier deactivated successfully.',
        ));
      }
    } on ApiException catch (e) {
      if (currentState is MerchantSupplierLoaded) {
        emit(currentState.copyWith(
          isActionSubmitting: false,
          actionError: e.message,
        ));
      }
    }
  }
}

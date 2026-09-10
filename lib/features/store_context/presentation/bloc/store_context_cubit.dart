import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/store_dto.dart';
import '../../domain/repositories/store_repository.dart';
import 'store_context_state.dart';

class StoreContextCubit extends Cubit<StoreContextState> {
  final StoreRepository _repository;
  final SecureStorageService _secureStorage;

  StoreContextCubit({
    required StoreRepository repository,
    required SecureStorageService secureStorage,
  })  : _repository = repository,
        _secureStorage = secureStorage,
        super(const StoreContextInitial());

  /// Restores active store ID from local storage and fetches available stores.
  Future<void> loadStoresAndRestoreContext() async {
    emit(const StoreContextLoading());
    try {
      final savedStoreId = await _secureStorage.getActiveStoreId();
      final stores = await _repository.getMyStores();

      StoreDto? activeStore;
      String? activeStoreId = savedStoreId;

      if (savedStoreId != null && savedStoreId.isNotEmpty) {
        try {
          activeStore = stores.firstWhere((s) => s.id == savedStoreId);
        } catch (_) {
          // The saved store ID is not in the user's merchant stores.
          // It might be a customer-only store. We do NOT clear activeStoreId.
          // activeStore remains null because we don't have its details from /stores/me.
        }
      }

      if (activeStoreId == null && stores.length == 1) {
        activeStore = stores.first;
        activeStoreId = activeStore.id;
        await _secureStorage.saveActiveStoreId(activeStoreId);
      }

      emit(StoreContextLoaded(
        availableStores: stores,
        activeStoreId: activeStoreId,
        activeStore: activeStore,
      ));
    } on ApiException catch (e) {
      emit(StoreContextError(e.message));
    } catch (e) {
      emit(StoreContextError(e.toString()));
    }
  }

  /// Sets the active store and persists the selection.
  Future<void> setActiveStore(String storeId) async {
    final currentState = state;
    if (currentState is! StoreContextLoaded) return;

    try {
      final selectedStore = currentState.availableStores.firstWhere((s) => s.id == storeId);
      
      await _secureStorage.saveActiveStoreId(storeId);

      emit(currentState.copyWith(
        activeStoreId: () => storeId,
        activeStore: () => selectedStore,
      ));
    } catch (_) {
      // Store ID not found in available stores
      emit(const StoreContextError('Selected store not available.'));
      // Restore loaded state without changing selection
      emit(currentState);
    }
  }

  /// Clears the store context (used on logout).
  Future<void> clear() async {
    await _secureStorage.clearActiveStoreId();
    emit(const StoreContextInitial());
  }
}

import '../../data/models/store_dto.dart';

abstract class StoreContextState {
  const StoreContextState();
}

class StoreContextInitial extends StoreContextState {
  const StoreContextInitial();
}

class StoreContextLoading extends StoreContextState {
  const StoreContextLoading();
}

class StoreContextLoaded extends StoreContextState {
  final List<StoreDto> availableStores;
  final String? activeStoreId;
  final StoreDto? activeStore;

  const StoreContextLoaded({
    required this.availableStores,
    this.activeStoreId,
    this.activeStore,
  });

  StoreContextLoaded copyWith({
    List<StoreDto>? availableStores,
    String? Function()? activeStoreId,
    StoreDto? Function()? activeStore,
  }) {
    return StoreContextLoaded(
      availableStores: availableStores ?? this.availableStores,
      activeStoreId: activeStoreId != null ? activeStoreId() : this.activeStoreId,
      activeStore: activeStore != null ? activeStore() : this.activeStore,
    );
  }
}

class StoreContextError extends StoreContextState {
  final String message;

  const StoreContextError(this.message);
}

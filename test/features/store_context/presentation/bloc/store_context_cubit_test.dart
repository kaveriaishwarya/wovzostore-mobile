import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/store_context/data/models/store_dto.dart';
import 'package:wovzo_mobile/features/store_context/domain/repositories/store_repository.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_cubit.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_state.dart';
import '../../../../core/storage/secure_storage_service_test.dart';

class _MockStoreRepository implements StoreRepository {
  List<StoreDto> storesToReturn = [];

  @override
  Future<List<StoreDto>> getMyStores() async {
    return storesToReturn;
  }

  @override
  Future<StoreDto> getStoreBySlug(String slug) async {
    return storesToReturn.firstWhere(
      (s) => s.slug == slug,
      orElse: () => throw Exception('Store not found'),
    );
  }
}

void main() {
  group('StoreContextCubit Tests', () {
    late _MockStoreRepository mockRepository;
    late MemorySecureStorageService storage;
    late StoreContextCubit cubit;

    const store1 = StoreDto(id: 's1', name: 'Store 1', slug: 's1', role: 'Merchant');
    const store2 = StoreDto(id: 's2', name: 'Store 2', slug: 's2', role: 'Customer');

    setUp(() {
      mockRepository = _MockStoreRepository();
      storage = MemorySecureStorageService();
      cubit = StoreContextCubit(repository: mockRepository, secureStorage: storage);
    });

    tearDown(() {
      cubit.close();
    });

    test('loadStoresAndRestoreContext loads stores and restores active store if exists', () async {
      mockRepository.storesToReturn = [store1, store2];
      await storage.saveActiveStoreId('s2');

      await cubit.loadStoresAndRestoreContext();

      final state = cubit.state;
      expect(state, isA<StoreContextLoaded>());
      final loadedState = state as StoreContextLoaded;
      expect(loadedState.availableStores.length, 2);
      expect(loadedState.activeStoreId, 's2');
      expect(loadedState.activeStore?.id, 's2');
      expect(loadedState.activeStore?.role, 'Customer');
    });

    test('loadStoresAndRestoreContext retains activeStoreId even if absent from merchant stores', () async {
      mockRepository.storesToReturn = [store1];
      await storage.saveActiveStoreId('customer_only_store');

      await cubit.loadStoresAndRestoreContext();

      final state = cubit.state as StoreContextLoaded;
      expect(state.availableStores.length, 1);
      // It should retain the customer-only store ID, but activeStore object is null
      expect(state.activeStoreId, 'customer_only_store');
      expect(state.activeStore, isNull);
      
      final savedStoreId = await storage.getActiveStoreId();
      expect(savedStoreId, 'customer_only_store');
    });

    test('loadStoresAndRestoreContext auto-selects if exactly 1 store and no active store exists', () async {
      mockRepository.storesToReturn = [store1];
      
      await cubit.loadStoresAndRestoreContext();

      final state = cubit.state as StoreContextLoaded;
      expect(state.availableStores.length, 1);
      expect(state.activeStoreId, 's1');
      expect(state.activeStore?.id, 's1');

      final savedStoreId = await storage.getActiveStoreId();
      expect(savedStoreId, 's1');
    });

    test('setActiveStore sets active store and persists', () async {
      mockRepository.storesToReturn = [store1, store2];
      await cubit.loadStoresAndRestoreContext(); // Initially no active store

      await cubit.setActiveStore('s1');

      final state = cubit.state as StoreContextLoaded;
      expect(state.activeStoreId, 's1');
      expect(state.activeStore?.name, 'Store 1');

      final savedStoreId = await storage.getActiveStoreId();
      expect(savedStoreId, 's1');
    });

    test('clear resets state and storage (used on logout)', () async {
      mockRepository.storesToReturn = [store1];
      await storage.saveActiveStoreId('s1');
      await cubit.loadStoresAndRestoreContext();

      await cubit.clear();

      expect(cubit.state, isA<StoreContextInitial>());
      final savedStoreId = await storage.getActiveStoreId();
      expect(savedStoreId, isNull);
    });
  });
}

import '../../data/models/store_dto.dart';

abstract class StoreRepository {
  Future<List<StoreDto>> getMyStores();
}

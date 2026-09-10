import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart';
import '../models/store_dto.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource _remoteDataSource;

  StoreRepositoryImpl({required StoreRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<StoreDto>> getMyStores() async {
    return await _remoteDataSource.getMyStores();
  }

  @override
  Future<StoreDto> getStoreBySlug(String slug) async {
    return await _remoteDataSource.getStoreBySlug(slug);
  }
}

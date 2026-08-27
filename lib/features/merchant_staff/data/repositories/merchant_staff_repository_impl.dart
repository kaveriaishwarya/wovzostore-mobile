import '../../../analytics/data/models/paged_result_model.dart';
import '../../domain/repositories/merchant_staff_repository.dart';
import '../datasources/merchant_staff_remote_datasource.dart';
import '../models/create_staff_request_model.dart';
import '../models/merchant_staff_model.dart';
import '../models/update_staff_request_model.dart';

class MerchantStaffRepositoryImpl implements MerchantStaffRepository {
  final MerchantStaffRemoteDataSource remoteDataSource;

  MerchantStaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PagedResult<MerchantStaffModel>> getStaff({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isActive,
  }) {
    return remoteDataSource.getStaff(
      page: page,
      pageSize: pageSize,
      search: search,
      role: role,
      isActive: isActive,
    );
  }

  @override
  Future<MerchantStaffModel> getStaffById(String id) {
    return remoteDataSource.getStaffById(id);
  }

  @override
  Future<MerchantStaffModel> createStaff(CreateStaffRequestModel request) {
    return remoteDataSource.createStaff(request);
  }

  @override
  Future<MerchantStaffModel> updateStaff(String id, UpdateStaffRequestModel request) {
    return remoteDataSource.updateStaff(id, request);
  }

  @override
  Future<void> activateStaff(String id) {
    return remoteDataSource.activateStaff(id);
  }

  @override
  Future<void> deactivateStaff(String id) {
    return remoteDataSource.deactivateStaff(id);
  }
}

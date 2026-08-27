import '../../../analytics/data/models/paged_result_model.dart';
import '../../data/models/create_staff_request_model.dart';
import '../../data/models/merchant_staff_model.dart';
import '../../data/models/update_staff_request_model.dart';

abstract class MerchantStaffRepository {
  Future<PagedResult<MerchantStaffModel>> getStaff({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isActive,
  });
  Future<MerchantStaffModel> getStaffById(String id);
  Future<MerchantStaffModel> createStaff(CreateStaffRequestModel request);
  Future<MerchantStaffModel> updateStaff(String id, UpdateStaffRequestModel request);
  Future<void> activateStaff(String id);
  Future<void> deactivateStaff(String id);
}

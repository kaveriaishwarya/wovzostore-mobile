import '../../../analytics/data/models/paged_result_model.dart';
import '../../../merchant_orders/data/models/order_model.dart';
import '../../data/models/merchant_customer_details_model.dart';
import '../../data/models/merchant_customer_model.dart';

abstract class MerchantCustomerRepository {
  Future<PagedResult<MerchantCustomerModel>> getCustomers({
    int page = 1,
    int pageSize = 20,
    bool? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  });

  Future<MerchantCustomerDetailsModel> getCustomerById(String customerId);

  Future<void> updateCustomer(
    String customerId, {
    required String fullName,
    String? email,
    DateTime? dateOfBirth,
  });

  Future<void> activateCustomer(String customerId);
  Future<void> deactivateCustomer(String customerId);
  Future<List<OrderModel>> getCustomerOrders(String customerId);
}

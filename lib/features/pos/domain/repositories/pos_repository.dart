import '../../../analytics/data/models/paged_result_model.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../data/models/pos_cart_item_model.dart';
import '../../data/models/pos_customer_model.dart';
import '../../data/models/pos_sale_result_model.dart';

abstract class PosRepository {
  Future<PagedResult<ProductModel>> searchProducts(String query, {int page = 1, int pageSize = 20});
  Future<List<PosCustomerModel>> getCustomers(String query);
  Future<PosSaleResultModel> processPosSale({
    required PosCustomerModel customer,
    required List<PosCartItemModel> items,
    required int paymentMethod,
    required String paymentMethodName,
  });
}

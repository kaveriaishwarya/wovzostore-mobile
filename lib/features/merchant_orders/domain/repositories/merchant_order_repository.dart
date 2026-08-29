import 'dart:typed_data';
import '../../../analytics/data/models/paged_result_model.dart';
import '../../data/models/order_list_model.dart';
import '../../data/models/order_model.dart';

abstract class MerchantOrderRepository {
  Future<PagedResult<OrderListModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  });

  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> getOrderByOrderNumber(String orderNumber);
  /// Retrieves the tax invoice HTML bytes for the given order.
  Future<Uint8List> getInvoice(String orderId);

  Future<OrderModel> confirmOrder(String orderId, {String? comment, String? adminId});
  Future<OrderModel> startProcessingOrder(String orderId, {String? comment, String? adminId});
  Future<OrderModel> packOrder(String orderId, {String? comment, String? adminId});
  Future<OrderModel> shipOrder(String orderId, {String? comment, String? adminId});
  Future<OrderModel> markOutForDelivery(String orderId, {String? comment, String? adminId});
  Future<OrderModel> deliverOrder(String orderId, {String? comment, String? adminId});
  Future<OrderModel> cancelOrder(String orderId, String reason);
  Future<OrderModel> approveReturn(String orderId, {String? comment, String? adminId});
  Future<OrderModel> completeReturn(String orderId, {String? comment, String? adminId});
}

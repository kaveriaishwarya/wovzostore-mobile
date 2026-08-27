import 'package:dio/dio.dart';
import '../../../analytics/data/models/paged_result_model.dart';
import '../models/order_list_model.dart';
import '../models/order_model.dart';
import '../models/order_transition_request_model.dart';

abstract class MerchantOrderRemoteDataSource {
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

class MerchantOrderRemoteDataSourceImpl implements MerchantOrderRemoteDataSource {
  final Dio _dio;

  MerchantOrderRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PagedResult<OrderListModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty) 'sortDirection': sortDirection,
    };

    final response = await _dio.get(
      '/api/v1/orders',
      queryParameters: queryParams,
    );

    return PagedResult<OrderListModel>.fromJson(
      response.data,
      (itemJson) => OrderListModel.fromJson(itemJson),
    );
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _dio.get('/api/v1/orders/$orderId');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> getOrderByOrderNumber(String orderNumber) async {
    final response = await _dio.get('/api/v1/orders/order-number/$orderNumber');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> confirmOrder(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/confirm',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> startProcessingOrder(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/processing',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> packOrder(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/pack',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> shipOrder(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/ship',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> markOutForDelivery(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/out-for-delivery',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> deliverOrder(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/deliver',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> cancelOrder(String orderId, String reason) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/cancel',
      data: CancelOrderRequestModel(reason: reason).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> approveReturn(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/approve-return',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> completeReturn(String orderId, {String? comment, String? adminId}) async {
    final response = await _dio.post(
      '/api/v1/orders/$orderId/complete-return',
      data: OrderStatusTransitionRequestModel(comment: comment, adminId: adminId).toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}

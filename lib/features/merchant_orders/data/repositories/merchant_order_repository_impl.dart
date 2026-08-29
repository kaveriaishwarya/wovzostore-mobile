import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../analytics/data/models/paged_result_model.dart';
import '../../domain/repositories/merchant_order_repository.dart';
import '../datasources/merchant_order_remote_datasource.dart';
import '../models/order_list_model.dart';
import '../models/order_model.dart';

class MerchantOrderRepositoryImpl implements MerchantOrderRepository {
  final MerchantOrderRemoteDataSource _remoteDataSource;

  MerchantOrderRepositoryImpl({required MerchantOrderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiServerException(message: e.toString());
    }
  }

  @override
  Future<PagedResult<OrderListModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) {
    return _guard(() => _remoteDataSource.getOrders(
          page: page,
          pageSize: pageSize,
          status: status,
          search: search,
          sortBy: sortBy,
          sortDirection: sortDirection,
        ));
  }

  @override
  Future<OrderModel> getOrderById(String orderId) {
    return _guard(() => _remoteDataSource.getOrderById(orderId));
  }

  @override
  Future<OrderModel> getOrderByOrderNumber(String orderNumber) {
    return _guard(() => _remoteDataSource.getOrderByOrderNumber(orderNumber));
  }

  @override
  Future<OrderModel> confirmOrder(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.confirmOrder(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<OrderModel> startProcessingOrder(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.startProcessingOrder(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<OrderModel> packOrder(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.packOrder(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<OrderModel> shipOrder(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.shipOrder(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<OrderModel> markOutForDelivery(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.markOutForDelivery(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<OrderModel> deliverOrder(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.deliverOrder(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<OrderModel> cancelOrder(String orderId, String reason) {
    return _guard(() => _remoteDataSource.cancelOrder(orderId, reason));
  }

  @override
  Future<OrderModel> approveReturn(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.approveReturn(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<OrderModel> completeReturn(String orderId, {String? comment, String? adminId}) {
    return _guard(() => _remoteDataSource.completeReturn(orderId, comment: comment, adminId: adminId));
  }

  @override
  Future<Uint8List> getInvoice(String orderId) {
    return _guard(() => _remoteDataSource.fetchOrderInvoice(orderId));
  }
}

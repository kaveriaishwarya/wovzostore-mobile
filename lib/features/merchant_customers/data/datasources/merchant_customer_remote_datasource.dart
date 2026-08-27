import 'package:dio/dio.dart';
import '../../../analytics/data/models/paged_result_model.dart';
import '../../../merchant_orders/data/models/order_model.dart';
import '../models/merchant_customer_details_model.dart';
import '../models/merchant_customer_model.dart';

abstract class MerchantCustomerRemoteDataSource {
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

class MerchantCustomerRemoteDataSourceImpl implements MerchantCustomerRemoteDataSource {
  final Dio _dio;

  MerchantCustomerRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PagedResult<MerchantCustomerModel>> getCustomers({
    int page = 1,
    int pageSize = 20,
    bool? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) async {
    final response = await _dio.get(
      '/api/v1/customers',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortDirection != null) 'sortDirection': sortDirection,
      },
    );

    return PagedResult<MerchantCustomerModel>.fromJson(
      response.data,
      (itemJson) => MerchantCustomerModel.fromJson(itemJson),
    );
  }

  @override
  Future<MerchantCustomerDetailsModel> getCustomerById(String customerId) async {
    final response = await _dio.get('/api/v1/customers/$customerId');
    return MerchantCustomerDetailsModel.fromJson(response.data);
  }

  @override
  Future<void> updateCustomer(
    String customerId, {
    required String fullName,
    String? email,
    DateTime? dateOfBirth,
  }) async {
    await _dio.put(
      '/api/v1/customers/$customerId',
      data: {
        'fullName': fullName,
        if (email != null) 'email': email,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      },
    );
  }

  @override
  Future<void> activateCustomer(String customerId) async {
    await _dio.post('/api/v1/customers/$customerId/activate');
  }

  @override
  Future<void> deactivateCustomer(String customerId) async {
    await _dio.post('/api/v1/customers/$customerId/deactivate');
  }

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    final response = await _dio.get('/api/v1/orders/customer/$customerId');
    final rawData = response.data as List<dynamic>? ?? [];
    return rawData.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}

import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../analytics/data/models/paged_result_model.dart';
import '../../../merchant_orders/data/models/order_model.dart';
import '../../domain/repositories/merchant_customer_repository.dart';
import '../datasources/merchant_customer_remote_datasource.dart';
import '../models/merchant_customer_details_model.dart';
import '../models/merchant_customer_model.dart';

class MerchantCustomerRepositoryImpl implements MerchantCustomerRepository {
  final MerchantCustomerRemoteDataSource _remoteDataSource;

  MerchantCustomerRepositoryImpl({
    required MerchantCustomerRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

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
  Future<PagedResult<MerchantCustomerModel>> getCustomers({
    int page = 1,
    int pageSize = 20,
    bool? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) {
    return _guard(() => _remoteDataSource.getCustomers(
          page: page,
          pageSize: pageSize,
          status: status,
          search: search,
          sortBy: sortBy,
          sortDirection: sortDirection,
        ));
  }

  @override
  Future<MerchantCustomerDetailsModel> getCustomerById(String customerId) {
    return _guard(() => _remoteDataSource.getCustomerById(customerId));
  }

  @override
  Future<void> updateCustomer(
    String customerId, {
    required String fullName,
    String? email,
    DateTime? dateOfBirth,
  }) {
    return _guard(() => _remoteDataSource.updateCustomer(
          customerId,
          fullName: fullName,
          email: email,
          dateOfBirth: dateOfBirth,
        ));
  }

  @override
  Future<void> activateCustomer(String customerId) {
    return _guard(() => _remoteDataSource.activateCustomer(customerId));
  }

  @override
  Future<void> deactivateCustomer(String customerId) {
    return _guard(() => _remoteDataSource.deactivateCustomer(customerId));
  }

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) {
    return _guard(() => _remoteDataSource.getCustomerOrders(customerId));
  }
}

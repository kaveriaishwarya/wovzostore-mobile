import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../analytics/data/models/paged_result_model.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/pos_remote_datasource.dart';
import '../models/pos_cart_item_model.dart';
import '../models/pos_customer_model.dart';
import '../models/pos_sale_result_model.dart';

class PosRepositoryImpl implements PosRepository {
  final PosRemoteDataSource _remoteDataSource;

  PosRepositoryImpl({required PosRemoteDataSource remoteDataSource})
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
  Future<PagedResult<ProductModel>> searchProducts(String query, {int page = 1, int pageSize = 20}) {
    return _guard(() => _remoteDataSource.searchProducts(query, page: page, pageSize: pageSize));
  }

  @override
  Future<List<PosCustomerModel>> getCustomers(String query) {
    return _guard(() => _remoteDataSource.getCustomers(query));
  }

  @override
  Future<PosSaleResultModel> processPosSale({
    required PosCustomerModel customer,
    required List<PosCartItemModel> items,
    required int paymentMethod,
    required String paymentMethodName,
  }) {
    return _guard(() => _remoteDataSource.processPosSale(
          customer: customer,
          items: items,
          paymentMethod: paymentMethod,
          paymentMethodName: paymentMethodName,
        ));
  }
}

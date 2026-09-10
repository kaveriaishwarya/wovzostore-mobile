import 'package:dio/dio.dart';

abstract class CustomerRemoteDataSource {
  Future<void> onboardCustomer();
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final Dio _dio;

  CustomerRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<void> onboardCustomer() async {
    // Interceptor already handles sending Bearer token and X-Store-Id
    await _dio.post('/api/v1/customers/onboard');
  }
}

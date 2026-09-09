import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../models/store_dto.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreDto>> getMyStores();
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final Dio _dio;

  StoreRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<StoreDto>> getMyStores() async {
    try {
      final response = await _dio.get('/api/v1/stores/me');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StoreDto.fromJson(json)).toList();
      }
      throw const ApiServerException(message: 'Failed to load stores');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }
}

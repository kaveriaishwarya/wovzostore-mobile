import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../models/store_dto.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreDto>> getMyStores();
  Future<StoreDto> getStoreBySlug(String slug);
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

  @override
  Future<StoreDto> getStoreBySlug(String slug) async {
    try {
      // Endpoint is public, so no auth required strictly for this call
      final response = await _dio.get('/api/v1/stores/$slug');
      if (response.statusCode == 200) {
        return StoreDto.fromJson(response.data);
      }
      throw const ApiServerException(message: 'Failed to load store');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ApiServerException(message: 'Store not found');
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }
}

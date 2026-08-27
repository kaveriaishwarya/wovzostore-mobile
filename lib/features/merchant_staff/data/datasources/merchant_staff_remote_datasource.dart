import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../analytics/data/models/paged_result_model.dart';
import '../models/create_staff_request_model.dart';
import '../models/merchant_staff_model.dart';
import '../models/update_staff_request_model.dart';

abstract class MerchantStaffRemoteDataSource {
  Future<PagedResult<MerchantStaffModel>> getStaff({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isActive,
  });
  Future<MerchantStaffModel> getStaffById(String id);
  Future<MerchantStaffModel> createStaff(CreateStaffRequestModel request);
  Future<MerchantStaffModel> updateStaff(String id, UpdateStaffRequestModel request);
  Future<void> activateStaff(String id);
  Future<void> deactivateStaff(String id);
}

class MerchantStaffRemoteDataSourceImpl implements MerchantStaffRemoteDataSource {
  final Dio dio;

  MerchantStaffRemoteDataSourceImpl({required this.dio});

  @override
  Future<PagedResult<MerchantStaffModel>> getStaff({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await dio.get('/api/v1/staff', queryParameters: queryParams);

      return PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => MerchantStaffModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<MerchantStaffModel> getStaffById(String id) async {
    try {
      final response = await dio.get('/api/v1/staff/$id');
      return MerchantStaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<MerchantStaffModel> createStaff(CreateStaffRequestModel request) async {
    try {
      final response = await dio.post('/api/v1/staff', data: request.toJson());
      return MerchantStaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<MerchantStaffModel> updateStaff(String id, UpdateStaffRequestModel request) async {
    try {
      final response = await dio.put('/api/v1/staff/$id', data: request.toJson());
      return MerchantStaffModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> activateStaff(String id) async {
    try {
      await dio.post('/api/v1/staff/$id/activate');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> deactivateStaff(String id) async {
    try {
      await dio.post('/api/v1/staff/$id/deactivate');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: e.toString());
    }
  }
}

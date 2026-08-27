import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../models/store_settings_model.dart';

abstract class MerchantSettingsRemoteDataSource {
  Future<StoreSettingsModel> getStoreSettings();
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings);
}

class MerchantSettingsRemoteDataSourceImpl implements MerchantSettingsRemoteDataSource {
  final Dio dio;

  MerchantSettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<StoreSettingsModel> getStoreSettings() async {
    try {
      final response = await dio.get('/api/v1/settings/store');
      return StoreSettingsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: 'Failed to load store settings: $e');
    }
  }

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) async {
    try {
      final response = await dio.put(
        '/api/v1/settings/store',
        data: settings.toJson(),
      );
      return StoreSettingsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiUnknownException(message: 'Failed to update store settings: $e');
    }
  }
}

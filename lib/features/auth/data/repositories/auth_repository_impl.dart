import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<OtpSentResponseModel> requestOtp(String phone) async {
    try {
      return await _remoteDataSource.requestOtp(phone);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp(String phone, String otp) async {
    try {
      return await _remoteDataSource.verifyOtp(phone, otp);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      return await _remoteDataSource.getMe();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> updateProfile(String fullName) async {
    try {
      await _remoteDataSource.updateProfile(fullName);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiUnknownException(message: e.toString());
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _remoteDataSource.logout(refreshToken);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiUnknownException(message: e.toString());
    }
  }
}

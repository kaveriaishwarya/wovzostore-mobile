import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<OtpSentResponseModel> requestOtp(String phone);
  Future<AuthResponseModel> verifyOtp(String phone, String otp);
  Future<UserModel> getMe();
  Future<void> updateProfile(String fullName);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<OtpSentResponseModel> requestOtp(String phone) async {
    final response = await _dio.post(
      '/api/v1/auth/otp/request',
      data: {'phone': phone},
    );

    return OtpSentResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp(String phone, String otp) async {
    final response = await _dio.post(
      '/api/v1/auth/otp/verify',
      data: {
        'phone': phone,
        'otp': otp,
      },
    );

    return AuthResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dio.get('/api/v1/auth/me');

    return UserModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> updateProfile(String fullName) async {
    await _dio.put(
      '/api/v1/auth/me',
      data: {'fullName': fullName},
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dio.post(
      '/api/v1/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}

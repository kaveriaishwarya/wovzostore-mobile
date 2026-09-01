import '../../data/models/auth_response_model.dart';
import '../../data/models/otp_request_model.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<OtpSentResponseModel> requestOtp(String phone);
  Future<AuthResponseModel> verifyOtp(String phone, String otp);
  Future<UserModel> getCurrentUser();
  Future<void> updateProfile(String fullName);
  Future<void> logout(String refreshToken);
}

import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String accessTokenExpiresAt;
  final String refreshToken;
  final String refreshTokenExpiresAt;
  final bool isNewUser;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.isNewUser,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken']?.toString() ?? '',
      accessTokenExpiresAt: json['accessTokenExpiresAt']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      refreshTokenExpiresAt: json['refreshTokenExpiresAt']?.toString() ?? '',
      isNewUser: json['isNewUser'] is bool ? json['isNewUser'] as bool : false,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : const UserModel(userId: '', role: 'Customer'),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'accessTokenExpiresAt': accessTokenExpiresAt,
        'refreshToken': refreshToken,
        'refreshTokenExpiresAt': refreshTokenExpiresAt,
        'isNewUser': isNewUser,
        'user': user.toJson(),
      };
}

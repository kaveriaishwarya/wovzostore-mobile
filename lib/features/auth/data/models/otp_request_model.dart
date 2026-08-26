class OtpRequestModel {
  final String phone;

  const OtpRequestModel({required this.phone});

  Map<String, dynamic> toJson() => {
        'phone': phone,
      };
}

class OtpSentResponseModel {
  final String message;
  final int expiresInSeconds;
  final int resendCooldownSeconds;

  const OtpSentResponseModel({
    required this.message,
    required this.expiresInSeconds,
    required this.resendCooldownSeconds,
  });

  factory OtpSentResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpSentResponseModel(
      message: json['message']?.toString() ?? 'OTP sent successfully.',
      expiresInSeconds: json['expiresInSeconds'] is int
          ? json['expiresInSeconds'] as int
          : int.tryParse(json['expiresInSeconds']?.toString() ?? '') ?? 300,
      resendCooldownSeconds: json['resendCooldownSeconds'] is int
          ? json['resendCooldownSeconds'] as int
          : int.tryParse(json['resendCooldownSeconds']?.toString() ?? '') ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'expiresInSeconds': expiresInSeconds,
        'resendCooldownSeconds': resendCooldownSeconds,
      };
}

class OtpVerifyRequestModel {
  final String phone;
  final String otp;

  const OtpVerifyRequestModel({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };
}

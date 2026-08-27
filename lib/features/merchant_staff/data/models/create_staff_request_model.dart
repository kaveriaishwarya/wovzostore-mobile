class CreateStaffRequestModel {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final String password;

  const CreateStaffRequestModel({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'password': password,
    };
  }
}

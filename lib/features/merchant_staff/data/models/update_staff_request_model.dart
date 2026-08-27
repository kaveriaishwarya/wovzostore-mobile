class UpdateStaffRequestModel {
  final String fullName;
  final String? phoneNumber;
  final String role;

  const UpdateStaffRequestModel({
    required this.fullName,
    this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}

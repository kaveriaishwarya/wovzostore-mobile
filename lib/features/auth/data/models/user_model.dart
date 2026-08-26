class UserModel {
  final String userId;
  final String role;
  final String? phoneNumber;
  final String? email;
  final String? customerId;
  final String? displayName;
  final String? profileImageUrl;
  final bool isActive;
  final String? dateOfBirth;

  const UserModel({
    required this.userId,
    required this.role,
    this.phoneNumber,
    this.email,
    this.customerId,
    this.displayName,
    this.profileImageUrl,
    this.isActive = true,
    this.dateOfBirth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Customer',
      phoneNumber: json['phoneNumber']?.toString(),
      email: json['email']?.toString(),
      customerId: json['customerId']?.toString(),
      displayName: json['displayName']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      dateOfBirth: json['dateOfBirth']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'role': role,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
        if (customerId != null) 'customerId': customerId,
        if (displayName != null) 'displayName': displayName,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'isActive': isActive,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      };

  @override
  String toString() => 'UserModel(userId: $userId, role: $role, displayName: $displayName)';
}

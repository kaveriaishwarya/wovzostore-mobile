import 'package:equatable/equatable.dart';

class MerchantStaffModel extends Equatable {
  final String id;
  final String? fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const MerchantStaffModel({
    required this.id,
    this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory MerchantStaffModel.fromJson(Map<String, dynamic> json) {
    return MerchantStaffModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, fullName, email, phoneNumber, role, isActive, createdAt];
}

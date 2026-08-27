import 'package:equatable/equatable.dart';

class MerchantCustomerDetailsModel extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? dateOfBirth;
  final bool status;
  final DateTime createdAt;
  final String? defaultAddress;
  final int ordersCount;
  final double totalSpent;

  const MerchantCustomerDetailsModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.dateOfBirth,
    required this.status,
    required this.createdAt,
    this.defaultAddress,
    this.ordersCount = 0,
    this.totalSpent = 0.0,
  });

  factory MerchantCustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    return MerchantCustomerDetailsModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      status: json['status'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      defaultAddress: json['defaultAddress'] as String?,
      ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'defaultAddress': defaultAddress,
      'ordersCount': ordersCount,
      'totalSpent': totalSpent,
    };
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phoneNumber,
        isEmailVerified,
        isPhoneVerified,
        dateOfBirth,
        status,
        createdAt,
        defaultAddress,
        ordersCount,
        totalSpent,
      ];
}

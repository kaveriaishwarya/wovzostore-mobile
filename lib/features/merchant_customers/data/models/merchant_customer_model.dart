import 'package:equatable/equatable.dart';

class MerchantCustomerModel extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final bool status;
  final DateTime createdAt;
  final int ordersCount;
  final double totalSpent;

  const MerchantCustomerModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.ordersCount = 0,
    this.totalSpent = 0.0,
  });

  factory MerchantCustomerModel.fromJson(Map<String, dynamic> json) {
    return MerchantCustomerModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String? ?? '',
      status: json['status'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
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
      'status': status,
      'createdAt': createdAt.toIso8601String(),
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
        status,
        createdAt,
        ordersCount,
        totalSpent,
      ];
}

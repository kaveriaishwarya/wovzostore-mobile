import 'package:equatable/equatable.dart';

class OrderListModel extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final int status;
  final String statusName;
  final int paymentStatus;
  final String paymentStatusName;
  final int paymentMethod;
  final String paymentMethodName;
  final double grandTotal;
  final String currency;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderListModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.status,
    required this.statusName,
    required this.paymentStatus,
    required this.paymentStatusName,
    required this.paymentMethod,
    required this.paymentMethodName,
    required this.grandTotal,
    required this.currency,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderListModel.fromJson(Map<String, dynamic> json) {
    return OrderListModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      statusName: json['statusName'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as int? ?? 0,
      paymentStatusName: json['paymentStatusName'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as int? ?? 0,
      paymentMethodName: json['paymentMethodName'] as String? ?? '',
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'status': status,
      'statusName': statusName,
      'paymentStatus': paymentStatus,
      'paymentStatusName': paymentStatusName,
      'paymentMethod': paymentMethod,
      'paymentMethodName': paymentMethodName,
      'grandTotal': grandTotal,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        status,
        statusName,
        paymentStatus,
        paymentStatusName,
        paymentMethod,
        paymentMethodName,
        grandTotal,
        currency,
        createdAt,
        updatedAt,
      ];
}

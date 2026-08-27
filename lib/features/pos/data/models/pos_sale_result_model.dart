import 'package:equatable/equatable.dart';

class PosSaleResultModel extends Equatable {
  final String orderId;
  final String orderNumber;
  final double grandTotal;
  final int paymentMethod;
  final String paymentMethodName;
  final DateTime createdAt;

  const PosSaleResultModel({
    required this.orderId,
    required this.orderNumber,
    required this.grandTotal,
    required this.paymentMethod,
    required this.paymentMethodName,
    required this.createdAt,
  });

  factory PosSaleResultModel.fromJson(Map<String, dynamic> json) {
    return PosSaleResultModel(
      orderId: json['orderId'] as String? ?? json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as int? ?? 1,
      paymentMethodName: json['paymentMethodName'] as String? ?? 'Cash',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      'paymentMethodName': paymentMethodName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        grandTotal,
        paymentMethod,
        paymentMethodName,
        createdAt,
      ];
}

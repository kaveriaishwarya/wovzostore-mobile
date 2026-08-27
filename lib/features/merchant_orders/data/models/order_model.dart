import 'package:equatable/equatable.dart';

class AddressSnapshotModel extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pinCode;
  final String country;

  const AddressSnapshotModel({
    required this.fullName,
    required this.phoneNumber,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
  });

  factory AddressSnapshotModel.fromJson(Map<String, dynamic> json) {
    return AddressSnapshotModel(
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pinCode: json['pinCode'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'country': country,
    };
  }

  @override
  List<Object?> get props => [
        fullName,
        phoneNumber,
        line1,
        line2,
        city,
        state,
        pinCode,
        country,
      ];
}

class OrderSummaryModel extends Equatable {
  final double subtotal;
  final double discountTotal;
  final double shippingFee;
  final double taxAmount;
  final double grandTotal;
  final String currency;

  const OrderSummaryModel({
    required this.subtotal,
    required this.discountTotal,
    required this.shippingFee,
    required this.taxAmount,
    required this.grandTotal,
    required this.currency,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (json['discountTotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discountTotal': discountTotal,
      'shippingFee': shippingFee,
      'taxAmount': taxAmount,
      'grandTotal': grandTotal,
      'currency': currency,
    };
  }

  @override
  List<Object?> get props => [
        subtotal,
        discountTotal,
        shippingFee,
        taxAmount,
        grandTotal,
        currency,
      ];
}

class OrderItemModel extends Equatable {
  final String id;
  final String orderId;
  final String productVariantId;
  final String productId;
  final String sku;
  final String productName;
  final String variantName;
  final String? imageUrl;
  final double unitPrice;
  final double? comparePrice;
  final int quantity;
  final double lineTotal;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productVariantId,
    required this.productId,
    required this.sku,
    required this.productName,
    required this.variantName,
    this.imageUrl,
    required this.unitPrice,
    this.comparePrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      sku: json['sku'] as String? ?? json['SKU'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      variantName: json['variantName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      comparePrice: (json['comparePrice'] as num?)?.toDouble(),
      quantity: json['quantity'] as int? ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productVariantId': productVariantId,
      'productId': productId,
      'sku': sku,
      'productName': productName,
      'variantName': variantName,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'comparePrice': comparePrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productVariantId,
        productId,
        sku,
        productName,
        variantName,
        imageUrl,
        unitPrice,
        comparePrice,
        quantity,
        lineTotal,
      ];
}

class OrderStatusHistoryModel extends Equatable {
  final String id;
  final String orderId;
  final int status;
  final String statusName;
  final String? comment;
  final String? changedByAdminId;
  final DateTime changedAt;

  const OrderStatusHistoryModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.statusName,
    this.comment,
    this.changedByAdminId,
    required this.changedAt,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      statusName: json['statusName'] as String? ?? '',
      comment: json['comment'] as String?,
      changedByAdminId: json['changedByAdminId'] as String?,
      changedAt: json['changedAt'] != null
          ? DateTime.parse(json['changedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': status,
      'statusName': statusName,
      'comment': comment,
      'changedByAdminId': changedByAdminId,
      'changedAt': changedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        status,
        statusName,
        comment,
        changedByAdminId,
        changedAt,
      ];
}

class OrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final String checkoutId;
  final int status;
  final String statusName;
  final int paymentStatus;
  final String paymentStatusName;
  final int paymentMethod;
  final String paymentMethodName;
  final AddressSnapshotModel? shippingAddress;
  final AddressSnapshotModel? billingAddress;
  final OrderSummaryModel summary;
  final String? notes;
  final String? cancellationReason;
  final double? refundAmount;
  final DateTime? refundedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItemModel> items;
  final List<OrderStatusHistoryModel> statusHistory;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.checkoutId,
    required this.status,
    required this.statusName,
    required this.paymentStatus,
    required this.paymentStatusName,
    required this.paymentMethod,
    required this.paymentMethodName,
    this.shippingAddress,
    this.billingAddress,
    required this.summary,
    this.notes,
    this.cancellationReason,
    this.refundAmount,
    this.refundedAt,
    required this.createdAt,
    this.updatedAt,
    required this.items,
    required this.statusHistory,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      checkoutId: json['checkoutId'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      statusName: json['statusName'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as int? ?? 0,
      paymentStatusName: json['paymentStatusName'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as int? ?? 0,
      paymentMethodName: json['paymentMethodName'] as String? ?? '',
      shippingAddress: json['shippingAddress'] != null
          ? AddressSnapshotModel.fromJson(json['shippingAddress'] as Map<String, dynamic>)
          : null,
      billingAddress: json['billingAddress'] != null
          ? AddressSnapshotModel.fromJson(json['billingAddress'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] != null
          ? OrderSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : const OrderSummaryModel(
              subtotal: 0.0,
              discountTotal: 0.0,
              shippingFee: 0.0,
              taxAmount: 0.0,
              grandTotal: 0.0,
              currency: 'INR',
            ),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      statusHistory: json['statusHistory'] != null
          ? (json['statusHistory'] as List)
              .map((h) => OrderStatusHistoryModel.fromJson(h as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'checkoutId': checkoutId,
      'status': status,
      'statusName': statusName,
      'paymentStatus': paymentStatus,
      'paymentStatusName': paymentStatusName,
      'paymentMethod': paymentMethod,
      'paymentMethodName': paymentMethodName,
      'shippingAddress': shippingAddress?.toJson(),
      'billingAddress': billingAddress?.toJson(),
      'summary': summary.toJson(),
      'notes': notes,
      'cancellationReason': cancellationReason,
      'refundAmount': refundAmount,
      'refundedAt': refundedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'statusHistory': statusHistory.map((h) => h.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        checkoutId,
        status,
        statusName,
        paymentStatus,
        paymentStatusName,
        paymentMethod,
        paymentMethodName,
        shippingAddress,
        billingAddress,
        summary,
        notes,
        cancellationReason,
        refundAmount,
        refundedAt,
        createdAt,
        updatedAt,
        items,
        statusHistory,
      ];
}

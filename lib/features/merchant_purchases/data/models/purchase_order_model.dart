import 'package:equatable/equatable.dart';

enum PurchaseOrderStatus {
  draft(1, 'Draft'),
  ordered(2, 'Ordered'),
  partiallyReceived(3, 'Partially Received'),
  received(4, 'Received'),
  cancelled(5, 'Cancelled');

  final int value;
  final String displayName;

  const PurchaseOrderStatus(this.value, this.displayName);

  static PurchaseOrderStatus fromValue(int value) {
    return PurchaseOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PurchaseOrderStatus.draft,
    );
  }
}

class PurchaseOrderItemModel extends Equatable {
  final String id;
  final String productVariantId;
  final String variantName;
  final String sku;
  final int quantityOrdered;
  final int quantityReceived;
  final double unitCost;
  final double totalCost;
  final bool isFullyReceived;

  const PurchaseOrderItemModel({
    required this.id,
    required this.productVariantId,
    required this.variantName,
    required this.sku,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCost,
    required this.totalCost,
    required this.isFullyReceived,
  });

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemModel(
      id: json['id'] as String,
      productVariantId: json['productVariantId'] as String,
      variantName: json['variantName'] as String? ?? '',
      sku: json['sku'] as String? ?? json['SKU'] as String? ?? '',
      quantityOrdered: json['quantityOrdered'] as int? ?? 0,
      quantityReceived: json['quantityReceived'] as int? ?? 0,
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      isFullyReceived: json['isFullyReceived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productVariantId': productVariantId,
      'variantName': variantName,
      'sku': sku,
      'quantityOrdered': quantityOrdered,
      'quantityReceived': quantityReceived,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'isFullyReceived': isFullyReceived,
    };
  }

  @override
  List<Object?> get props => [
        id,
        productVariantId,
        variantName,
        sku,
        quantityOrdered,
        quantityReceived,
        unitCost,
        totalCost,
        isFullyReceived,
      ];
}

class PurchaseOrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final String supplierId;
  final String supplierName;
  final PurchaseOrderStatus status;
  final String statusName;
  final double totalAmount;
  final DateTime? expectedDeliveryDate;
  final String? notes;
  final String? createdByAdminId;
  final DateTime? receivedAt;
  final List<PurchaseOrderItemModel> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PurchaseOrderModel({
    required this.id,
    required this.orderNumber,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.statusName,
    required this.totalAmount,
    this.expectedDeliveryDate,
    this.notes,
    this.createdByAdminId,
    this.receivedAt,
    required this.items,
    required this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    final statusInt = json['status'] as int? ?? 1;
    final itemsRaw = json['items'] as List<dynamic>? ?? [];

    return PurchaseOrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String? ?? '',
      status: PurchaseOrderStatus.fromValue(statusInt),
      statusName: json['statusName'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      expectedDeliveryDate: json['expectedDeliveryDate'] != null
          ? DateTime.parse(json['expectedDeliveryDate'] as String)
          : null,
      notes: json['notes'] as String?,
      createdByAdminId: json['createdByAdminId'] as String?,
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : null,
      items: itemsRaw
          .map((item) => PurchaseOrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.value,
      'statusName': statusName,
      'totalAmount': totalAmount,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'notes': notes,
      'createdByAdminId': createdByAdminId,
      'receivedAt': receivedAt?.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        supplierId,
        supplierName,
        status,
        statusName,
        totalAmount,
        expectedDeliveryDate,
        notes,
        createdByAdminId,
        receivedAt,
        items,
        createdAt,
        updatedAt,
      ];
}

class CreatePurchaseOrderItemRequestModel extends Equatable {
  final String productVariantId;
  final int quantityOrdered;
  final double unitCost;

  const CreatePurchaseOrderItemRequestModel({
    required this.productVariantId,
    required this.quantityOrdered,
    required this.unitCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'productVariantId': productVariantId,
      'quantityOrdered': quantityOrdered,
      'unitCost': unitCost,
    };
  }

  @override
  List<Object?> get props => [productVariantId, quantityOrdered, unitCost];
}

class CreatePurchaseOrderRequestModel extends Equatable {
  final String supplierId;
  final DateTime? expectedDeliveryDate;
  final String? notes;
  final List<CreatePurchaseOrderItemRequestModel> items;

  const CreatePurchaseOrderRequestModel({
    required this.supplierId,
    this.expectedDeliveryDate,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'notes': notes,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [supplierId, expectedDeliveryDate, notes, items];
}

class ReceivePurchaseItemRequestModel extends Equatable {
  final String itemId;
  final int quantityToReceive;

  const ReceivePurchaseItemRequestModel({
    required this.itemId,
    required this.quantityToReceive,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'quantityToReceive': quantityToReceive,
    };
  }

  @override
  List<Object?> get props => [itemId, quantityToReceive];
}

class ReceivePurchaseItemsRequestModel extends Equatable {
  final List<ReceivePurchaseItemRequestModel> items;
  final String? notes;

  const ReceivePurchaseItemsRequestModel({
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [items, notes];
}

class CancelPurchaseOrderRequestModel extends Equatable {
  final String? reason;

  const CancelPurchaseOrderRequestModel({this.reason});

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
    };
  }

  @override
  List<Object?> get props => [reason];
}

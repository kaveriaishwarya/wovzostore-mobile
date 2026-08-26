import 'paged_result_model.dart';

/// Single inventory SKU item matching backend `InventoryItemReportDto`.
class InventoryItemReportModel {
  final String productId;
  final String? variantId;
  final String productName;
  final int currentStock;
  final int reservedStock;
  final int availableStock;
  final int lowStockThreshold;
  final double unitPrice;
  final double inventoryValue;
  final int unitsSoldInPeriod;
  final double stockVelocity;

  const InventoryItemReportModel({
    required this.productId,
    this.variantId,
    required this.productName,
    required this.currentStock,
    required this.reservedStock,
    required this.availableStock,
    required this.lowStockThreshold,
    required this.unitPrice,
    required this.inventoryValue,
    required this.unitsSoldInPeriod,
    required this.stockVelocity,
  });

  factory InventoryItemReportModel.fromJson(Map<String, dynamic> json) =>
      InventoryItemReportModel(
        productId: json['productId'] as String? ?? '',
        variantId: json['variantId'] as String?,
        productName: json['productName'] as String? ?? '',
        currentStock: json['currentStock'] as int? ?? 0,
        reservedStock: json['reservedStock'] as int? ?? 0,
        availableStock: json['availableStock'] as int? ?? 0,
        lowStockThreshold: json['lowStockThreshold'] as int? ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        inventoryValue: (json['inventoryValue'] as num?)?.toDouble() ?? 0.0,
        unitsSoldInPeriod: json['unitsSoldInPeriod'] as int? ?? 0,
        stockVelocity: (json['stockVelocity'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'variantId': variantId,
        'productName': productName,
        'currentStock': currentStock,
        'reservedStock': reservedStock,
        'availableStock': availableStock,
        'lowStockThreshold': lowStockThreshold,
        'unitPrice': unitPrice,
        'inventoryValue': inventoryValue,
        'unitsSoldInPeriod': unitsSoldInPeriod,
        'stockVelocity': stockVelocity,
      };
}

/// Complete inventory report matching backend `InventoryReportDto`.
class InventoryReportModel {
  final double totalInventoryValue;
  final int lowStockCount;
  final int outOfStockCount;
  final int totalUnits;
  final PagedResult<InventoryItemReportModel> items;

  const InventoryReportModel({
    required this.totalInventoryValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalUnits,
    required this.items,
  });

  factory InventoryReportModel.fromJson(Map<String, dynamic> json) =>
      InventoryReportModel(
        totalInventoryValue:
            (json['totalInventoryValue'] as num?)?.toDouble() ?? 0.0,
        lowStockCount: json['lowStockCount'] as int? ?? 0,
        outOfStockCount: json['outOfStockCount'] as int? ?? 0,
        totalUnits: json['totalUnits'] as int? ?? 0,
        items: json['items'] != null
            ? PagedResult.fromJson(
                json['items'] as Map<String, dynamic>,
                (item) => InventoryItemReportModel.fromJson(item),
              )
            : const PagedResult(
                data: [],
                pageNumber: 1,
                pageSize: 20,
                totalCount: 0,
                totalPages: 0,
                hasPreviousPage: false,
                hasNextPage: false,
              ),
      );

  Map<String, dynamic> toJson() => {
        'totalInventoryValue': totalInventoryValue,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
        'totalUnits': totalUnits,
        'items': items.toJson((item) => item.toJson()),
      };
}

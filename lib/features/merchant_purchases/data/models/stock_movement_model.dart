import 'package:equatable/equatable.dart';

enum StockMovementType {
  purchase(1, 'Purchase'),
  sale(2, 'Sale'),
  adjustment(3, 'Adjustment'),
  returnType(4, 'Return');

  final int value;
  final String displayName;

  const StockMovementType(this.value, this.displayName);

  static StockMovementType fromValue(int value) {
    return StockMovementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StockMovementType.adjustment,
    );
  }
}

class StockMovementModel extends Equatable {
  final String id;
  final String productVariantId;
  final String variantName;
  final String sku;
  final StockMovementType movementType;
  final String movementTypeName;
  final int quantityChange;
  final int previousQuantity;
  final int newQuantity;
  final String? referenceId;
  final String? notes;
  final String? createdByAdminId;
  final DateTime createdAt;

  const StockMovementModel({
    required this.id,
    required this.productVariantId,
    required this.variantName,
    required this.sku,
    required this.movementType,
    required this.movementTypeName,
    required this.quantityChange,
    required this.previousQuantity,
    required this.newQuantity,
    this.referenceId,
    this.notes,
    this.createdByAdminId,
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    final typeInt = json['movementType'] as int? ?? 3;
    return StockMovementModel(
      id: json['id'] as String,
      productVariantId: json['productVariantId'] as String,
      variantName: json['variantName'] as String? ?? '',
      sku: json['sku'] as String? ?? json['SKU'] as String? ?? '',
      movementType: StockMovementType.fromValue(typeInt),
      movementTypeName: json['movementTypeName'] as String? ?? '',
      quantityChange: json['quantityChange'] as int? ?? 0,
      previousQuantity: json['previousQuantity'] as int? ?? 0,
      newQuantity: json['newQuantity'] as int? ?? 0,
      referenceId: json['referenceId'] as String?,
      notes: json['notes'] as String?,
      createdByAdminId: json['createdByAdminId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productVariantId': productVariantId,
      'variantName': variantName,
      'sku': sku,
      'movementType': movementType.value,
      'movementTypeName': movementTypeName,
      'quantityChange': quantityChange,
      'previousQuantity': previousQuantity,
      'newQuantity': newQuantity,
      'referenceId': referenceId,
      'notes': notes,
      'createdByAdminId': createdByAdminId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        productVariantId,
        variantName,
        sku,
        movementType,
        movementTypeName,
        quantityChange,
        previousQuantity,
        newQuantity,
        referenceId,
        notes,
        createdByAdminId,
        createdAt,
      ];
}

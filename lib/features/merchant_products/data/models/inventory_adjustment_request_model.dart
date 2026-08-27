class SetInventoryQuantityRequestModel {
  final int quantity;

  const SetInventoryQuantityRequestModel({required this.quantity});

  Map<String, dynamic> toJson() => {'quantity': quantity};
}

class AdjustInventoryQuantityRequestModel {
  final int adjustment;

  const AdjustInventoryQuantityRequestModel({required this.adjustment});

  Map<String, dynamic> toJson() => {'adjustment': adjustment};
}

class UpdateLowStockThresholdRequestModel {
  final int threshold;

  const UpdateLowStockThresholdRequestModel({required this.threshold});

  Map<String, dynamic> toJson() => {'threshold': threshold};
}

class StoreSettingsModel {
  final String storeName;
  final String? logoUrl;
  final String? supportEmail;
  final String? supportPhone;
  final bool codEnabled;
  final double minOrderAmountForCod;
  final String defaultCurrency;
  final double? freeDeliveryThreshold;
  final double flatDeliveryCharge;
  final int estimatedDeliveryDays;
  final String? servicablePinCodes;
  final int returnWindowDays;
  final int replaceWindowDays;
  final bool returnAllowed;
  final String? policyText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StoreSettingsModel({
    required this.storeName,
    this.logoUrl,
    this.supportEmail,
    this.supportPhone,
    required this.codEnabled,
    required this.minOrderAmountForCod,
    required this.defaultCurrency,
    this.freeDeliveryThreshold,
    required this.flatDeliveryCharge,
    required this.estimatedDeliveryDays,
    this.servicablePinCodes,
    required this.returnWindowDays,
    required this.replaceWindowDays,
    required this.returnAllowed,
    this.policyText,
    required this.createdAt,
    this.updatedAt,
  });

  factory StoreSettingsModel.fromJson(Map<String, dynamic> json) {
    return StoreSettingsModel(
      storeName: json['storeName'] as String,
      logoUrl: json['logoUrl'] as String?,
      supportEmail: json['supportEmail'] as String?,
      supportPhone: json['supportPhone'] as String?,
      codEnabled: json['codEnabled'] as bool? ?? false,
      minOrderAmountForCod: (json['minOrderAmountForCod'] as num?)?.toDouble() ?? 0.0,
      defaultCurrency: json['defaultCurrency'] as String? ?? 'INR',
      freeDeliveryThreshold: (json['freeDeliveryThreshold'] as num?)?.toDouble(),
      flatDeliveryCharge: (json['flatDeliveryCharge'] as num?)?.toDouble() ?? 0.0,
      estimatedDeliveryDays: json['estimatedDeliveryDays'] as int? ?? 0,
      servicablePinCodes: json['servicablePinCodes'] as String?,
      returnWindowDays: json['returnWindowDays'] as int? ?? 0,
      replaceWindowDays: json['replaceWindowDays'] as int? ?? 0,
      returnAllowed: json['returnAllowed'] as bool? ?? false,
      policyText: json['policyText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'logoUrl': logoUrl,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'codEnabled': codEnabled,
      'minOrderAmountForCod': minOrderAmountForCod,
      'defaultCurrency': defaultCurrency,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'flatDeliveryCharge': flatDeliveryCharge,
      'estimatedDeliveryDays': estimatedDeliveryDays,
      'servicablePinCodes': servicablePinCodes,
      'returnWindowDays': returnWindowDays,
      'replaceWindowDays': replaceWindowDays,
      'returnAllowed': returnAllowed,
      'policyText': policyText,
    };
  }
}

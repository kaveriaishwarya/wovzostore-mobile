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
  final String? gstin;
  final String? legalName;
  final String? panNumber;
  final String? stateCode;
  final String? stateName;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? pinCode;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String invoicePrefix;
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
    this.gstin,
    this.legalName,
    this.panNumber,
    this.stateCode,
    this.stateName,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.pinCode,
    this.bankName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.invoicePrefix = 'INV-',
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
      gstin: json['gstin'] as String?,
      legalName: json['legalName'] as String?,
      panNumber: json['panNumber'] as String?,
      stateCode: json['stateCode'] as String?,
      stateName: json['stateName'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      pinCode: json['pinCode'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankIfscCode: json['bankIfscCode'] as String?,
      invoicePrefix: json['invoicePrefix'] as String? ?? 'INV-',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
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
      'gstin': gstin,
      'legalName': legalName,
      'panNumber': panNumber,
      'stateCode': stateCode,
      'stateName': stateName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'pinCode': pinCode,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankIfscCode': bankIfscCode,
      'invoicePrefix': invoicePrefix,
    };
  }
}

import 'package:equatable/equatable.dart';

class SupplierModel extends Equatable {
  final String id;
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final String? gstin;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupplierModel({
    required this.id,
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.gstin,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contactPerson: json['contactPerson'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      gstin: json['gstin'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'gstin': gstin,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        contactPerson,
        email,
        phone,
        address,
        gstin,
        isActive,
        createdAt,
        updatedAt,
      ];
}

class CreateSupplierRequestModel extends Equatable {
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final String? gstin;

  const CreateSupplierRequestModel({
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.gstin,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'gstin': gstin,
    };
  }

  @override
  List<Object?> get props => [name, contactPerson, email, phone, address, gstin];
}

class UpdateSupplierRequestModel extends Equatable {
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final String? gstin;

  const UpdateSupplierRequestModel({
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.gstin,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'gstin': gstin,
    };
  }

  @override
  List<Object?> get props => [name, contactPerson, email, phone, address, gstin];
}

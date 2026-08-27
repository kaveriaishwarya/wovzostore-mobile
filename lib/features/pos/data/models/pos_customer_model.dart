import 'package:equatable/equatable.dart';

class PosCustomerModel extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;

  const PosCustomerModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
  });

  static const PosCustomerModel walkIn = PosCustomerModel(
    id: '00000000-0000-0000-0000-000000000000',
    fullName: 'Walk-In Customer',
    phoneNumber: '0000000000',
  );

  factory PosCustomerModel.fromJson(Map<String, dynamic> json) {
    return PosCustomerModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Walk-In Customer',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id, fullName, phoneNumber, email];
}

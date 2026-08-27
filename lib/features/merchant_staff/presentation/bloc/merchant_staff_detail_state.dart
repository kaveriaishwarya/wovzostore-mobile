import 'package:equatable/equatable.dart';
import '../../data/models/merchant_staff_model.dart';

abstract class MerchantStaffDetailState extends Equatable {
  const MerchantStaffDetailState();

  @override
  List<Object?> get props => [];
}

class MerchantStaffDetailInitial extends MerchantStaffDetailState {}

class MerchantStaffDetailLoading extends MerchantStaffDetailState {}

class MerchantStaffDetailLoaded extends MerchantStaffDetailState {
  final MerchantStaffModel staff;

  const MerchantStaffDetailLoaded(this.staff);

  @override
  List<Object?> get props => [staff];
}

class MerchantStaffDetailActionSuccess extends MerchantStaffDetailState {
  final String message;
  final MerchantStaffModel? updatedStaff;

  const MerchantStaffDetailActionSuccess({
    required this.message,
    this.updatedStaff,
  });

  @override
  List<Object?> get props => [message, updatedStaff];
}

class MerchantStaffDetailError extends MerchantStaffDetailState {
  final String message;

  const MerchantStaffDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

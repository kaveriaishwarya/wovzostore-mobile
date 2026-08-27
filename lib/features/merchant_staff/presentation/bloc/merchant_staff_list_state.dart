import 'package:equatable/equatable.dart';
import '../../data/models/merchant_staff_model.dart';

abstract class MerchantStaffListState extends Equatable {
  const MerchantStaffListState();

  @override
  List<Object?> get props => [];
}

class MerchantStaffListInitial extends MerchantStaffListState {}

class MerchantStaffListLoading extends MerchantStaffListState {}

class MerchantStaffListLoaded extends MerchantStaffListState {
  final List<MerchantStaffModel> staff;
  final int pageNumber;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final String? searchQuery;
  final String? roleFilter;
  final bool? activeFilter;

  const MerchantStaffListLoaded({
    required this.staff,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    this.searchQuery,
    this.roleFilter,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [
        staff,
        pageNumber,
        totalPages,
        totalCount,
        hasNextPage,
        searchQuery,
        roleFilter,
        activeFilter,
      ];
}

class MerchantStaffListError extends MerchantStaffListState {
  final String message;

  const MerchantStaffListError(this.message);

  @override
  List<Object?> get props => [message];
}

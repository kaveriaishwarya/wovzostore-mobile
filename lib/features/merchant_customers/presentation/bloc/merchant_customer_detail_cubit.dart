import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/merchant_customer_repository.dart';
import 'merchant_customer_detail_state.dart';

class MerchantCustomerDetailCubit extends Cubit<MerchantCustomerDetailState> {
  final MerchantCustomerRepository _repository;

  MerchantCustomerDetailCubit({required MerchantCustomerRepository repository})
      : _repository = repository,
        super(const MerchantCustomerDetailState());

  Future<void> loadCustomerDetails(String customerId) async {
    emit(state.copyWith(status: MerchantCustomerDetailStatus.loading));
    try {
      final details = await _repository.getCustomerById(customerId);
      final orders = await _repository.getCustomerOrders(customerId);

      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.success,
        customer: details,
        orders: orders,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateCustomer({
    required String customerId,
    required String fullName,
    String? email,
    DateTime? dateOfBirth,
  }) async {
    emit(state.copyWith(status: MerchantCustomerDetailStatus.updating));
    try {
      await _repository.updateCustomer(
        customerId,
        fullName: fullName,
        email: email,
        dateOfBirth: dateOfBirth,
      );

      final updatedDetails = await _repository.getCustomerById(customerId);
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.success,
        customer: updatedDetails,
        actionSuccessMessage: 'Customer profile updated successfully',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleCustomerStatus(String customerId) async {
    if (state.customer == null) return;
    final isCurrentlyActive = state.customer!.status;

    emit(state.copyWith(status: MerchantCustomerDetailStatus.updating));
    try {
      if (isCurrentlyActive) {
        await _repository.deactivateCustomer(customerId);
      } else {
        await _repository.activateCustomer(customerId);
      }

      final updatedDetails = await _repository.getCustomerById(customerId);
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.success,
        customer: updatedDetails,
        actionSuccessMessage: isCurrentlyActive
            ? 'Customer deactivated successfully'
            : 'Customer activated successfully',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantCustomerDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

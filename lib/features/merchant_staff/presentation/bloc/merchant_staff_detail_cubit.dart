import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/create_staff_request_model.dart';
import '../../data/models/update_staff_request_model.dart';
import '../../domain/repositories/merchant_staff_repository.dart';
import 'merchant_staff_detail_state.dart';

class MerchantStaffDetailCubit extends Cubit<MerchantStaffDetailState> {
  final MerchantStaffRepository repository;

  MerchantStaffDetailCubit({required this.repository}) : super(MerchantStaffDetailInitial());

  Future<void> loadStaffDetail(String id) async {
    emit(MerchantStaffDetailLoading());
    try {
      final staff = await repository.getStaffById(id);
      emit(MerchantStaffDetailLoaded(staff));
    } catch (e) {
      emit(MerchantStaffDetailError(e.toString()));
    }
  }

  Future<void> createStaff(CreateStaffRequestModel request) async {
    emit(MerchantStaffDetailLoading());
    try {
      final created = await repository.createStaff(request);
      emit(MerchantStaffDetailActionSuccess(
        message: 'Staff member created successfully.',
        updatedStaff: created,
      ));
    } catch (e) {
      emit(MerchantStaffDetailError(e.toString()));
    }
  }

  Future<void> updateStaff(String id, UpdateStaffRequestModel request) async {
    emit(MerchantStaffDetailLoading());
    try {
      final updated = await repository.updateStaff(id, request);
      emit(MerchantStaffDetailActionSuccess(
        message: 'Staff member updated successfully.',
        updatedStaff: updated,
      ));
    } catch (e) {
      emit(MerchantStaffDetailError(e.toString()));
    }
  }

  Future<void> activateStaff(String id) async {
    emit(MerchantStaffDetailLoading());
    try {
      await repository.activateStaff(id);
      final refreshed = await repository.getStaffById(id);
      emit(MerchantStaffDetailActionSuccess(
        message: 'Staff member activated successfully.',
        updatedStaff: refreshed,
      ));
    } catch (e) {
      emit(MerchantStaffDetailError(e.toString()));
    }
  }

  Future<void> deactivateStaff(String id) async {
    emit(MerchantStaffDetailLoading());
    try {
      await repository.deactivateStaff(id);
      final refreshed = await repository.getStaffById(id);
      emit(MerchantStaffDetailActionSuccess(
        message: 'Staff member deactivated successfully.',
        updatedStaff: refreshed,
      ));
    } catch (e) {
      emit(MerchantStaffDetailError(e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/customer_onboarding_repository.dart';
import 'customer_onboarding_state.dart';

class CustomerOnboardingCubit extends Cubit<CustomerOnboardingState> {
  final CustomerOnboardingRepository _repository;

  CustomerOnboardingCubit({
    required CustomerOnboardingRepository repository,
  })  : _repository = repository,
        super(const CustomerOnboardingState());

  Future<void> verifyAndOnboard(String storeId) async {
    // If we've already onboarded for this store in this session, skip
    if (state.status == CustomerOnboardingStatus.success && state.onboardedStoreId == storeId) {
      return;
    }

    emit(state.copyWith(status: CustomerOnboardingStatus.loading));

    try {
      await _repository.onboardCustomer();
      emit(state.copyWith(
        status: CustomerOnboardingStatus.success,
        onboardedStoreId: storeId,
        errorMessage: null,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CustomerOnboardingStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerOnboardingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() {
    emit(const CustomerOnboardingState());
  }
}

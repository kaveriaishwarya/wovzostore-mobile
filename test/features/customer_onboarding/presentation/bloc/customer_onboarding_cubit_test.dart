import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/customer_onboarding/domain/repositories/customer_onboarding_repository.dart';
import 'package:wovzo_mobile/features/customer_onboarding/presentation/bloc/customer_onboarding_cubit.dart';
import 'package:wovzo_mobile/features/customer_onboarding/presentation/bloc/customer_onboarding_state.dart';

class MockCustomerOnboardingRepository implements CustomerOnboardingRepository {
  bool shouldFail = false;
  int callCount = 0;

  @override
  Future<void> onboardCustomer() async {
    callCount++;
    if (shouldFail) {
      throw const ApiServerException(message: 'Failed to onboard', statusCode: 500);
    }
  }
}

void main() {
  group('CustomerOnboardingCubit', () {
    late MockCustomerOnboardingRepository repository;
    late CustomerOnboardingCubit cubit;

    setUp(() {
      repository = MockCustomerOnboardingRepository();
      cubit = CustomerOnboardingCubit(repository: repository);
    });

    test('initial state is correct', () {
      expect(cubit.state.status, CustomerOnboardingStatus.initial);
      expect(cubit.state.onboardedStoreId, isNull);
    });

    test('verifyAndOnboard emits loading then success', () async {
      final storeId = 'store-1';
      
      final states = <CustomerOnboardingState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.verifyAndOnboard(storeId);
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, CustomerOnboardingStatus.loading);
      expect(states[1].status, CustomerOnboardingStatus.success);
      expect(states[1].onboardedStoreId, storeId);
      expect(repository.callCount, 1);
      subscription.cancel();
    });

    test('verifyAndOnboard handles backend failure', () async {
      repository.shouldFail = true;
      final storeId = 'store-1';
      
      final states = <CustomerOnboardingState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.verifyAndOnboard(storeId);
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, CustomerOnboardingStatus.loading);
      expect(states[1].status, CustomerOnboardingStatus.error);
      expect(states[1].errorMessage, 'Failed to onboard');
      expect(repository.callCount, 1);
      subscription.cancel();
    });

    test('verifyAndOnboard is idempotent for same storeId', () async {
      final storeId = 'store-1';
      
      await cubit.verifyAndOnboard(storeId);
      expect(repository.callCount, 1);

      // Call again with same store ID
      await cubit.verifyAndOnboard(storeId);
      // Should not call repository again
      expect(repository.callCount, 1);
    });

    test('verifyAndOnboard triggers again for new storeId', () async {
      await cubit.verifyAndOnboard('store-1');
      expect(repository.callCount, 1);

      await cubit.verifyAndOnboard('store-2');
      expect(repository.callCount, 2);
      expect(cubit.state.onboardedStoreId, 'store-2');
    });

    test('reset clears state', () async {
      await cubit.verifyAndOnboard('store-1');
      cubit.reset();
      expect(cubit.state.status, CustomerOnboardingStatus.initial);
      expect(cubit.state.onboardedStoreId, isNull);
    });
  });
}

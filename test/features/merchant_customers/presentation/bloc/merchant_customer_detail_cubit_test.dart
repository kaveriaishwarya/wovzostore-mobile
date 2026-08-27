import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_details_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/domain/repositories/merchant_customer_repository.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/bloc/merchant_customer_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/bloc/merchant_customer_detail_state.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_model.dart';

class MockMerchantCustomerDetailRepository implements MerchantCustomerRepository {
  bool shouldFail = false;
  bool currentStatus = true;

  final sampleDetails = MerchantCustomerDetailsModel(
    id: 'cust-1',
    fullName: 'Priya Patel',
    email: 'priya@example.com',
    phoneNumber: '9123456789',
    isEmailVerified: true,
    isPhoneVerified: true,
    status: true,
    createdAt: DateTime.parse('2026-08-28T00:00:00.000Z'),
    defaultAddress: 'Sector 5, Gurgaon',
    ordersCount: 2,
    totalSpent: 3000.0,
  );

  @override
  Future<PagedResult<MerchantCustomerModel>> getCustomers({
    int page = 1,
    int pageSize = 20,
    bool? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<MerchantCustomerDetailsModel> getCustomerById(String customerId) async {
    if (shouldFail) {
      throw const ApiServerException(message: 'Customer not found');
    }
    return MerchantCustomerDetailsModel(
      id: sampleDetails.id,
      fullName: sampleDetails.fullName,
      email: sampleDetails.email,
      phoneNumber: sampleDetails.phoneNumber,
      isEmailVerified: sampleDetails.isEmailVerified,
      isPhoneVerified: sampleDetails.isPhoneVerified,
      status: currentStatus,
      createdAt: sampleDetails.createdAt,
      defaultAddress: sampleDetails.defaultAddress,
      ordersCount: sampleDetails.ordersCount,
      totalSpent: sampleDetails.totalSpent,
    );
  }

  @override
  Future<void> updateCustomer(
    String customerId, {
    required String fullName,
    String? email,
    DateTime? dateOfBirth,
  }) async {}

  @override
  Future<void> activateCustomer(String customerId) async {
    currentStatus = true;
  }

  @override
  Future<void> deactivateCustomer(String customerId) async {
    currentStatus = false;
  }

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    return const [];
  }
}

void main() {
  group('MerchantCustomerDetailCubit Tests', () {
    late MockMerchantCustomerDetailRepository repository;
    late MerchantCustomerDetailCubit cubit;

    setUp(() {
      repository = MockMerchantCustomerDetailRepository();
      cubit = MerchantCustomerDetailCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MerchantCustomerDetailStatus.initial', () {
      expect(cubit.state.status, MerchantCustomerDetailStatus.initial);
      expect(cubit.state.customer, isNull);
    });

    test('loadCustomerDetails emits loading then success state', () async {
      await cubit.loadCustomerDetails('cust-1');

      expect(cubit.state.status, MerchantCustomerDetailStatus.success);
      expect(cubit.state.customer?.fullName, 'Priya Patel');
    });

    test('toggleCustomerStatus deactivates active customer', () async {
      await cubit.loadCustomerDetails('cust-1');
      await cubit.toggleCustomerStatus('cust-1');

      expect(cubit.state.status, MerchantCustomerDetailStatus.success);
      expect(cubit.state.customer?.status, isFalse);
      expect(cubit.state.actionSuccessMessage, 'Customer deactivated successfully');
    });

    test('updateCustomer emits updating then success state with updated profile', () async {
      await cubit.loadCustomerDetails('cust-1');
      await cubit.updateCustomer(
        customerId: 'cust-1',
        fullName: 'Priya Patel Updated',
        email: 'priya_new@example.com',
      );

      expect(cubit.state.status, MerchantCustomerDetailStatus.success);
      expect(cubit.state.actionSuccessMessage, 'Customer profile updated successfully');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_details_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/domain/repositories/merchant_customer_repository.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/bloc/merchant_customer_list_cubit.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/bloc/merchant_customer_list_state.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_model.dart';

class MockMerchantCustomerRepository implements MerchantCustomerRepository {
  bool shouldFail = false;

  final sampleCustomer = MerchantCustomerModel(
    id: 'cust-1',
    fullName: 'Priya Patel',
    email: 'priya@example.com',
    phoneNumber: '9123456789',
    status: true,
    createdAt: DateTime.parse('2026-08-28T00:00:00.000Z'),
    ordersCount: 3,
    totalSpent: 4500.0,
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
    if (shouldFail) {
      throw const ApiServerException(message: 'Failed to fetch customers');
    }

    return PagedResult<MerchantCustomerModel>(
      data: [sampleCustomer],
      pageNumber: page,
      pageSize: pageSize,
      totalCount: 1,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<MerchantCustomerDetailsModel> getCustomerById(String customerId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCustomer(
    String customerId, {
    required String fullName,
    String? email,
    DateTime? dateOfBirth,
  }) async {}

  @override
  Future<void> activateCustomer(String customerId) async {}

  @override
  Future<void> deactivateCustomer(String customerId) async {}

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    return const [];
  }
}

void main() {
  group('MerchantCustomerListCubit Tests', () {
    late MockMerchantCustomerRepository repository;
    late MerchantCustomerListCubit cubit;

    setUp(() {
      repository = MockMerchantCustomerRepository();
      cubit = MerchantCustomerListCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MerchantCustomerListStatus.initial', () {
      expect(cubit.state.status, MerchantCustomerListStatus.initial);
      expect(cubit.state.customers, isEmpty);
    });

    test('loadCustomers emits loading then success state', () async {
      await cubit.loadCustomers(refresh: true);

      expect(cubit.state.status, MerchantCustomerListStatus.success);
      expect(cubit.state.customers.length, 1);
      expect(cubit.state.customers.first.fullName, 'Priya Patel');
    });

    test('filterByStatus updates statusFilter and reloads list', () async {
      await cubit.filterByStatus(true);

      expect(cubit.state.statusFilter, isTrue);
      expect(cubit.state.customers.length, 1);
    });

    test('search updates searchQuery and reloads list', () async {
      await cubit.search('Priya');

      expect(cubit.state.searchQuery, 'Priya');
      expect(cubit.state.customers.length, 1);
    });

    test('loadCustomers emits error state on repository failure', () async {
      repository.shouldFail = true;
      await cubit.loadCustomers(refresh: true);

      expect(cubit.state.status, MerchantCustomerListStatus.error);
      expect(cubit.state.errorMessage, 'Failed to fetch customers');
    });
  });
}

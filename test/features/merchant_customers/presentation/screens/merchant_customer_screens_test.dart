import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_details_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/data/models/merchant_customer_model.dart';
import 'package:wovzo_mobile/features/merchant_customers/domain/repositories/merchant_customer_repository.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/bloc/merchant_customer_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/bloc/merchant_customer_list_cubit.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/screens/merchant_customer_detail_screen.dart';
import 'package:wovzo_mobile/features/merchant_customers/presentation/screens/merchant_customer_list_screen.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_model.dart';

class MockUIMerchantCustomerRepository implements MerchantCustomerRepository {
  final sampleCustomer = MerchantCustomerModel(
    id: 'cust-101',
    fullName: 'Ananya Roy',
    email: 'ananya@example.com',
    phoneNumber: '9988776655',
    status: true,
    createdAt: DateTime.parse('2026-08-28T00:00:00.000Z'),
    ordersCount: 4,
    totalSpent: 8900.0,
  );

  final sampleDetails = MerchantCustomerDetailsModel(
    id: 'cust-101',
    fullName: 'Ananya Roy',
    email: 'ananya@example.com',
    phoneNumber: '9988776655',
    isEmailVerified: true,
    isPhoneVerified: true,
    status: true,
    createdAt: DateTime.parse('2026-08-28T00:00:00.000Z'),
    defaultAddress: 'MG Road, Indiranagar, Bangalore',
    ordersCount: 4,
    totalSpent: 8900.0,
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
    return sampleDetails;
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
  final sl = GetIt.instance;
  late MockUIMerchantCustomerRepository repository;
  late MerchantCustomerListCubit listCubit;
  late MerchantCustomerDetailCubit detailCubit;

  setUp(() {
    sl.reset();
    repository = MockUIMerchantCustomerRepository();
    listCubit = MerchantCustomerListCubit(repository: repository);
    detailCubit = MerchantCustomerDetailCubit(repository: repository);

    sl.registerLazySingleton<MerchantCustomerRepository>(() => repository);
    sl.registerFactory<MerchantCustomerListCubit>(() => listCubit);
    sl.registerFactory<MerchantCustomerDetailCubit>(() => detailCubit);
  });

  tearDown(() {
    sl.reset();
  });

  group('Merchant Customer UI Screen Tests', () {
    testWidgets('MerchantCustomerListScreen renders title, search bar, status chips, and customer cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantCustomerListScreen(cubit: listCubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer Directory'), findsOneWidget);
      expect(find.text('Search by name, email or phone...'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
      expect(find.text('Ananya Roy'), findsOneWidget);
      expect(find.text('Phone: 9988776655'), findsOneWidget);
    });

    testWidgets('MerchantCustomerDetailScreen renders profile info, badges, and action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantCustomerDetailScreen(customerId: 'cust-101', cubit: detailCubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.text('Ananya Roy'), findsOneWidget);
      expect(find.text('Phone: 9988776655'), findsOneWidget);
      expect(find.text('Phone Verified'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });

    testWidgets('Tapping Edit Profile opens edit modal dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantCustomerDetailScreen(customerId: 'cust-101', cubit: detailCubit),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Customer Profile'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Tapping Deactivate opens confirmation dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantCustomerDetailScreen(customerId: 'cust-101', cubit: detailCubit),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deactivate'));
      await tester.pumpAndSettle();

      expect(find.text('Deactivate Customer?'), findsOneWidget);
    });
  });
}

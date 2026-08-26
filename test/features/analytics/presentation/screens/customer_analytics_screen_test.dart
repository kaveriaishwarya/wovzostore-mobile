import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/customer_analytics_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/customer_analytics_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/screens/customer_analytics_screen.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
  });

  Widget createWidgetUnderTest(CustomerAnalyticsCubit cubit) {
    return MaterialApp(
      home: BlocProvider<CustomerAnalyticsCubit>.value(
        value: cubit,
        child: const CustomerAnalyticsScreen(),
      ),
    );
  }

  group('CustomerAnalyticsScreen Widget Tests', () {
    testWidgets('renders title, date filter, summary KPIs, and top customers', (tester) async {
      mockRepository.customerAnalyticsResult = const CustomerAnalyticsReportModel(
        summary: CustomerAnalyticsSummaryModel(
          totalCustomers: 250,
          newCustomers: 100,
          returningCustomers: 150,
          repeatPurchaseRate: 60.0,
          revenueFromNewCustomers: 120000,
          revenueFromReturningCustomers: 380000,
        ),
        topCustomers: PagedResult(
          data: [
            CustomerPerformanceModel(
              customerId: 'c-1',
              displayName: 'Rahul Sharma',
              orderCount: 8,
              revenue: 32000,
            ),
          ],
          pageNumber: 1,
          pageSize: 20,
          totalCount: 1,
          totalPages: 1,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );

      final cubit = CustomerAnalyticsCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Customer Analytics'), findsOneWidget);
      expect(find.text('Total Customers'), findsOneWidget);
      expect(find.text('New Customers'), findsOneWidget);
      expect(find.text('Returning Customers'), findsOneWidget);
      expect(find.text('Repeat Rate'), findsOneWidget);
      expect(find.text('Top Customers'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);

      // Privacy check: sensitive fields should not be present
      expect(find.textContaining('@'), findsNothing);
      expect(find.textContaining('password'), findsNothing);
      expect(find.textContaining('phone'), findsNothing);
    });

    testWidgets('displays error state with retry button on failure', (tester) async {
      mockRepository.shouldThrowError = true;

      final cubit = CustomerAnalyticsCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Failed to load customer analytics'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}

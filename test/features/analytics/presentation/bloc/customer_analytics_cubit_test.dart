import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/customer_analytics_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/analytics_status.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/customer_analytics_cubit.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;
  late CustomerAnalyticsCubit cubit;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    cubit = CustomerAnalyticsCubit(
      repository: mockRepository,
      startDate: '2026-01-01',
      endDate: '2026-01-31',
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('CustomerAnalyticsCubit Tests', () {
    test('successful load updates state with customer report', () async {
      mockRepository.customerAnalyticsResult = const CustomerAnalyticsReportModel(
        summary: CustomerAnalyticsSummaryModel(
          totalCustomers: 100,
          newCustomers: 40,
          returningCustomers: 60,
          repeatPurchaseRate: 60.0,
          revenueFromNewCustomers: 50000,
          revenueFromReturningCustomers: 150000,
        ),
        topCustomers: PagedResult(
          data: [
            CustomerPerformanceModel(
              customerId: 'c1',
              displayName: 'John Doe',
              orderCount: 5,
              revenue: 12000,
            )
          ],
          pageNumber: 1,
          pageSize: 20,
          totalCount: 1,
          totalPages: 1,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );

      await cubit.loadReport();

      expect(cubit.state.status, AnalyticsStatus.success);
      expect(cubit.state.report?.summary.totalCustomers, 100);
      expect(cubit.state.report?.topCustomers.data.length, 1);
    });

    test('changePage and changeSorting update state appropriately', () {
      cubit.changePage(2);
      expect(cubit.state.page, 2);

      cubit.changeSorting('ordercount', 'asc');
      expect(cubit.state.sortBy, 'ordercount');
      expect(cubit.state.sortDirection, 'asc');
      expect(cubit.state.page, 1);
    });

    test('updateDateRange resets page to 1', () {
      cubit.changePage(3);
      expect(cubit.state.page, 3);

      cubit.updateDateRange(startDate: '2026-02-01', endDate: '2026-02-28');
      expect(cubit.state.startDate, '2026-02-01');
      expect(cubit.state.endDate, '2026-02-28');
      expect(cubit.state.page, 1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/product_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/analytics_status.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/product_performance_cubit.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;
  late ProductPerformanceCubit cubit;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    cubit = ProductPerformanceCubit(
      repository: mockRepository,
      startDate: '2026-01-01',
      endDate: '2026-01-31',
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ProductPerformanceCubit Tests', () {
    test('successful load updates state with paged data', () async {
      mockRepository.productPerformanceResult = const PagedResult(
        data: [
          ProductPerformanceModel(
            productId: 'p1',
            productName: 'Jacket',
            unitsSold: 10,
            revenue: 15000,
            averageSellingPrice: 1500,
          )
        ],
        pageNumber: 1,
        pageSize: 20,
        totalCount: 1,
        totalPages: 1,
        hasPreviousPage: false,
        hasNextPage: false,
      );

      await cubit.loadReport();

      expect(cubit.state.status, AnalyticsStatus.success);
      expect(cubit.state.pagedData?.data.length, 1);
      expect(cubit.state.pagedData?.data.first.productName, 'Jacket');
    });

    test('changePage updates page parameter and loads report', () async {
      cubit.changePage(2);
      expect(cubit.state.page, 2);
    });

    test('changeSorting updates sorting and resets page to 1', () async {
      cubit.changePage(3);
      expect(cubit.state.page, 3);

      cubit.changeSorting('unitssold', 'asc');
      expect(cubit.state.sortBy, 'unitssold');
      expect(cubit.state.sortDirection, 'asc');
      expect(cubit.state.page, 1);
    });

    test('updateFilters updates filters and resets page to 1', () async {
      cubit.changePage(4);
      expect(cubit.state.page, 4);

      cubit.updateFilters(categoryId: 'cat-123', brandId: 'brand-456');
      expect(cubit.state.categoryId, 'cat-123');
      expect(cubit.state.brandId, 'brand-456');
      expect(cubit.state.page, 1);
    });

    test('loadReport emits error on failure', () async {
      mockRepository.shouldThrowError = true;
      await cubit.loadReport();
      expect(cubit.state.status, AnalyticsStatus.error);
    });
  });
}

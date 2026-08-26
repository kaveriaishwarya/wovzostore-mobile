import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/brand_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/category_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/analytics_status.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/category_brand_cubit.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;
  late CategoryBrandCubit cubit;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    cubit = CategoryBrandCubit(
      repository: mockRepository,
      startDate: '2026-01-01',
      endDate: '2026-01-31',
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('CategoryBrandCubit Tests', () {
    test('successful load updates categories and brands', () async {
      mockRepository.categoryPerformanceResult = const [
        CategoryPerformanceModel(
          categoryId: 'cat-1',
          categoryName: 'Electronics',
          unitsSold: 50,
          revenue: 100000,
        ),
      ];

      mockRepository.brandPerformanceResult = const [
        BrandPerformanceModel(
          brandId: 'b-1',
          brandName: 'Sony',
          unitsSold: 30,
          revenue: 80000,
        ),
      ];

      await cubit.loadReport();

      expect(cubit.state.status, AnalyticsStatus.success);
      expect(cubit.state.categories.length, 1);
      expect(cubit.state.categories.first.categoryName, 'Electronics');
      expect(cubit.state.brands.length, 1);
      expect(cubit.state.brands.first.brandName, 'Sony');
    });

    test('failure emits error status', () async {
      mockRepository.shouldThrowError = true;
      await cubit.loadReport();
      expect(cubit.state.status, AnalyticsStatus.error);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/product_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/product_performance_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/screens/product_performance_screen.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
  });

  Widget createWidgetUnderTest(ProductPerformanceCubit cubit) {
    return MaterialApp(
      home: BlocProvider<ProductPerformanceCubit>.value(
        value: cubit,
        child: const ProductPerformanceScreen(),
      ),
    );
  }

  group('ProductPerformanceScreen Widget Tests', () {
    testWidgets('renders title, date filter, and sort options', (tester) async {
      final cubit = ProductPerformanceCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();

      expect(find.text('Product Performance'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Units Sold'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('renders product cards and pagination on successful load', (tester) async {
      mockRepository.productPerformanceResult = const PagedResult(
        data: [
          ProductPerformanceModel(
            productId: 'p1',
            productName: 'Classic Leather Jacket',
            variantId: 'v1',
            variantName: 'Size M - Black',
            unitsSold: 15,
            revenue: 45000,
            averageSellingPrice: 3000,
          ),
        ],
        pageNumber: 1,
        pageSize: 20,
        totalCount: 25,
        totalPages: 2,
        hasPreviousPage: false,
        hasNextPage: true,
      );

      final cubit = ProductPerformanceCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Classic Leather Jacket'), findsOneWidget);
      expect(find.text('Variant: Size M - Black'), findsOneWidget);
      expect(find.text('25 Products Sold'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);
    });

    testWidgets('renders empty state when zero products are returned', (tester) async {
      mockRepository.productPerformanceResult = const PagedResult(
        data: [],
        pageNumber: 1,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
      );

      final cubit = ProductPerformanceCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('No product performance data for this period'), findsOneWidget);
    });

    testWidgets('displays error state with retry button on failure', (tester) async {
      mockRepository.shouldThrowError = true;

      final cubit = ProductPerformanceCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Failed to load product performance'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}

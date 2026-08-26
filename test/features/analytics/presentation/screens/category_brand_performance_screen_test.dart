import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/brand_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/category_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/category_brand_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/screens/category_brand_performance_screen.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
  });

  Widget createWidgetUnderTest(CategoryBrandCubit cubit) {
    return MaterialApp(
      home: BlocProvider<CategoryBrandCubit>.value(
        value: cubit,
        child: const CategoryBrandPerformanceScreen(),
      ),
    );
  }

  group('CategoryBrandPerformanceScreen Widget Tests', () {
    testWidgets('renders title, date filter, and segmented tabs', (tester) async {
      final cubit = CategoryBrandCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();

      expect(find.text('Categories & Brands'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Brands'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('renders category and brand list cards and supports switching', (tester) async {
      mockRepository.categoryPerformanceResult = const [
        CategoryPerformanceModel(
          categoryId: 'c1',
          categoryName: 'Footwear',
          unitsSold: 50,
          revenue: 100000,
        ),
      ];

      mockRepository.brandPerformanceResult = const [
        BrandPerformanceModel(
          brandId: 'b1',
          brandName: 'Adidas',
          unitsSold: 30,
          revenue: 75000,
        ),
      ];

      final cubit = CategoryBrandCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Category tab active by default
      expect(find.text('Footwear'), findsOneWidget);

      // Switch to Brands tab
      await tester.tap(find.text('Brands'));
      await tester.pumpAndSettle();

      expect(find.text('Adidas'), findsOneWidget);
    });

    testWidgets('displays error state on failure with retry button', (tester) async {
      mockRepository.shouldThrowError = true;

      final cubit = CategoryBrandCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Failed to load category & brand performance'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}

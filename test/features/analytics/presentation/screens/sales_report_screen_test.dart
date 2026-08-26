import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/sales_report_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/sales_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/screens/sales_report_screen.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
  });

  Widget createWidgetUnderTest(SalesCubit cubit) {
    return MaterialApp(
      home: BlocProvider<SalesCubit>.value(
        value: cubit,
        child: const SalesReportScreen(),
      ),
    );
  }

  group('SalesReportScreen Widget Tests', () {
    testWidgets('renders title and date filters', (tester) async {
      final cubit = SalesCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();

      expect(find.text('Sales Report'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
    });

    testWidgets('renders KPI cards and secondary metrics on successful load', (tester) async {
      mockRepository.salesReportResult = const SalesReportModel(
        grossSales: 125000,
        netSales: 110000,
        orderCount: 45,
        averageOrderValue: 2777,
        discountAmount: 10000,
        taxAmount: 5000,
        shippingAmount: 2000,
        refundAmount: 1000,
        cancelledOrderCount: 2,
        trend: [
          SalesTrendModel(
            orderCount: 10,
            grossSales: 25000,
            netSales: 22000,
          ),
        ],
      );

      final cubit = SalesCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Gross Sales'), findsOneWidget);
      expect(find.text('Net Sales'), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('Average Order Value'), findsOneWidget);
      expect(find.text('Secondary Breakdown'), findsOneWidget);
      expect(find.text('Revenue Trend'), findsOneWidget);
      expect(find.text('Order Volume'), findsOneWidget);
    });

    testWidgets('displays error state with retry button on failure', (tester) async {
      mockRepository.shouldThrowError = true;

      final cubit = SalesCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Failed to load sales report'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}

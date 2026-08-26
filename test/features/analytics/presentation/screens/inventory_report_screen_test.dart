import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/inventory_report_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/inventory_report_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/screens/inventory_report_screen.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
  });

  Widget createWidgetUnderTest(InventoryReportCubit cubit) {
    return MaterialApp(
      home: BlocProvider<InventoryReportCubit>.value(
        value: cubit,
        child: const InventoryReportScreen(),
      ),
    );
  }

  group('InventoryReportScreen Widget Tests', () {
    testWidgets('renders title, KPI cards, filter chip, and inventory list', (tester) async {
      mockRepository.inventoryReportResult = const InventoryReportModel(
        totalInventoryValue: 750000,
        lowStockCount: 3,
        outOfStockCount: 1,
        totalUnits: 450,
        items: PagedResult(
          data: [
            InventoryItemReportModel(
              productId: 'p-1',
              productName: 'Slim Denim Shirt',
              currentStock: 4,
              reservedStock: 1,
              availableStock: 3,
              lowStockThreshold: 5,
              unitPrice: 1500,
              inventoryValue: 6000,
              unitsSoldInPeriod: 12,
              stockVelocity: 0.6,
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

      final cubit = InventoryReportCubit(repository: mockRepository);

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Inventory Report'), findsOneWidget);
      expect(find.text('Total Valuation'), findsOneWidget);
      expect(find.text('Total Units'), findsOneWidget);
      expect(find.text('Low Stock'), findsWidgets);
      expect(find.text('Out of Stock'), findsOneWidget);
      expect(find.text('Low Stock Only'), findsOneWidget);
      expect(find.text('Slim Denim Shirt'), findsOneWidget);
      expect(find.text('Low Stock'), findsWidgets); // Status badge
    });

    testWidgets('displays error state with retry button on failure', (tester) async {
      mockRepository.shouldThrowError = true;

      final cubit = InventoryReportCubit(repository: mockRepository);

      await tester.pumpWidget(createWidgetUnderTest(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Failed to load inventory report'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}

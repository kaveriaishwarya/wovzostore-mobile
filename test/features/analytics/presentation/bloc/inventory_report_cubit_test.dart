import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/inventory_report_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/analytics_status.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/inventory_report_cubit.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;
  late InventoryReportCubit cubit;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    cubit = InventoryReportCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('InventoryReportCubit Tests', () {
    test('successful load updates state with inventory report', () async {
      mockRepository.inventoryReportResult = const InventoryReportModel(
        totalInventoryValue: 250000,
        lowStockCount: 2,
        outOfStockCount: 1,
        totalUnits: 150,
        items: PagedResult(
          data: [],
          pageNumber: 1,
          pageSize: 20,
          totalCount: 0,
          totalPages: 0,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );

      await cubit.loadReport();

      expect(cubit.state.status, AnalyticsStatus.success);
      expect(cubit.state.report?.totalInventoryValue, 250000);
      expect(cubit.state.report?.lowStockCount, 2);
    });

    test('updateFilters toggles lowStockOnly and category and resets page', () {
      cubit.changePage(3);
      expect(cubit.state.page, 3);

      cubit.updateFilters(lowStockOnly: true, categoryId: 'cat-1');
      expect(cubit.state.lowStockOnly, true);
      expect(cubit.state.categoryId, 'cat-1');
      expect(cubit.state.page, 1);
    });

    test('failure emits error status', () async {
      mockRepository.shouldThrowError = true;
      await cubit.loadReport();
      expect(cubit.state.status, AnalyticsStatus.error);
    });
  });
}

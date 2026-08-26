import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/sales_report_model.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/analytics_status.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/sales_cubit.dart';
import '../mocks/mock_analytics_repository.dart';

void main() {
  late MockAnalyticsRepository mockRepository;
  late SalesCubit cubit;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    cubit = SalesCubit(
      repository: mockRepository,
      startDate: '2026-01-01',
      endDate: '2026-01-31',
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('SalesCubit Tests', () {
    test('initial state has correct default values', () {
      expect(cubit.state.status, AnalyticsStatus.initial);
      expect(cubit.state.startDate, '2026-01-01');
      expect(cubit.state.endDate, '2026-01-31');
      expect(cubit.state.report, isNull);
    });

    test('loadReport emits loading then success on repository success', () async {
      mockRepository.salesReportResult = const SalesReportModel(
        grossSales: 10000,
        netSales: 9000,
        orderCount: 5,
        averageOrderValue: 2000,
        discountAmount: 1000,
        taxAmount: 500,
        shippingAmount: 200,
        refundAmount: 0,
        cancelledOrderCount: 0,
        trend: [],
      );

      final expectedStatuses = [
        AnalyticsStatus.loading,
        AnalyticsStatus.success,
      ];

      final actualStatuses = <AnalyticsStatus>[];
      final subscription = cubit.stream.listen((state) {
        actualStatuses.add(state.status);
      });

      await cubit.loadReport();
      await Future.delayed(const Duration(milliseconds: 10));

      expect(actualStatuses, expectedStatuses);
      expect(cubit.state.report?.grossSales, 10000);
      await subscription.cancel();
    });

    test('loadReport emits error on repository failure', () async {
      mockRepository.shouldThrowError = true;

      await cubit.loadReport();

      expect(cubit.state.status, AnalyticsStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('updateDateRange updates state and triggers reload', () async {
      cubit.updateDateRange(startDate: '2026-02-01', endDate: '2026-02-28');

      expect(cubit.state.startDate, '2026-02-01');
      expect(cubit.state.endDate, '2026-02-28');
    });
  });
}

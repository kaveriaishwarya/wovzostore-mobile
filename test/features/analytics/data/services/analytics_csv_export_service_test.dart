import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/services/analytics_csv_export_service.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/sales_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/product_performance_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/category_brand_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/customer_analytics_cubit.dart';
import 'package:wovzo_mobile/features/analytics/presentation/bloc/inventory_report_cubit.dart';
import '../../presentation/mocks/mock_analytics_repository.dart';

class _MockCsvExportService implements AnalyticsCsvExportService {
  bool saveCsvCalled = false;
  bool shareCsvCalled = false;
  String? savedFileName;
  Uint8List? savedBytes;

  @override
  Future<String> saveCsvFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    saveCsvCalled = true;
    savedFileName = fileName;
    savedBytes = bytes;
    return '/tmp/$fileName';
  }

  @override
  Future<void> shareCsvFile({
    required String filePath,
    required String title,
  }) async {
    shareCsvCalled = true;
  }

  @override
  String formatCleanDate(String dateYmd) => dateYmd.replaceAll('-', '');

  @override
  String generateSalesFileName(String start, String end) =>
      'sales_report_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';

  @override
  String generateProductFileName(String start, String end) =>
      'product_performance_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';

  @override
  String generateCategoryFileName(String start, String end) =>
      'category_performance_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';

  @override
  String generateBrandFileName(String start, String end) =>
      'brand_performance_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';

  @override
  String generateCustomerFileName(String start, String end) =>
      'customer_analytics_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';

  @override
  String generateInventoryFileName() => 'inventory_report_20260101.csv';
}

void main() {
  group('AnalyticsCsvExportService Filename Generation Tests', () {
    final service = AnalyticsCsvExportServiceImpl();

    test('generates expected deterministic filenames for all reports', () {
      expect(
        service.generateSalesFileName('2026-01-01', '2026-01-31'),
        'sales_report_20260101_20260131.csv',
      );
      expect(
        service.generateProductFileName('2026-01-01', '2026-01-31'),
        'product_performance_20260101_20260131.csv',
      );
      expect(
        service.generateCategoryFileName('2026-01-01', '2026-01-31'),
        'category_performance_20260101_20260131.csv',
      );
      expect(
        service.generateBrandFileName('2026-01-01', '2026-01-31'),
        'brand_performance_20260101_20260131.csv',
      );
      expect(
        service.generateCustomerFileName('2026-01-01', '2026-01-31'),
        'customer_analytics_20260101_20260131.csv',
      );
      expect(
        service.generateInventoryFileName().startsWith('inventory_report_'),
        true,
      );
      expect(
        service.generateInventoryFileName().endsWith('.csv'),
        true,
      );
    });
  });

  group('Cubit CSV Export Integration Tests', () {
    late MockAnalyticsRepository mockRepository;
    late _MockCsvExportService mockExportService;

    setUp(() {
      mockRepository = MockAnalyticsRepository();
      mockExportService = _MockCsvExportService();
    });

    test('SalesCubit.exportReport saves and shares file', () async {
      final cubit = SalesCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await cubit.exportReport(mockExportService);

      expect(mockExportService.saveCsvCalled, true);
      expect(mockExportService.shareCsvCalled, true);
      expect(mockExportService.savedFileName, 'sales_report_20260101_20260131.csv');
      expect(cubit.state.isExporting, false);
    });

    test('ProductPerformanceCubit.exportReport saves and shares file', () async {
      final cubit = ProductPerformanceCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await cubit.exportReport(mockExportService);

      expect(mockExportService.saveCsvCalled, true);
      expect(mockExportService.shareCsvCalled, true);
      expect(mockExportService.savedFileName, 'product_performance_20260101_20260131.csv');
      expect(cubit.state.isExporting, false);
    });

    test('CategoryBrandCubit exports both category and brand files', () async {
      final cubit = CategoryBrandCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await cubit.exportCategoryReport(mockExportService);
      expect(mockExportService.savedFileName, 'category_performance_20260101_20260131.csv');

      await cubit.exportBrandReport(mockExportService);
      expect(mockExportService.savedFileName, 'brand_performance_20260101_20260131.csv');
      expect(cubit.state.isExporting, false);
    });

    test('CustomerAnalyticsCubit.exportReport saves and shares file', () async {
      final cubit = CustomerAnalyticsCubit(
        repository: mockRepository,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      await cubit.exportReport(mockExportService);

      expect(mockExportService.saveCsvCalled, true);
      expect(mockExportService.shareCsvCalled, true);
      expect(mockExportService.savedFileName, 'customer_analytics_20260101_20260131.csv');
      expect(cubit.state.isExporting, false);
    });

    test('InventoryReportCubit.exportReport saves and shares file', () async {
      final cubit = InventoryReportCubit(repository: mockRepository);

      await cubit.exportReport(mockExportService);

      expect(mockExportService.saveCsvCalled, true);
      expect(mockExportService.shareCsvCalled, true);
      expect(mockExportService.savedFileName, 'inventory_report_20260101.csv');
      expect(cubit.state.isExporting, false);
    });
  });
}

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:wovzo_mobile/features/analytics/data/models/brand_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/category_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/customer_analytics_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/inventory_report_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/product_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/sales_report_model.dart';
import 'package:wovzo_mobile/features/analytics/data/repositories/analytics_repository_impl.dart';

class _MockAnalyticsRemoteDataSource implements AnalyticsRemoteDataSource {
  bool getSalesReportCalled = false;
  bool getProductPerformanceCalled = false;
  bool getCategoryPerformanceCalled = false;
  bool getBrandPerformanceCalled = false;
  bool getCustomerAnalyticsCalled = false;
  bool getInventoryReportCalled = false;
  bool exportSalesCalled = false;
  bool exportProductCalled = false;
  bool exportCategoryCalled = false;
  bool exportBrandCalled = false;
  bool exportCustomerCalled = false;
  bool exportInventoryCalled = false;

  @override
  Future<SalesReportModel> getSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  }) async {
    getSalesReportCalled = true;
    return const SalesReportModel(
      grossSales: 0,
      netSales: 0,
      orderCount: 0,
      averageOrderValue: 0,
      discountAmount: 0,
      taxAmount: 0,
      shippingAmount: 0,
      refundAmount: 0,
      cancelledOrderCount: 0,
      trend: [],
    );
  }

  @override
  Future<PagedResult<ProductPerformanceModel>> getProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    getProductPerformanceCalled = true;
    return const PagedResult(
      data: [],
      pageNumber: 1,
      pageSize: 20,
      totalCount: 0,
      totalPages: 0,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<List<CategoryPerformanceModel>> getCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    getCategoryPerformanceCalled = true;
    return [];
  }

  @override
  Future<List<BrandPerformanceModel>> getBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    getBrandPerformanceCalled = true;
    return [];
  }

  @override
  Future<CustomerAnalyticsReportModel> getCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    getCustomerAnalyticsCalled = true;
    return const CustomerAnalyticsReportModel(
      summary: CustomerAnalyticsSummaryModel(
        totalCustomers: 0,
        newCustomers: 0,
        returningCustomers: 0,
        repeatPurchaseRate: 0,
        revenueFromNewCustomers: 0,
        revenueFromReturningCustomers: 0,
      ),
      topCustomers: PagedResult(
        data: [],
        pageNumber: 1,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0,
        hasPreviousPage: false,
        hasNextPage: false,
      ),
    );
  }

  @override
  Future<InventoryReportModel> getInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    getInventoryReportCalled = true;
    return const InventoryReportModel(
      totalInventoryValue: 0,
      lowStockCount: 0,
      outOfStockCount: 0,
      totalUnits: 0,
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
  }

  @override
  Future<Uint8List> exportSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  }) async {
    exportSalesCalled = true;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<Uint8List> exportProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    String? sortBy,
    String? sortDirection,
  }) async {
    exportProductCalled = true;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<Uint8List> exportCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    exportCategoryCalled = true;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<Uint8List> exportBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    exportBrandCalled = true;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<Uint8List> exportCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    String? sortBy,
    String? sortDirection,
  }) async {
    exportCustomerCalled = true;
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<Uint8List> exportInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    String? sortBy,
    String? sortDirection,
  }) async {
    exportInventoryCalled = true;
    return Uint8List.fromList([1, 2, 3]);
  }
}

void main() {
  late _MockAnalyticsRemoteDataSource mockDataSource;
  late AnalyticsRepositoryImpl repository;

  setUp(() {
    mockDataSource = _MockAnalyticsRemoteDataSource();
    repository = AnalyticsRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('AnalyticsRepository Delegation Tests', () {
    test('getSalesReport delegates to remote data source', () async {
      await repository.getSalesReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.getSalesReportCalled, true);
    });

    test('getProductPerformanceReport delegates to remote data source', () async {
      await repository.getProductPerformanceReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.getProductPerformanceCalled, true);
    });

    test('getCategoryPerformanceReport delegates to remote data source', () async {
      await repository.getCategoryPerformanceReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.getCategoryPerformanceCalled, true);
    });

    test('getBrandPerformanceReport delegates to remote data source', () async {
      await repository.getBrandPerformanceReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.getBrandPerformanceCalled, true);
    });

    test('getCustomerAnalyticsReport delegates to remote data source', () async {
      await repository.getCustomerAnalyticsReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.getCustomerAnalyticsCalled, true);
    });

    test('getInventoryReport delegates to remote data source', () async {
      await repository.getInventoryReport();
      expect(mockDataSource.getInventoryReportCalled, true);
    });

    test('export methods delegate to remote data source', () async {
      await repository.exportSalesReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.exportSalesCalled, true);

      await repository.exportProductPerformanceReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.exportProductCalled, true);

      await repository.exportCategoryPerformanceReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.exportCategoryCalled, true);

      await repository.exportBrandPerformanceReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.exportBrandCalled, true);

      await repository.exportCustomerAnalyticsReport(startDate: '2026-01-01', endDate: '2026-01-31');
      expect(mockDataSource.exportCustomerCalled, true);

      await repository.exportInventoryReport();
      expect(mockDataSource.exportInventoryCalled, true);
    });
  });
}

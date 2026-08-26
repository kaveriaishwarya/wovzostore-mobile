import 'dart:typed_data';
import 'package:wovzo_mobile/features/analytics/data/models/brand_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/category_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/customer_analytics_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/dashboard_summary_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/inventory_report_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/product_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/sales_report_model.dart';
import 'package:wovzo_mobile/features/analytics/domain/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  bool shouldThrowError = false;

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    if (shouldThrowError) throw Exception('Failed to load dashboard');
    return const DashboardSummaryModel();
  }

  SalesReportModel? salesReportResult;
  PagedResult<ProductPerformanceModel>? productPerformanceResult;
  List<CategoryPerformanceModel>? categoryPerformanceResult;
  List<BrandPerformanceModel>? brandPerformanceResult;
  CustomerAnalyticsReportModel? customerAnalyticsResult;
  InventoryReportModel? inventoryReportResult;

  @override
  Future<SalesReportModel> getSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  }) async {
    if (shouldThrowError) throw Exception('Failed to load sales report');
    return salesReportResult ??
        const SalesReportModel(
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
    if (shouldThrowError) throw Exception('Failed to load product performance');
    return productPerformanceResult ??
        const PagedResult(
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
    if (shouldThrowError) throw Exception('Failed to load category performance');
    return categoryPerformanceResult ?? [];
  }

  @override
  Future<List<BrandPerformanceModel>> getBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    if (shouldThrowError) throw Exception('Failed to load brand performance');
    return brandPerformanceResult ?? [];
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
    if (shouldThrowError) throw Exception('Failed to load customer analytics');
    return customerAnalyticsResult ??
        const CustomerAnalyticsReportModel(
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
    if (shouldThrowError) throw Exception('Failed to load inventory report');
    return inventoryReportResult ??
        const InventoryReportModel(
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
    return Uint8List.fromList([1]);
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
    return Uint8List.fromList([1]);
  }

  @override
  Future<Uint8List> exportCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    return Uint8List.fromList([1]);
  }

  @override
  Future<Uint8List> exportBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    return Uint8List.fromList([1]);
  }

  @override
  Future<Uint8List> exportCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    String? sortBy,
    String? sortDirection,
  }) async {
    return Uint8List.fromList([1]);
  }

  @override
  Future<Uint8List> exportInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    String? sortBy,
    String? sortDirection,
  }) async {
    return Uint8List.fromList([1]);
  }
}

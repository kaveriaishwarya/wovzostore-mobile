import 'dart:typed_data';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../models/sales_report_model.dart';
import '../models/product_performance_model.dart';
import '../models/category_performance_model.dart';
import '../models/brand_performance_model.dart';
import '../models/customer_analytics_model.dart';
import '../models/inventory_report_model.dart';
import '../models/paged_result_model.dart';
import '../models/dashboard_summary_model.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardSummaryModel> getDashboardSummary() {
    return remoteDataSource.getDashboardSummary();
  }

  @override
  Future<SalesReportModel> getSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  }) {
    return remoteDataSource.getSalesReport(
      startDate: startDate,
      endDate: endDate,
      interval: interval,
      status: status,
      paymentMethod: paymentMethod,
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
  }) {
    return remoteDataSource.getProductPerformanceReport(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      brandId: brandId,
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  @override
  Future<List<CategoryPerformanceModel>> getCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  }) {
    return remoteDataSource.getCategoryPerformanceReport(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<BrandPerformanceModel>> getBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) {
    return remoteDataSource.getBrandPerformanceReport(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<CustomerAnalyticsReportModel> getCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) {
    return remoteDataSource.getCustomerAnalyticsReport(
      startDate: startDate,
      endDate: endDate,
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
      sortDirection: sortDirection,
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
  }) {
    return remoteDataSource.getInventoryReport(
      lowStockOnly: lowStockOnly,
      categoryId: categoryId,
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  @override
  Future<Uint8List> exportSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  }) {
    return remoteDataSource.exportSalesReport(
      startDate: startDate,
      endDate: endDate,
      interval: interval,
      status: status,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<Uint8List> exportProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    String? sortBy,
    String? sortDirection,
  }) {
    return remoteDataSource.exportProductPerformanceReport(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      brandId: brandId,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  @override
  Future<Uint8List> exportCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  }) {
    return remoteDataSource.exportCategoryPerformanceReport(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Uint8List> exportBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) {
    return remoteDataSource.exportBrandPerformanceReport(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Uint8List> exportCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    String? sortBy,
    String? sortDirection,
  }) {
    return remoteDataSource.exportCustomerAnalyticsReport(
      startDate: startDate,
      endDate: endDate,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  @override
  Future<Uint8List> exportInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    String? sortBy,
    String? sortDirection,
  }) {
    return remoteDataSource.exportInventoryReport(
      lowStockOnly: lowStockOnly,
      categoryId: categoryId,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }
}

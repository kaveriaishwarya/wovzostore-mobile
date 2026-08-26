import 'dart:typed_data';
import '../../data/models/sales_report_model.dart';
import '../../data/models/product_performance_model.dart';
import '../../data/models/category_performance_model.dart';
import '../../data/models/brand_performance_model.dart';
import '../../data/models/customer_analytics_model.dart';
import '../../data/models/inventory_report_model.dart';
import '../../data/models/paged_result_model.dart';
import '../../data/models/dashboard_summary_model.dart';

abstract class AnalyticsRepository {
  Future<DashboardSummaryModel> getDashboardSummary();

  Future<SalesReportModel> getSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  });

  Future<PagedResult<ProductPerformanceModel>> getProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  });

  Future<List<CategoryPerformanceModel>> getCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<List<BrandPerformanceModel>> getBrandPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<CustomerAnalyticsReportModel> getCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  });

  Future<InventoryReportModel> getInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  });

  Future<Uint8List> exportSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  });

  Future<Uint8List> exportProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    String? sortBy,
    String? sortDirection,
  });

  Future<Uint8List> exportCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<Uint8List> exportBrandPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<Uint8List> exportCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    String? sortBy,
    String? sortDirection,
  });

  Future<Uint8List> exportInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    String? sortBy,
    String? sortDirection,
  });
}

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/analytics/data/models/brand_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/category_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/customer_analytics_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/dashboard_summary_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/inventory_report_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/product_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/sales_report_model.dart';
import 'package:wovzo_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:wovzo_mobile/features/business_dashboard/presentation/bloc/merchant_dashboard_cubit.dart';
import 'package:wovzo_mobile/features/business_dashboard/presentation/bloc/merchant_dashboard_state.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  bool shouldFail = false;

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    if (shouldFail) {
      throw const ApiNetworkException(message: 'Failed to connect to analytics server');
    }
    return const DashboardSummaryModel(
      latestDaily: AnalyticsSnapshotModel(
        id: 'snap1',
        period: 1,
        periodStart: '2026-08-26',
        periodEnd: '2026-08-26',
        totalOrders: 15,
        totalRevenue: 1500.0,
        averageOrderValue: 100.0,
        cancelledOrders: 1,
        refundAmount: 0.0,
        totalCustomers: 50,
        newCustomers: 5,
        returningCustomers: 45,
        conversionRate: 3.5,
        inventoryValue: 25000.0,
        lowStockCount: 3,
        averageRating: 4.8,
        reviewCount: 20,
        createdAtUtc: '2026-08-26T00:00:00Z',
      ),
    );
  }

  @override
  Future<SalesReportModel> getSalesReport({required String startDate, required String endDate, int? interval, int? status, int? paymentMethod}) => throw UnimplementedError();

  @override
  Future<PagedResult<ProductPerformanceModel>> getProductPerformanceReport({required String startDate, required String endDate, String? categoryId, String? brandId, int page = 1, int pageSize = 20, String? sortBy, String? sortDirection}) => throw UnimplementedError();

  @override
  Future<List<CategoryPerformanceModel>> getCategoryPerformanceReport({required String startDate, required String endDate}) => throw UnimplementedError();

  @override
  Future<List<BrandPerformanceModel>> getBrandPerformanceReport({required String startDate, required String endDate}) => throw UnimplementedError();

  @override
  Future<CustomerAnalyticsReportModel> getCustomerAnalyticsReport({required String startDate, required String endDate, int page = 1, int pageSize = 20, String? sortBy, String? sortDirection}) => throw UnimplementedError();

  @override
  Future<InventoryReportModel> getInventoryReport({bool lowStockOnly = false, String? categoryId, int page = 1, int pageSize = 20, String? sortBy, String? sortDirection}) => throw UnimplementedError();

  @override
  Future<Uint8List> exportSalesReport({required String startDate, required String endDate, int? interval, int? status, int? paymentMethod}) => throw UnimplementedError();

  @override
  Future<Uint8List> exportProductPerformanceReport({required String startDate, required String endDate, String? categoryId, String? brandId, String? sortBy, String? sortDirection}) => throw UnimplementedError();

  @override
  Future<Uint8List> exportCategoryPerformanceReport({required String startDate, required String endDate}) => throw UnimplementedError();

  @override
  Future<Uint8List> exportBrandPerformanceReport({required String startDate, required String endDate}) => throw UnimplementedError();

  @override
  Future<Uint8List> exportCustomerAnalyticsReport({required String startDate, required String endDate, String? sortBy, String? sortDirection}) => throw UnimplementedError();

  @override
  Future<Uint8List> exportInventoryReport({bool lowStockOnly = false, String? categoryId, String? sortBy, String? sortDirection}) => throw UnimplementedError();
}

void main() {
  group('DashboardSummaryModel Tests', () {
    test('DashboardSummaryModel.fromJson parses backend DTO correctly', () {
      final json = {
        'latestDaily': {
          'id': 'snap1',
          'period': 1,
          'periodStart': '2026-08-26',
          'periodEnd': '2026-08-26',
          'totalOrders': 15,
          'totalRevenue': 1500.0,
          'averageOrderValue': 100.0,
          'cancelledOrders': 1,
          'refundAmount': 0.0,
          'totalCustomers': 50,
          'newCustomers': 5,
          'returningCustomers': 45,
          'conversionRate': 3.5,
          'inventoryValue': 25000.0,
          'lowStockCount': 3,
          'averageRating': 4.8,
          'reviewCount': 20,
          'createdAtUtc': '2026-08-26T00:00:00Z',
        }
      };

      final summary = DashboardSummaryModel.fromJson(json);
      expect(summary.latestDaily, isNotNull);
      expect(summary.latestDaily?.totalOrders, 15);
      expect(summary.latestDaily?.totalRevenue, 1500.0);
      expect(summary.latestDaily?.lowStockCount, 3);
    });
  });

  group('MerchantDashboardCubit Tests', () {
    late MockAnalyticsRepository repository;
    late MerchantDashboardCubit cubit;

    setUp(() {
      repository = MockAnalyticsRepository();
      cubit = MerchantDashboardCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MerchantDashboardStatus.initial', () {
      expect(cubit.state.status, MerchantDashboardStatus.initial);
    });

    test('loadDashboard emits loading then success', () async {
      final states = <MerchantDashboardState>[];
      cubit.stream.listen(states.add);

      await cubit.loadDashboard();
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, MerchantDashboardStatus.loading);
      expect(states[1].status, MerchantDashboardStatus.success);
      expect(states[1].summary?.latestDaily?.totalRevenue, 1500.0);
    });

    test('loadDashboard emits error on failure', () async {
      repository.shouldFail = true;

      final states = <MerchantDashboardState>[];
      cubit.stream.listen(states.add);

      await cubit.loadDashboard();
      await Future.delayed(Duration.zero);

      expect(states.last.status, MerchantDashboardStatus.error);
      expect(states.last.errorMessage, 'Failed to connect to analytics server');
    });
  });
}

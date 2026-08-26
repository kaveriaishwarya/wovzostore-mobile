import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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
import 'package:wovzo_mobile/features/business_dashboard/presentation/screens/merchant_dashboard_screen.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  bool shouldFail = false;
  DashboardSummaryModel summary = const DashboardSummaryModel(
    latestDaily: AnalyticsSnapshotModel(
      id: 's1',
      period: 1,
      periodStart: '2026-08-26',
      periodEnd: '2026-08-26',
      totalOrders: 10,
      totalRevenue: 2500.0,
      averageOrderValue: 250.0,
      cancelledOrders: 0,
      refundAmount: 0,
      totalCustomers: 40,
      newCustomers: 4,
      returningCustomers: 36,
      conversionRate: 4.0,
      inventoryValue: 10000.0,
      lowStockCount: 2,
      averageRating: 4.5,
      reviewCount: 10,
      createdAtUtc: '2026-08-26T00:00:00Z',
    ),
  );

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    if (shouldFail) {
      throw const ApiNetworkException(message: 'Network error occurred');
    }
    return summary;
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
  final sl = GetIt.instance;
  late FakeAnalyticsRepository repository;
  late MerchantDashboardCubit cubit;

  setUp(() {
    sl.reset();
    repository = FakeAnalyticsRepository();
    sl.registerLazySingleton<AnalyticsRepository>(() => repository);
    cubit = MerchantDashboardCubit(repository: repository);
    sl.registerFactory<MerchantDashboardCubit>(() => cubit);
  });

  tearDown(() {
    cubit.close();
    sl.reset();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MerchantDashboardScreen(cubit: cubit),
    );
  }

  group('MerchantDashboardScreen Widget Tests', () {
    testWidgets('renders title and loaded dashboard metrics', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('WOVZO BUSINESS'), findsOneWidget);
      expect(find.text('Merchant Dashboard'), findsOneWidget);
      expect(find.text('₹2500.00'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('POS'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
    });

    testWidgets('renders low stock banner when low stock count > 0', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Low Stock Alert'), findsOneWidget);
      expect(find.text('2 products require inventory replenishment.'), findsOneWidget);
    });

    testWidgets('renders error state and retry button on failure', (tester) async {
      repository.shouldFail = true;

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Network error occurred'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

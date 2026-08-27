import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wovzo_mobile/core/auth/auth_role.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';
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
import 'package:wovzo_mobile/features/merchant_settings/data/models/store_settings_model.dart';
import 'package:wovzo_mobile/features/merchant_settings/domain/repositories/merchant_settings_repository.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/cubit/merchant_settings_cubit.dart';
import 'package:wovzo_mobile/features/merchant_settings/presentation/screens/merchant_settings_screen.dart';

class DummyAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<DashboardSummaryModel> getDashboardSummary() async => const DashboardSummaryModel();

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

class DummyMerchantSettingsRepository implements MerchantSettingsRepository {
  @override
  Future<StoreSettingsModel> getStoreSettings() async => StoreSettingsModel(
        storeName: 'Test Store',
        codEnabled: true,
        minOrderAmountForCod: 0,
        defaultCurrency: 'INR',
        flatDeliveryCharge: 0,
        estimatedDeliveryDays: 0,
        returnWindowDays: 0,
        replaceWindowDays: 0,
        returnAllowed: true,
        createdAt: DateTime.now(),
      );

  @override
  Future<StoreSettingsModel> updateStoreSettings(StoreSettingsModel settings) async => settings;
}

void main() {
  final sl = GetIt.instance;

  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<AnalyticsRepository>(() => DummyAnalyticsRepository());
    sl.registerFactory<MerchantDashboardCubit>(() => MerchantDashboardCubit(repository: sl<AnalyticsRepository>()));
    sl.registerLazySingleton<MerchantSettingsRepository>(() => DummyMerchantSettingsRepository());
    sl.registerFactory<MerchantSettingsCubit>(() => MerchantSettingsCubit(repository: sl<MerchantSettingsRepository>()));
  });

  tearDown(() async {
    await sl.reset();
  });

  group('Business Router & Role Guard Tests', () {
    test('unauthenticated access to /business redirects to /login', () {
      final redirect = AppRouter.guardBusinessRoute(
        location: '/business',
        isAuthenticated: false,
        userRole: null,
      );
      expect(redirect, '/login');
    });

    test('Customer role accessing /business redirects to /home', () {
      final redirect = AppRouter.guardBusinessRoute(
        location: '/business',
        isAuthenticated: true,
        userRole: AppRole.customer,
      );
      expect(redirect, '/home');
    });

    test('Merchant roles (Admin, SuperAdmin, StoreManager) accessing /business resolve to /business/dashboard', () {
      final adminRedirect = AppRouter.guardBusinessRoute(
        location: '/business',
        isAuthenticated: true,
        userRole: AppRole.admin,
      );
      expect(adminRedirect, '/business/dashboard');

      final superAdminRedirect = AppRouter.guardBusinessRoute(
        location: '/business/dashboard',
        isAuthenticated: true,
        userRole: AppRole.superAdmin,
      );
      expect(superAdminRedirect, isNull);

      final managerRedirect = AppRouter.guardBusinessRoute(
        location: '/business/dashboard',
        isAuthenticated: true,
        userRole: AppRole.storeManager,
      );
      expect(managerRedirect, isNull);
    });

    test('Settings route (/business/settings) role authorization guards', () {
      // Unauthenticated -> /login
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/settings',
          isAuthenticated: false,
          userRole: null,
        ),
        '/login',
      );

      // Customer -> /home
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/settings',
          isAuthenticated: true,
          userRole: AppRole.customer,
        ),
        '/home',
      );

      // StoreManager -> /unauthorized (DENIED)
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/settings',
          isAuthenticated: true,
          userRole: AppRole.storeManager,
        ),
        '/unauthorized',
      );

      // Admin -> ALLOW (null)
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/settings',
          isAuthenticated: true,
          userRole: AppRole.admin,
        ),
        isNull,
      );

      // SuperAdmin -> ALLOW (null)
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/settings',
          isAuthenticated: true,
          userRole: AppRole.superAdmin,
        ),
        isNull,
      );
    });

    test('guardBusinessRoute enforces /business/staff role restrictions', () {
      // Unauthenticated -> /login
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/staff',
          isAuthenticated: false,
          userRole: null,
        ),
        equals('/login'),
      );

      // Customer -> /home
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/staff',
          isAuthenticated: true,
          userRole: AppRole.customer,
        ),
        equals('/home'),
      );

      // StoreManager -> /unauthorized
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/staff',
          isAuthenticated: true,
          userRole: AppRole.storeManager,
        ),
        equals('/unauthorized'),
      );

      // Admin -> ALLOW (null)
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/staff',
          isAuthenticated: true,
          userRole: AppRole.admin,
        ),
        isNull,
      );

      // SuperAdmin -> ALLOW (null)
      expect(
        AppRouter.guardBusinessRoute(
          location: '/business/staff',
          isAuthenticated: true,
          userRole: AppRole.superAdmin,
        ),
        isNull,
      );
    });

    testWidgets('authenticated merchant accessing /business/dashboard renders MerchantDashboardScreen', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/business/dashboard',
        isAuthenticated: true,
        userRole: AppRole.admin,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      expect(find.byType(MerchantDashboardScreen), findsOneWidget);
    });

    testWidgets('authenticated admin accessing /business/settings renders MerchantSettingsScreen', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/business/settings',
        isAuthenticated: true,
        userRole: AppRole.admin,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(MerchantSettingsScreen), findsOneWidget);
    });
  });
}

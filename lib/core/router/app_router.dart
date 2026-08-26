import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/presentation/bloc/category_brand_cubit.dart';
import '../../features/analytics/presentation/bloc/customer_analytics_cubit.dart';
import '../../features/analytics/presentation/bloc/inventory_report_cubit.dart';
import '../../features/analytics/presentation/bloc/product_performance_cubit.dart';
import '../../features/analytics/presentation/bloc/sales_cubit.dart';
import '../../features/analytics/presentation/screens/analytics_hub_screen.dart';
import '../../features/analytics/presentation/screens/category_brand_performance_screen.dart';
import '../../features/analytics/presentation/screens/customer_analytics_screen.dart';
import '../../features/analytics/presentation/screens/inventory_report_screen.dart';
import '../../features/analytics/presentation/screens/product_performance_screen.dart';
import '../../features/analytics/presentation/screens/sales_report_screen.dart';
import '../auth/auth_role.dart';
import '../di/injection.dart';

class AppRouter {
  static List<RouteBase> get analyticsRoutes => [
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsHubScreen(),
          routes: [
            GoRoute(
              path: 'sales',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<SalesCubit>(),
                child: const SalesReportScreen(),
              ),
            ),
            GoRoute(
              path: 'products',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<ProductPerformanceCubit>(),
                child: const ProductPerformanceScreen(),
              ),
            ),
            GoRoute(
              path: 'categories-brands',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<CategoryBrandCubit>(),
                child: const CategoryBrandPerformanceScreen(),
              ),
            ),
            GoRoute(
              path: 'customers',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<CustomerAnalyticsCubit>(),
                child: const CustomerAnalyticsScreen(),
              ),
            ),
            GoRoute(
              path: 'inventory',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<InventoryReportCubit>(),
                child: const InventoryReportScreen(),
              ),
            ),
          ],
        ),
      ];

  /// Route guard redirect logic for Analytics
  static String? guardAnalyticsRoute({
    required String location,
    required bool isAuthenticated,
    required AppRole? userRole,
  }) {
    if (location.startsWith('/analytics')) {
      if (!isAuthenticated) {
        return '/login';
      }
      if (!AuthRoleHelper.canAccessAnalytics(userRole)) {
        return '/unauthorized';
      }
    }
    return null;
  }

  /// Factory creating standard GoRouter with Analytics integration
  static GoRouter createRouter({
    String initialLocation = '/analytics',
    bool isAuthenticated = true,
    AppRole? userRole = AppRole.admin,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) {
        return guardAnalyticsRoute(
          location: state.matchedLocation,
          isAuthenticated: isAuthenticated,
          userRole: userRole,
        );
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Login Screen')),
          ),
        ),
        GoRoute(
          path: '/unauthorized',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Unauthorized: Access Denied')),
          ),
        ),
        ...analyticsRoutes,
      ],
    );
  }
}

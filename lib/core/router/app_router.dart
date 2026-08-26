import 'dart:async';
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

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';

import '../../features/catalog/presentation/bloc/catalog_cubit.dart';
import '../../features/catalog/presentation/bloc/product_details_cubit.dart';
import '../../features/catalog/presentation/bloc/product_list_cubit.dart';
import '../../features/catalog/presentation/screens/categories_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/product_details_screen.dart';
import '../../features/catalog/presentation/screens/product_list_screen.dart';

import '../../features/business_dashboard/presentation/screens/merchant_dashboard_screen.dart';

import '../auth/auth_role.dart';
import '../di/injection.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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

  /// Route guard redirect logic for Business Dashboard & Merchant routes
  static String? guardBusinessRoute({
    required String location,
    required bool isAuthenticated,
    required AppRole? userRole,
  }) {
    if (location.startsWith('/business')) {
      if (!isAuthenticated) {
        return '/login';
      }
      if (userRole == AppRole.customer) {
        return '/home';
      }
      if (!AuthRoleHelper.canAccessAnalytics(userRole)) {
        return '/unauthorized';
      }
      if (location == '/business') {
        return '/business/dashboard';
      }
    }
    return null;
  }

  /// Global authentication and navigation redirect logic
  static String? handleRedirect({
    required String location,
    required AuthState authState,
    required bool isMocked,
    bool mockIsAuthenticated = false,
    AppRole? mockUserRole,
  }) {
    // 1. If checking session on startup, do not redirect prematurely
    if (!isMocked && (authState.isCheckingSession || authState.status == AuthStatus.initial)) {
      return null;
    }

    final isAuthenticated = isMocked ? mockIsAuthenticated : authState.isAuthenticated;
    final userRole = isMocked
        ? mockUserRole
        : AuthRoleHelper.fromClaim(authState.user?.role);

    final isAuthRoute = location == '/login' || location == '/otp-verify';

    // 2. Unauthenticated user accessing protected routes -> /login
    if (!isAuthenticated && !isAuthRoute && location != '/unauthorized') {
      return '/login';
    }

    // 3. Authenticated user accessing auth routes -> /business/dashboard for Merchant, /home for Customer
    if (isAuthenticated && isAuthRoute) {
      if (AuthRoleHelper.canAccessAnalytics(userRole)) {
        return '/business/dashboard';
      }
      return '/home';
    }

    // 4. Analytics role authorization check
    if (location.startsWith('/analytics')) {
      return guardAnalyticsRoute(
        location: location,
        isAuthenticated: isAuthenticated,
        userRole: userRole,
      );
    }

    // 5. Business role authorization check
    if (location.startsWith('/business')) {
      return guardBusinessRoute(
        location: location,
        isAuthenticated: isAuthenticated,
        userRole: userRole,
      );
    }

    return null;
  }

  /// Factory creating standard GoRouter with Auth and Analytics integration
  static GoRouter createRouter({
    String initialLocation = '/home',
    AuthCubit? authCubit,
    bool? isAuthenticated,
    AppRole? userRole,
  }) {
    final cubit = authCubit ?? (sl.isRegistered<AuthCubit>() ? sl<AuthCubit>() : null);
    final isMocked = isAuthenticated != null || userRole != null;

    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: cubit != null ? GoRouterRefreshStream(cubit.stream) : null,
      redirect: (context, state) {
        final currentAuthState = cubit?.state ?? const AuthState.unauthenticated();
        return handleRedirect(
          location: state.matchedLocation,
          authState: currentAuthState,
          isMocked: isMocked,
          mockIsAuthenticated: isAuthenticated ?? true,
          mockUserRole: userRole ?? AppRole.admin,
        );
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            final activeCubit = cubit ?? sl<AuthCubit>();
            return BlocProvider.value(
              value: activeCubit,
              child: LoginScreen(
                onOtpSent: (phone) {
                  GoRouter.of(context).push('/otp-verify', extra: phone);
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/otp-verify',
          builder: (context, state) {
            final activeCubit = cubit ?? sl<AuthCubit>();
            final phone = state.extra as String? ?? state.uri.queryParameters['phone'] ?? '';
            return BlocProvider.value(
              value: activeCubit,
              child: OtpVerificationScreen(phone: phone),
            );
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<CatalogCubit>(),
            child: HomeScreen(
              onCategoryTap: (categoryId) {
                context.go('/products?categoryId=$categoryId');
              },
              onSearchTap: () {
                context.go('/products');
              },
              onProductTap: (productId) {
                context.push('/products/$productId');
              },
            ),
          ),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<CatalogCubit>(),
            child: CategoriesScreen(
              onCategoryTap: (categoryId, categoryName) {
                context.go('/products?categoryId=$categoryId&categoryName=${Uri.encodeComponent(categoryName)}');
              },
            ),
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) {
            final categoryId = state.uri.queryParameters['categoryId'];
            final categoryName = state.uri.queryParameters['categoryName'];
            final brandId = state.uri.queryParameters['brandId'];
            final search = state.uri.queryParameters['search'];

            return BlocProvider(
              create: (_) => sl<ProductListCubit>(),
              child: ProductListScreen(
                categoryId: categoryId,
                categoryName: categoryName,
                brandId: brandId,
                searchQuery: search,
                onProductTap: (productId) {
                  context.push('/products/$productId');
                },
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'slug/:slug',
              builder: (context, state) {
                final slug = state.pathParameters['slug'];
                return BlocProvider(
                  create: (_) => sl<ProductDetailsCubit>(),
                  child: ProductDetailsScreen(productSlug: slug),
                );
              },
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                return BlocProvider(
                  create: (_) => sl<ProductDetailsCubit>(),
                  child: ProductDetailsScreen(productId: id),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/unauthorized',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Unauthorized: Access Denied')),
          ),
        ),
        GoRoute(
          path: '/business',
          redirect: (context, state) => '/business/dashboard',
          routes: [
            GoRoute(
              path: 'dashboard',
              builder: (context, state) => MerchantDashboardScreen(
                onAnalyticsTap: () => context.push('/analytics'),
              ),
            ),
          ],
        ),
        ...analyticsRoutes,
      ],
    );
  }
}

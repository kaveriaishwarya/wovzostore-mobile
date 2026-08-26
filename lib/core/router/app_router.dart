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
import '../../features/home/presentation/screens/home_placeholder_screen.dart';

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

    // 3. Authenticated user accessing auth routes -> /home
    if (isAuthenticated && isAuthRoute) {
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
          builder: (context, state) => const HomePlaceholderScreen(),
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

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
import '../../features/auth/presentation/screens/business_onboarding_screen.dart';

import '../../features/catalog/presentation/bloc/catalog_cubit.dart';
import '../../features/catalog/presentation/bloc/product_details_cubit.dart';
import '../../features/catalog/presentation/bloc/product_list_cubit.dart';
import '../../features/catalog/presentation/screens/categories_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/product_details_screen.dart';
import '../../features/catalog/presentation/screens/product_list_screen.dart';

import '../../features/business_dashboard/presentation/screens/merchant_dashboard_screen.dart';
import '../../features/merchant_products/presentation/screens/merchant_product_form_screen.dart';
import '../../features/merchant_products/presentation/screens/merchant_product_list_screen.dart';
import '../../features/merchant_orders/presentation/screens/merchant_order_detail_screen.dart';
import '../../features/merchant_orders/presentation/screens/merchant_order_list_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/merchant_customers/presentation/screens/merchant_customer_detail_screen.dart';
import '../../features/merchant_customers/presentation/screens/merchant_customer_list_screen.dart';
import '../../features/merchant_settings/presentation/screens/merchant_settings_screen.dart';
import '../../features/merchant_settings/presentation/cubit/merchant_settings_cubit.dart';
import '../../features/merchant_staff/presentation/screens/merchant_staff_detail_screen.dart';
import '../../features/merchant_staff/presentation/screens/merchant_staff_list_screen.dart';
import '../../features/merchant_purchases/presentation/screens/merchant_supplier_list_screen.dart';
import '../../features/merchant_purchases/presentation/screens/merchant_purchase_list_screen.dart';
import '../../features/merchant_purchases/presentation/screens/merchant_purchase_detail_screen.dart';
import '../../features/merchant_purchases/presentation/screens/goods_receiving_screen.dart';
import '../../features/merchant_purchases/presentation/screens/stock_movement_list_screen.dart';

import '../../features/store_context/presentation/bloc/store_context_cubit.dart';
import '../../features/store_context/presentation/bloc/store_context_state.dart';
import '../../features/store_context/presentation/screens/store_selection_screen.dart';

import '../auth/auth_role.dart';
import '../di/injection.dart';

class MultiStreamListenable extends ChangeNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  MultiStreamListenable(List<Stream<dynamic>> streams) {
    for (final stream in streams) {
      _subscriptions.add(stream.asBroadcastStream().listen((_) => notifyListeners()));
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
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
    if (location == '/business-onboarding') {
      return null;
    }
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
      if (location.startsWith('/business/settings')) {
        if (!AuthRoleHelper.canAccessSettings(userRole)) {
          return '/unauthorized';
        }
      }
      if (location.startsWith('/business/staff')) {
        if (!AuthRoleHelper.canAccessStaff(userRole)) {
          return '/unauthorized';
        }
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
    StoreContextState storeContextState = const StoreContextInitial(),
    StoreContextCubit? storeContextCubit,
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

    // 3. Authenticated User Store Context Resolution
    if (isAuthenticated) {
      if (!isMocked) {
        if (storeContextState is StoreContextInitial) {
          // Initialize store context once authentication is established
          storeContextCubit?.loadStoresAndRestoreContext();
          return null; // Wait for loading
        }
        if (storeContextState is StoreContextLoading) {
          return null; // Do not interrupt routing or deep links during loading
        }
      }

      final storesLoaded = isMocked || storeContextState is StoreContextLoaded;
      
      if (storesLoaded) {
        final availableStores = isMocked 
            ? [] 
            : (storeContextState as StoreContextLoaded).availableStores;
        
        final activeStoreId = isMocked 
            ? "mock_store" 
            : (storeContextState as StoreContextLoaded).activeStoreId;

        if (!isMocked) {
          // Zero stores -> Onboarding
          if (availableStores.isEmpty) {
            if (isAuthRoute || location == '/store-selection' || (location.startsWith('/business') && location != '/business-onboarding')) {
              return '/business-onboarding';
            }
          } 
          // Missing active store (Multiple stores) -> Selection
          else if (activeStoreId == null) {
            if (isAuthRoute || location == '/business-onboarding' || (location.startsWith('/business') && location != '/store-selection')) {
              return '/store-selection';
            }
          } 
          // Has valid active store
          else {
            if (isAuthRoute || location == '/store-selection' || location == '/business-onboarding') {
              return userRole == AppRole.customer ? '/home' : '/business/dashboard';
            }
          }
        } else {
          // Mocking behavior for existing tests to avoid breaking them
          if (isAuthRoute) return '/business-onboarding';
        }

        // Run existing authorization guards for analytics/business
        if (location.startsWith('/analytics')) {
          return guardAnalyticsRoute(
            location: location,
            isAuthenticated: isAuthenticated,
            userRole: userRole,
          );
        }

        if (location.startsWith('/business')) {
          return guardBusinessRoute(
            location: location,
            isAuthenticated: isAuthenticated,
            userRole: userRole,
          );
        }
      }
    }

    return null;
  }

  /// Factory creating standard GoRouter with Auth, StoreContext, and Analytics integration
  static GoRouter createRouter({
    String initialLocation = '/home',
    AuthCubit? authCubit,
    StoreContextCubit? storeContextCubit,
    bool? isAuthenticated,
    AppRole? userRole,
  }) {
    final aCubit = authCubit ?? (sl.isRegistered<AuthCubit>() ? sl<AuthCubit>() : null);
    final sCubit = storeContextCubit ?? (sl.isRegistered<StoreContextCubit>() ? sl<StoreContextCubit>() : null);
    final isMocked = isAuthenticated != null || userRole != null;

    List<Stream<dynamic>> refreshStreams = [];
    if (aCubit != null) refreshStreams.add(aCubit.stream);
    if (sCubit != null) refreshStreams.add(sCubit.stream);

    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: refreshStreams.isNotEmpty ? MultiStreamListenable(refreshStreams) : null,
      redirect: (context, state) {
        final currentAuthState = aCubit?.state ?? const AuthState.unauthenticated();
        final currentStoreState = sCubit?.state ?? const StoreContextInitial();
        
        return handleRedirect(
          location: state.matchedLocation,
          authState: currentAuthState,
          storeContextState: currentStoreState,
          storeContextCubit: sCubit,
          isMocked: isMocked,
          mockIsAuthenticated: isAuthenticated ?? true,
          mockUserRole: userRole ?? AppRole.admin,
        );
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            final activeCubit = aCubit ?? sl<AuthCubit>();
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
            final activeCubit = aCubit ?? sl<AuthCubit>();
            final phone = state.extra as String? ?? state.uri.queryParameters['phone'] ?? '';
            return BlocProvider.value(
              value: activeCubit,
              child: OtpVerificationScreen(phone: phone),
            );
          },
        ),
        GoRoute(
          path: '/store-selection',
          builder: (context, state) => const StoreSelectionScreen(),
        ),
        GoRoute(
          path: '/business-onboarding',
          builder: (context, state) {
            final activeCubit = aCubit ?? sl<AuthCubit>();
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: activeCubit),
                BlocProvider(create: (_) => sl<MerchantSettingsCubit>()),
              ],
              child: BusinessOnboardingScreen(
                onSuccess: () {
                  // After business onboarding (store creation), we force reload the stores.
                  if (sCubit != null) {
                    sCubit.loadStoresAndRestoreContext();
                  } else if (sl.isRegistered<StoreContextCubit>()) {
                    sl<StoreContextCubit>().loadStoresAndRestoreContext();
                  }
                  context.go('/business/dashboard');
                },
              ),
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
          redirect: (context, state) => state.uri.path == '/business' ? '/business/dashboard' : null,
          routes: [
            GoRoute(
              path: 'dashboard',
              builder: (context, state) => MerchantDashboardScreen(
                onAnalyticsTap: () => context.push('/business/analytics'),
                onProductsTap: () => context.push('/business/products'),
                onOrdersTap: () => context.push('/business/orders'),
                onPosTap: () => context.push('/business/pos'),
                onCustomersTap: () => context.push('/business/customers'),
                onSettingsTap: () => context.push('/business/settings'),
                onStaffTap: () => context.push('/business/staff'),
                onSuppliersTap: () => context.push('/business/suppliers'),
                onPurchasesTap: () => context.push('/business/purchases'),
                onStockMovementsTap: () => context.push('/business/inventory/stock-movements'),
              ),
            ),
            GoRoute(
              path: 'analytics',
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
            GoRoute(
              path: 'suppliers',
              builder: (context, state) => const MerchantSupplierListScreen(),
            ),
            GoRoute(
              path: 'purchases',
              builder: (context, state) => MerchantPurchaseListScreen(
                onPurchaseTap: (id) => context.push('/business/purchases/$id'),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return MerchantPurchaseDetailScreen(
                      purchaseId: id,
                      onReceiveGoodsTap: () => context.push('/business/purchases/$id/receive'),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'receive',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return GoodsReceivingScreen(purchaseId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'inventory/stock-movements',
              builder: (context, state) => const StockMovementListScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const MerchantSettingsScreen(),
            ),
            GoRoute(
              path: 'staff',
              builder: (context, state) => MerchantStaffListScreen(
                onStaffTap: (id) => context.push('/business/staff/$id'),
                onAddStaffTap: () => context.push('/business/staff/new'),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final staffId = state.pathParameters['id']!;
                    return MerchantStaffDetailScreen(staffId: staffId);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'customers',
              builder: (context, state) => MerchantCustomerListScreen(
                onCustomerTap: (id) => context.push('/business/customers/$id'),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final customerId = state.pathParameters['id']!;
                    return MerchantCustomerDetailScreen(customerId: customerId);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'pos',
              builder: (context, state) => const PosScreen(),
            ),
            GoRoute(
              path: 'products',
              builder: (context, state) => MerchantProductListScreen(
                onAddProductTap: () => context.push('/business/products/new'),
                onEditProductTap: (id) => context.push('/business/products/$id/edit'),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const MerchantProductFormScreen(),
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) => const MerchantProductFormScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'orders',
              builder: (context, state) => MerchantOrderListScreen(
                onOrderTap: (id) => context.push('/business/orders/$id'),
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final orderId = state.pathParameters['id']!;
                    return MerchantOrderDetailScreen(orderId: orderId);
                  },
                ),
              ],
            ),
          ],
        ),
        ...analyticsRoutes,
      ],
    );
  }
}

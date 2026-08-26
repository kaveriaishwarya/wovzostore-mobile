import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/auth/auth_role.dart';
import 'package:wovzo_mobile/core/di/injection.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/catalog_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_details_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/bloc/product_list_cubit.dart';
import 'package:wovzo_mobile/features/catalog/presentation/screens/categories_screen.dart';
import 'package:wovzo_mobile/features/catalog/presentation/screens/home_screen.dart';
import 'package:wovzo_mobile/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:wovzo_mobile/features/catalog/presentation/screens/product_list_screen.dart';

class DummyCatalogRepository implements CatalogRepository {
  @override
  Future<List<BannerModel>> getBanners() async => const [];
  @override
  Future<List<CategoryModel>> getCategories() async => const [];
  @override
  Future<List<CategoryModel>> getCategoryTree() async => const [];
  @override
  Future<List<BrandModel>> getBrands() async => const [];

  @override
  Future<PagedProductsModel> getProducts({
    String? categoryId,
    String? brandId,
    String? search,
    String? sortBy,
    String? sortDirection,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PagedProductsModel(items: [], totalCount: 0, page: 1, pageSize: 20);
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    return ProductModel(id: id, name: 'Prod $id', slug: 'p-$id', categoryId: 'c1', status: 1, basePrice: 10, isActive: true, isFeatured: false);
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    return ProductModel(id: 'p_slug', name: 'Slug Prod', slug: slug, categoryId: 'c1', status: 1, basePrice: 10, isActive: true, isFeatured: false);
  }
}

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<CatalogRepository>(() => DummyCatalogRepository());
    sl.registerFactory<CatalogCubit>(() => CatalogCubit(repository: sl<CatalogRepository>()));
    sl.registerFactory<ProductListCubit>(() => ProductListCubit(repository: sl<CatalogRepository>()));
    sl.registerFactory<ProductDetailsCubit>(() => ProductDetailsCubit(repository: sl<CatalogRepository>()));
  });

  tearDown(() async {
    await sl.reset();
  });

  group('Catalog Router Tests', () {
    testWidgets('authenticated /home renders HomeScreen', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/home',
        isAuthenticated: true,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('authenticated /categories renders CategoriesScreen', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/categories',
        isAuthenticated: true,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesScreen), findsOneWidget);
    });

    testWidgets('authenticated /products renders ProductListScreen with query params', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/products?search=shoes&categoryId=c100',
        isAuthenticated: true,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(ProductListScreen), findsOneWidget);
      final screen = tester.widget<ProductListScreen>(find.byType(ProductListScreen));
      expect(screen.categoryId, 'c100');
      expect(screen.searchQuery, 'shoes');
    });

    testWidgets('authenticated /products/:id renders ProductDetailsScreen', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/products/prod_555',
        isAuthenticated: true,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      final screen = tester.widget<ProductDetailsScreen>(find.byType(ProductDetailsScreen));
      expect(screen.productId, 'prod_555');
    });

    test('unauthenticated access to protected catalog route /home redirects to /login', () {
      final redirect = AppRouter.handleRedirect(
        location: '/home',
        authState: const AuthState.unauthenticated(),
        isMocked: false,
      );
      expect(redirect, '/login');
    });

    test('Analytics routes and role guards remain functional', () {
      final redirect = AppRouter.guardAnalyticsRoute(
        location: '/analytics',
        isAuthenticated: true,
        userRole: AppRole.admin,
      );
      expect(redirect, isNull);

      final customerRedirect = AppRouter.guardAnalyticsRoute(
        location: '/analytics',
        isAuthenticated: true,
        userRole: AppRole.customer,
      );
      expect(customerRedirect, '/unauthorized');
    });
  });
}

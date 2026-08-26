import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/auth/auth_role.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';

void main() {
  group('Analytics Route Guard & Routing Tests', () {
    test('unauthenticated user is redirected to /login', () {
      final redirect = AppRouter.guardAnalyticsRoute(
        location: '/analytics',
        isAuthenticated: false,
        userRole: null,
      );
      expect(redirect, '/login');
    });

    test('customer user is redirected to /unauthorized', () {
      final redirect = AppRouter.guardAnalyticsRoute(
        location: '/analytics/sales',
        isAuthenticated: true,
        userRole: AppRole.customer,
      );
      expect(redirect, '/unauthorized');
    });

    test('Admin user is allowed access (no redirect)', () {
      final redirect = AppRouter.guardAnalyticsRoute(
        location: '/analytics',
        isAuthenticated: true,
        userRole: AppRole.admin,
      );
      expect(redirect, isNull);
    });

    test('SuperAdmin user is allowed access (no redirect)', () {
      final redirect = AppRouter.guardAnalyticsRoute(
        location: '/analytics/products',
        isAuthenticated: true,
        userRole: AppRole.superAdmin,
      );
      expect(redirect, isNull);
    });

    test('StoreManager user is allowed access (no redirect)', () {
      final redirect = AppRouter.guardAnalyticsRoute(
        location: '/analytics/inventory',
        isAuthenticated: true,
        userRole: AppRole.storeManager,
      );
      expect(redirect, isNull);
    });

    testWidgets('router renders unauthorized screen when customer accesses analytics', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/analytics',
        isAuthenticated: true,
        userRole: AppRole.customer,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Unauthorized: Access Denied'), findsOneWidget);
    });

    testWidgets('router renders login screen when anonymous user accesses analytics', (tester) async {
      final router = AppRouter.createRouter(
        initialLocation: '/analytics/sales',
        isAuthenticated: false,
        userRole: null,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}

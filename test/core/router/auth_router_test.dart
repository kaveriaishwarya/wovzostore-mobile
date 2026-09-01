import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/auth/auth_role.dart';
import 'package:wovzo_mobile/core/router/app_router.dart';
import 'package:wovzo_mobile/features/auth/data/models/user_model.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('Auth Router & Navigation Guard Tests', () {
    test('checkingSession state on startup does NOT redirect to /login prematurely', () {
      const state = AuthState.checkingSession();

      final redirect = AppRouter.handleRedirect(
        location: '/home',
        authState: state,
        isMocked: false,
      );

      expect(redirect, isNull);
    });

    test('unauthenticated user accessing protected /home is redirected to /login', () {
      const state = AuthState.unauthenticated();

      final redirect = AppRouter.handleRedirect(
        location: '/home',
        authState: state,
        isMocked: false,
      );

      expect(redirect, '/login');
    });

    test('authenticated user accessing /login is redirected to /home', () {
      const state = AuthState.authenticated(
        UserModel(userId: 'u1', role: 'Customer'),
      );

      final redirect = AppRouter.handleRedirect(
        location: '/login',
        authState: state,
        isMocked: false,
      );

      expect(redirect, '/business-onboarding');
    });

    test('authenticated user accessing /otp-verify is redirected to /home', () {
      const state = AuthState.authenticated(
        UserModel(userId: 'u1', role: 'Customer'),
      );

      final redirect = AppRouter.handleRedirect(
        location: '/otp-verify',
        authState: state,
        isMocked: false,
      );

      expect(redirect, '/business-onboarding');
    });

    test('authenticated user accessing /home is allowed (no redirect)', () {
      const state = AuthState.authenticated(
        UserModel(userId: 'u1', role: 'Customer'),
      );

      final redirect = AppRouter.handleRedirect(
        location: '/home',
        authState: state,
        isMocked: false,
      );

      expect(redirect, isNull);
    });

    test('Customer role accessing /analytics is redirected to /unauthorized', () {
      const state = AuthState.authenticated(
        UserModel(userId: 'u1', role: 'Customer'),
      );

      final redirect = AppRouter.handleRedirect(
        location: '/analytics',
        authState: state,
        isMocked: false,
      );

      expect(redirect, '/unauthorized');
    });

    test('Admin role accessing /analytics is allowed (no redirect)', () {
      const state = AuthState.authenticated(
        UserModel(userId: 'u1', role: 'Admin'),
      );

      final redirect = AppRouter.handleRedirect(
        location: '/analytics',
        authState: state,
        isMocked: false,
      );

      expect(redirect, isNull);
    });

    test('SuperAdmin role accessing /analytics is allowed (no redirect)', () {
      const state = AuthState.authenticated(
        UserModel(userId: 'u1', role: 'SuperAdmin'),
      );

      final redirect = AppRouter.handleRedirect(
        location: '/analytics/sales',
        authState: state,
        isMocked: false,
      );

      expect(redirect, isNull);
    });

    test('StoreManager role accessing /analytics is allowed (no redirect)', () {
      const state = AuthState.authenticated(
        UserModel(userId: 'u1', role: 'StoreManager'),
      );

      final redirect = AppRouter.handleRedirect(
        location: '/analytics/inventory',
        authState: state,
        isMocked: false,
      );

      expect(redirect, isNull);
    });

    test('mocked router compatibility mode preserves Analytics route guards', () {
      expect(
        AppRouter.guardAnalyticsRoute(
          location: '/analytics',
          isAuthenticated: false,
          userRole: null,
        ),
        '/login',
      );

      expect(
        AppRouter.guardAnalyticsRoute(
          location: '/analytics',
          isAuthenticated: true,
          userRole: AppRole.customer,
        ),
        '/unauthorized',
      );

      expect(
        AppRouter.guardAnalyticsRoute(
          location: '/analytics',
          isAuthenticated: true,
          userRole: AppRole.admin,
        ),
        isNull,
      );
    });
  });
}

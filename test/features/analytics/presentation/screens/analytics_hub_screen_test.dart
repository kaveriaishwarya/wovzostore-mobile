import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wovzo_mobile/features/analytics/presentation/screens/analytics_hub_screen.dart';

void main() {
  Widget createWidgetUnderTest(GoRouter router) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('AnalyticsHubScreen Widget Tests', () {
    testWidgets('renders title and all 5 report destination cards', (tester) async {
      final router = GoRouter(
        initialLocation: '/analytics',
        routes: [
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsHubScreen(),
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(router));
      await tester.pumpAndSettle();

      expect(find.text('Store Analytics & Reports'), findsOneWidget);
      expect(find.text('Reports Overview'), findsOneWidget);
      expect(find.text('Sales Report'), findsOneWidget);
      expect(find.text('Product Performance'), findsOneWidget);
      expect(find.text('Categories & Brands'), findsOneWidget);
      expect(find.text('Customer Analytics'), findsOneWidget);
      expect(find.text('Inventory Report'), findsOneWidget);
    });

    testWidgets('tapping destination card navigates to sub-route', (tester) async {
      String? navigatedLocation;

      final router = GoRouter(
        initialLocation: '/analytics',
        routes: [
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsHubScreen(),
            routes: [
              GoRoute(
                path: 'sales',
                builder: (context, state) {
                  navigatedLocation = state.matchedLocation;
                  return const Scaffold(body: Text('Sales Screen Destination'));
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sales Report'));
      await tester.pumpAndSettle();

      expect(navigatedLocation, '/analytics/sales');
      expect(find.text('Sales Screen Destination'), findsOneWidget);
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/di/injection.dart';
import 'package:wovzo_mobile/main.dart';

void main() {
  setUp(() {
    setupInjection();
  });

  testWidgets('MyApp mounts MaterialApp.router successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}

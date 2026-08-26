import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/di/injection.dart';
import 'package:wovzo_mobile/main.dart';

void main() {
  setUp(() {
    setupInjection();
  });

  testWidgets('MyApp mounts MaterialApp.router successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}

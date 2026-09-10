import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wovzo_mobile/features/store_context/data/models/store_dto.dart';
import 'package:wovzo_mobile/features/store_context/domain/repositories/store_repository.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_cubit.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_state.dart';
import 'package:wovzo_mobile/features/store_context/presentation/screens/store_discovery_screen.dart';

class MockStoreRepository extends Mock implements StoreRepository {}
class MockStoreContextCubit extends Mock implements StoreContextCubit {}

void main() {
  late MockStoreRepository mockRepository;
  late MockStoreContextCubit mockCubit;

  setUp(() {
    mockRepository = MockStoreRepository();
    mockCubit = MockStoreContextCubit();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.state).thenReturn(const StoreContextInitial());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidget({String? initialSlug}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<StoreContextCubit>.value(value: mockCubit),
        ],
        child: RepositoryProvider<StoreRepository>.value(
          value: mockRepository,
          child: StoreDiscoveryScreen(initialSlug: initialSlug),
        ),
      ),
    );
  }

  testWidgets('shows input field and submit button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enter Store'), findsOneWidget);
    expect(find.text('Are you a merchant? Create a store'), findsOneWidget);
  });

  testWidgets('shows error when store is not found', (WidgetTester tester) async {
    when(() => mockRepository.getStoreBySlug(any()))
        .thenThrow(Exception('Store not found'));

    await tester.pumpWidget(createWidget());
    
    await tester.enterText(find.byType(TextField), 'invalid-slug');
    await tester.tap(find.text('Enter Store'));
    await tester.pumpAndSettle();

    expect(find.text('Store not found. Please check the URL or slug.'), findsOneWidget);
  });

  testWidgets('resolves store and sets active store ID', (WidgetTester tester) async {
    const store = StoreDto(id: 'store-123', name: 'Test Store', slug: 'test-store', role: 'Customer');
    when(() => mockRepository.getStoreBySlug('test-store'))
        .thenAnswer((_) async => store);

    await tester.pumpWidget(createWidget());
    
    await tester.enterText(find.byType(TextField), 'test-store');
    await tester.tap(find.text('Enter Store'));
    
    // We can't fully test navigation since we're not using GoRouter here,
    // but we can verify that getStoreBySlug and setActiveStore were called.
    await tester.pump();
    
    verify(() => mockRepository.getStoreBySlug('test-store')).called(1);
    verify(() => mockCubit.setActiveStore('store-123')).called(1);
  });

  testWidgets('automatically resolves initialSlug', (WidgetTester tester) async {
    const store = StoreDto(id: 'store-456', name: 'Cool Store', slug: 'cool-store', role: 'Customer');
    when(() => mockRepository.getStoreBySlug('cool-store'))
        .thenAnswer((_) async => store);

    await tester.pumpWidget(createWidget(initialSlug: 'cool-store'));
    await tester.pump();
    
    verify(() => mockRepository.getStoreBySlug('cool-store')).called(1);
    verify(() => mockCubit.setActiveStore('store-456')).called(1);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/store_context/data/models/store_dto.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_cubit.dart';
import 'package:wovzo_mobile/features/store_context/presentation/bloc/store_context_state.dart';
import 'package:wovzo_mobile/features/store_context/presentation/screens/store_selection_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStoreContextCubit extends MockCubit<StoreContextState> implements StoreContextCubit {
  @override
  Future<void> loadStoresAndRestoreContext() async {}

  @override
  Future<void> setActiveStore(String storeId) async {}
}

void main() {
  late MockStoreContextCubit mockCubit;

  setUp(() {
    mockCubit = MockStoreContextCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<StoreContextCubit>.value(
        value: mockCubit,
        child: const StoreSelectionScreen(),
      ),
    );
  }

  testWidgets('shows loading indicator when state is Initial or Loading', (tester) async {
    when(() => mockCubit.state).thenReturn(const StoreContextInitial());
    whenListen(mockCubit, Stream<StoreContextState>.empty(), initialState: const StoreContextInitial());
    
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    when(() => mockCubit.state).thenReturn(const StoreContextLoading());
    whenListen(mockCubit, Stream<StoreContextState>.empty(), initialState: const StoreContextLoading());
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error state and retry button', (tester) async {
    when(() => mockCubit.state).thenReturn(const StoreContextError('Failed to load'));
    whenListen(mockCubit, Stream<StoreContextState>.empty(), initialState: const StoreContextError('Failed to load'));
    
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Failed to load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows no stores available when list is empty', (tester) async {
    when(() => mockCubit.state).thenReturn(const StoreContextLoaded(
      availableStores: [],
      activeStoreId: null,
      activeStore: null,
    ));
    whenListen(mockCubit, Stream<StoreContextState>.empty(), initialState: const StoreContextLoaded(
      availableStores: [],
      activeStoreId: null,
      activeStore: null,
    ));
    
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('No stores available'), findsOneWidget);
  });

  testWidgets('renders multiple stores and indicates active store', (tester) async {
    const store1 = StoreDto(id: '1', name: 'Store A', slug: 'a', role: 'Merchant');
    const store2 = StoreDto(id: '2', name: 'Store B', slug: 'b', role: 'Staff');

    when(() => mockCubit.state).thenReturn(const StoreContextLoaded(
      availableStores: [store1, store2],
      activeStoreId: '1',
      activeStore: store1,
    ));
    whenListen(mockCubit, Stream<StoreContextState>.empty(), initialState: const StoreContextLoaded(
      availableStores: [store1, store2],
      activeStoreId: '1',
      activeStore: store1,
    ));
    
    await tester.pumpWidget(createWidgetUnderTest());
    
    expect(find.text('Store A'), findsOneWidget);
    expect(find.text('Store B'), findsOneWidget);
    expect(find.text('Role: Merchant'), findsOneWidget);
    expect(find.text('Role: Staff'), findsOneWidget);
    
    // Check mark should be present for active store
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}

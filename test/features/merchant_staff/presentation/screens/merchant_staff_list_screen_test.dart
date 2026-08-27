import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/create_staff_request_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/merchant_staff_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/update_staff_request_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/domain/repositories/merchant_staff_repository.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/bloc/merchant_staff_list_cubit.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/screens/merchant_staff_list_screen.dart';

class FakeMerchantStaffRepository implements MerchantStaffRepository {
  bool shouldFail = false;
  final List<MerchantStaffModel> mockStaff = [
    MerchantStaffModel(
      id: 'staff-1',
      fullName: 'Ramesh Kumar',
      email: 'ramesh@wovzo.com',
      phoneNumber: '9876543210',
      role: 'StoreManager',
      isActive: true,
      createdAt: DateTime.parse('2026-08-28T01:00:00.000Z'),
    ),
    MerchantStaffModel(
      id: 'staff-2',
      fullName: 'Priya Sharma',
      email: 'priya@wovzo.com',
      phoneNumber: '9876543211',
      role: 'Support',
      isActive: false,
      createdAt: DateTime.parse('2026-08-28T01:00:00.000Z'),
    ),
  ];

  @override
  Future<PagedResult<MerchantStaffModel>> getStaff({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    if (shouldFail) throw Exception('Failed to load staff members');
    var filtered = mockStaff.toList();
    if (role != null) {
      filtered = filtered.where((s) => s.role == role).toList();
    }
    if (isActive != null) {
      filtered = filtered.where((s) => s.isActive == isActive).toList();
    }
    return PagedResult(
      data: filtered,
      pageNumber: page,
      pageSize: pageSize,
      totalCount: filtered.length,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<MerchantStaffModel> getStaffById(String id) async => mockStaff.first;

  @override
  Future<MerchantStaffModel> createStaff(CreateStaffRequestModel request) async => mockStaff.first;

  @override
  Future<MerchantStaffModel> updateStaff(String id, UpdateStaffRequestModel request) async => mockStaff.first;

  @override
  Future<void> activateStaff(String id) async {}

  @override
  Future<void> deactivateStaff(String id) async {}
}

void main() {
  final sl = GetIt.instance;
  late FakeMerchantStaffRepository fakeRepository;

  setUp(() async {
    await sl.reset();
    fakeRepository = FakeMerchantStaffRepository();
    sl.registerLazySingleton<MerchantStaffRepository>(() => fakeRepository);
    sl.registerFactory<MerchantStaffListCubit>(
        () => MerchantStaffListCubit(repository: sl<MerchantStaffRepository>()));
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  Finder findChip(String label) {
    return find.byWidgetPredicate(
      (w) => w is FilterChip && w.label is Text && (w.label as Text).data == label,
    );
  }

  group('MerchantStaffListScreen Widget Tests', () {
    testWidgets('renders search bar, filter chips, and staff list cards', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MerchantStaffListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Staff & Role Management'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(findChip('All Roles'), findsOneWidget);
      expect(findChip('SuperAdmin'), findsOneWidget);
      expect(findChip('Admin'), findsOneWidget);
      expect(findChip('StoreManager'), findsOneWidget);
      expect(findChip('Support'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(findChip('Active'), findsOneWidget);
      expect(findChip('Inactive'), findsOneWidget);
    });

    testWidgets('filtering by role updates visible staff list', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MerchantStaffListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);

      await tester.tap(findChip('Support'));
      await tester.pumpAndSettle();

      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Ramesh Kumar'), findsNothing);
    });

    testWidgets('displays error view with retry button on failure', (tester) async {
      fakeRepository.shouldFail = true;

      await tester.pumpWidget(buildTestableWidget(const MerchantStaffListScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load staff members'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wovzo_mobile/core/storage/secure_storage_service.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/otp_request_model.dart';
import 'package:wovzo_mobile/features/auth/data/models/user_model.dart';
import 'package:wovzo_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wovzo_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/create_staff_request_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/merchant_staff_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/update_staff_request_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/domain/repositories/merchant_staff_repository.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/bloc/merchant_staff_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/screens/merchant_staff_detail_screen.dart';

class MockAuthCubit extends Cubit<AuthState> implements AuthCubit {
  MockAuthCubit(super.initialState);

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> requestOtp(String phone) async {}

  @override
  Future<void> verifyOtp(String phone, String otp) async {}

  Future<void> adminLogin(String email, String password) async {}

  @override
  Future<void> logout() async {}
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<OtpSentResponseModel> requestOtp(String phone) async => throw UnimplementedError();

  @override
  Future<AuthResponseModel> verifyOtp(String phone, String otp) async => throw UnimplementedError();

  @override
  Future<UserModel> getCurrentUser() async => const UserModel(userId: 'u1', role: 'SuperAdmin');

  @override
  Future<void> logout(String refreshToken) async {}
}

class FakeSecureStorageService implements SecureStorageService {
  @override
  Future<void> clearAll() async {}

  @override
  Future<void> deleteTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'fake-token';

  @override
  Future<String?> getRefreshToken() async => 'fake-refresh';

  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<void> saveRefreshToken(String token) async {}

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
}

class FakeMerchantStaffRepository implements MerchantStaffRepository {
  bool shouldFail = false;
  MerchantStaffModel sampleStaff = MerchantStaffModel(
    id: 'staff-101',
    fullName: 'Anil Gupta',
    email: 'anil@wovzo.com',
    phoneNumber: '9876543210',
    role: 'StoreManager',
    isActive: true,
    createdAt: DateTime.parse('2026-08-28T01:00:00.000Z'),
  );

  @override
  Future<PagedResult<MerchantStaffModel>> getStaff({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? role,
    bool? isActive,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MerchantStaffModel> getStaffById(String id) async {
    if (shouldFail) throw Exception('Failed to load staff details');
    return sampleStaff;
  }

  @override
  Future<MerchantStaffModel> createStaff(CreateStaffRequestModel request) async {
    if (shouldFail) throw Exception('Create failed');
    return sampleStaff;
  }

  @override
  Future<MerchantStaffModel> updateStaff(String id, UpdateStaffRequestModel request) async {
    if (shouldFail) throw Exception('Update failed');
    return sampleStaff;
  }

  @override
  Future<void> activateStaff(String id) async {
    if (shouldFail) throw Exception('Activation failed');
  }

  @override
  Future<void> deactivateStaff(String id) async {
    if (shouldFail) throw Exception('Deactivation failed');
  }
}

void main() {
  final sl = GetIt.instance;
  late FakeMerchantStaffRepository fakeStaffRepo;
  late FakeAuthRepository fakeAuthRepo;
  late FakeSecureStorageService fakeStorage;

  setUp(() async {
    await sl.reset();
    fakeStaffRepo = FakeMerchantStaffRepository();
    fakeAuthRepo = FakeAuthRepository();
    fakeStorage = FakeSecureStorageService();

    sl.registerLazySingleton<MerchantStaffRepository>(() => fakeStaffRepo);
    sl.registerLazySingleton<AuthRepository>(() => fakeAuthRepo);
    sl.registerLazySingleton<SecureStorageService>(() => fakeStorage);
    sl.registerFactory<MerchantStaffDetailCubit>(
        () => MerchantStaffDetailCubit(repository: sl<MerchantStaffRepository>()));
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildTestableWidget(Widget child, {String role = 'SuperAdmin'}) {
    final user = UserModel(
      userId: 'user-admin',
      role: role,
      email: 'admin@wovzo.com',
      isActive: true,
    );

    final authCubit = MockAuthCubit(AuthState.authenticated(user));

    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: child,
      ),
    );
  }

  group('MerchantStaffDetailScreen Widget Tests', () {
    testWidgets('renders Create Form when staffId is "new"', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MerchantStaffDetailScreen(staffId: 'new')));
      await tester.pumpAndSettle();

      expect(find.text('Create New Staff'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Email Address *'), findsOneWidget);
      expect(find.text('Initial Password *'), findsOneWidget);
      expect(find.text('Create Staff Member'), findsOneWidget);
    });

    testWidgets('renders Profile Details and action buttons when loading existing staff', (tester) async {
      fakeStaffRepo.sampleStaff = MerchantStaffModel(
        id: 'staff-101',
        fullName: 'Anil Gupta',
        email: 'anil@wovzo.com',
        phoneNumber: '9876543210',
        role: 'StoreManager',
        isActive: true,
        createdAt: DateTime.parse('2026-08-28T01:00:00.000Z'),
      );

      await tester.pumpWidget(buildTestableWidget(const MerchantStaffDetailScreen(staffId: 'staff-101')));
      await tester.pumpAndSettle();

      expect(find.text('Staff Profile'), findsOneWidget);
      expect(find.text('Anil Gupta'), findsOneWidget);
      expect(find.text('anil@wovzo.com'), findsNWidgets(2));
      expect(find.text('Store Manager'), findsOneWidget);
      expect(find.text('Edit Profile & Role'), findsOneWidget);
      expect(find.text('Deactivate Staff Account'), findsOneWidget);
    });

    testWidgets('deactivate button presents confirmation dialog', (tester) async {
      fakeStaffRepo.sampleStaff = MerchantStaffModel(
        id: 'staff-101',
        fullName: 'Anil Gupta',
        email: 'anil@wovzo.com',
        phoneNumber: '9876543210',
        role: 'StoreManager',
        isActive: true,
        createdAt: DateTime.parse('2026-08-28T01:00:00.000Z'),
      );

      await tester.pumpWidget(buildTestableWidget(const MerchantStaffDetailScreen(staffId: 'staff-101')));
      await tester.pumpAndSettle();

      final deactivateBtn = find.text('Deactivate Staff Account');
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(deactivateBtn);
      await tester.pumpAndSettle();

      expect(find.text('Deactivate Account'), findsOneWidget);
      expect(find.textContaining('This will immediately lock out their account'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });

    testWidgets('shows warning banner when Admin views an Admin/SuperAdmin profile', (tester) async {
      fakeStaffRepo.sampleStaff = MerchantStaffModel(
        id: 'staff-102',
        fullName: 'Executive Admin',
        email: 'exec@wovzo.com',
        phoneNumber: '9876543222',
        role: 'Admin',
        isActive: true,
        createdAt: DateTime.parse('2026-08-28T01:00:00.000Z'),
      );

      await tester.pumpWidget(buildTestableWidget(
        const MerchantStaffDetailScreen(staffId: 'staff-102'),
        role: 'Admin',
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Admin Security Policy'), findsOneWidget);
      expect(find.text('Edit Profile & Role'), findsNothing);
    });
  });
}

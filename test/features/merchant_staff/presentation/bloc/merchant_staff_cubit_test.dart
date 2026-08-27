import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/create_staff_request_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/merchant_staff_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/data/models/update_staff_request_model.dart';
import 'package:wovzo_mobile/features/merchant_staff/domain/repositories/merchant_staff_repository.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/bloc/merchant_staff_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/bloc/merchant_staff_detail_state.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/bloc/merchant_staff_list_cubit.dart';
import 'package:wovzo_mobile/features/merchant_staff/presentation/bloc/merchant_staff_list_state.dart';

class FakeMerchantStaffRepository implements MerchantStaffRepository {
  bool shouldFail = false;
  final List<MerchantStaffModel> mockStaffList = [
    MerchantStaffModel(
      id: 'staff-1',
      fullName: 'Ramesh Kumar',
      email: 'ramesh@wovzo.com',
      phoneNumber: '9876543210',
      role: 'StoreManager',
      isActive: true,
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
    if (shouldFail) throw Exception('Network error');
    return PagedResult(
      data: mockStaffList,
      pageNumber: page,
      pageSize: pageSize,
      totalCount: mockStaffList.length,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<MerchantStaffModel> getStaffById(String id) async {
    if (shouldFail) throw Exception('Staff not found');
    return mockStaffList.firstWhere((s) => s.id == id, orElse: () => mockStaffList.first);
  }

  @override
  Future<MerchantStaffModel> createStaff(CreateStaffRequestModel request) async {
    if (shouldFail) throw Exception('Create failed');
    final newStaff = MerchantStaffModel(
      id: 'staff-new',
      fullName: request.fullName,
      email: request.email,
      phoneNumber: request.phoneNumber,
      role: request.role,
      isActive: true,
      createdAt: DateTime.now(),
    );
    mockStaffList.add(newStaff);
    return newStaff;
  }

  @override
  Future<MerchantStaffModel> updateStaff(String id, UpdateStaffRequestModel request) async {
    if (shouldFail) throw Exception('Update failed');
    return MerchantStaffModel(
      id: id,
      fullName: request.fullName,
      email: 'ramesh@wovzo.com',
      phoneNumber: request.phoneNumber,
      role: request.role,
      isActive: true,
      createdAt: DateTime.now(),
    );
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
  late FakeMerchantStaffRepository fakeRepository;
  late MerchantStaffListCubit listCubit;
  late MerchantStaffDetailCubit detailCubit;

  setUp(() {
    fakeRepository = FakeMerchantStaffRepository();
    listCubit = MerchantStaffListCubit(repository: fakeRepository);
    detailCubit = MerchantStaffDetailCubit(repository: fakeRepository);
  });

  tearDown(() {
    listCubit.close();
    detailCubit.close();
  });

  group('MerchantStaffListCubit', () {
    test('loadStaff emits Loading then Loaded state', () async {
      final expectedStates = [
        isA<MerchantStaffListLoading>(),
        isA<MerchantStaffListLoaded>(),
      ];

      expectLater(listCubit.stream, emitsInOrder(expectedStates));
      await listCubit.loadStaff();

      final state = listCubit.state as MerchantStaffListLoaded;
      expect(state.staff.length, equals(1));
      expect(state.staff.first.id, equals('staff-1'));
    });

    test('loadStaff emits Loading then Error on failure', () async {
      fakeRepository.shouldFail = true;

      final expectedStates = [
        isA<MerchantStaffListLoading>(),
        isA<MerchantStaffListError>(),
      ];

      expectLater(listCubit.stream, emitsInOrder(expectedStates));
      await listCubit.loadStaff();
    });
  });

  group('MerchantStaffDetailCubit', () {
    test('loadStaffDetail emits Loading then Loaded', () async {
      final expectedStates = [
        isA<MerchantStaffDetailLoading>(),
        isA<MerchantStaffDetailLoaded>(),
      ];

      expectLater(detailCubit.stream, emitsInOrder(expectedStates));
      await detailCubit.loadStaffDetail('staff-1');
    });

    test('createStaff emits Loading then ActionSuccess', () async {
      final expectedStates = [
        isA<MerchantStaffDetailLoading>(),
        isA<MerchantStaffDetailActionSuccess>(),
      ];

      expectLater(detailCubit.stream, emitsInOrder(expectedStates));
      await detailCubit.createStaff(const CreateStaffRequestModel(
        fullName: 'New Staff',
        email: 'new@wovzo.com',
        role: 'Support',
        password: 'Pass123!',
      ));
    });

    test('deactivateStaff emits Loading then ActionSuccess', () async {
      final expectedStates = [
        isA<MerchantStaffDetailLoading>(),
        isA<MerchantStaffDetailActionSuccess>(),
      ];

      expectLater(detailCubit.stream, emitsInOrder(expectedStates));
      await detailCubit.deactivateStaff('staff-1');
    });
  });
}

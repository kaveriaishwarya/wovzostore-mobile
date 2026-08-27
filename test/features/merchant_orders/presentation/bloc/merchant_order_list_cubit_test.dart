import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_list_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/domain/repositories/merchant_order_repository.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/bloc/merchant_order_list_cubit.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/bloc/merchant_order_list_state.dart';

class MockMerchantOrderRepository implements MerchantOrderRepository {
  bool shouldFail = false;

  @override
  Future<PagedResult<OrderListModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to fetch orders');
    return PagedResult<OrderListModel>(
      data: [
        OrderListModel(
          id: 'ord-1',
          orderNumber: 'WVZ-0001',
          customerId: 'cust-1',
          status: status ?? 1,
          statusName: 'Placed',
          paymentStatus: 1,
          paymentStatusName: 'Paid',
          paymentMethod: 1,
          paymentMethodName: 'Online',
          grandTotal: 500.0,
          currency: 'INR',
          createdAt: DateTime(2026, 8, 28),
        ),
      ],
      pageNumber: page,
      pageSize: pageSize,
      totalCount: 1,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<OrderModel> getOrderById(String orderId) => throw UnimplementedError();
  @override
  Future<OrderModel> getOrderByOrderNumber(String orderNumber) => throw UnimplementedError();
  @override
  Future<OrderModel> confirmOrder(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
  @override
  Future<OrderModel> startProcessingOrder(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
  @override
  Future<OrderModel> packOrder(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
  @override
  Future<OrderModel> shipOrder(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
  @override
  Future<OrderModel> markOutForDelivery(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
  @override
  Future<OrderModel> deliverOrder(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
  @override
  Future<OrderModel> cancelOrder(String orderId, String reason) => throw UnimplementedError();
  @override
  Future<OrderModel> approveReturn(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
  @override
  Future<OrderModel> completeReturn(String orderId, {String? comment, String? adminId}) => throw UnimplementedError();
}

void main() {
  group('MerchantOrderListCubit Tests', () {
    late MockMerchantOrderRepository repository;
    late MerchantOrderListCubit cubit;

    setUp(() {
      repository = MockMerchantOrderRepository();
      cubit = MerchantOrderListCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MerchantOrderListStatus.initial', () {
      expect(cubit.state.status, MerchantOrderListStatus.initial);
    });

    test('loadOrders emits loading then success state', () async {
      final states = <MerchantOrderListState>[];
      cubit.stream.listen(states.add);

      await cubit.loadOrders();
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, MerchantOrderListStatus.loading);
      expect(states[1].status, MerchantOrderListStatus.success);
      expect(states[1].orders.length, 1);
    });

    test('filterByStatus reloads with status filter', () async {
      final states = <MerchantOrderListState>[];
      cubit.stream.listen(states.add);

      await cubit.filterByStatus(2);
      await Future.delayed(Duration.zero);

      expect(states.last.status, MerchantOrderListStatus.success);
      expect(states.last.statusFilter, 2);
    });

    test('loadOrders emits error state on failure', () async {
      repository.shouldFail = true;

      final states = <MerchantOrderListState>[];
      cubit.stream.listen(states.add);

      await cubit.loadOrders();
      await Future.delayed(Duration.zero);

      expect(states.last.status, MerchantOrderListStatus.error);
      expect(states.last.errorMessage, 'Failed to fetch orders');
    });
  });
}

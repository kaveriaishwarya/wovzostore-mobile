import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/api_exception.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_list_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/domain/repositories/merchant_order_repository.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/bloc/merchant_order_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/bloc/merchant_order_detail_state.dart';

class MockDetailMerchantOrderRepository implements MerchantOrderRepository {
  bool shouldFail = false;

  final sampleOrder = OrderModel(
    id: 'ord-123',
    orderNumber: 'WVZ-0001',
    customerId: 'cust-1',
    checkoutId: 'chk-1',
    status: 1,
    statusName: 'Placed',
    paymentStatus: 1,
    paymentStatusName: 'Paid',
    paymentMethod: 1,
    paymentMethodName: 'Online',
    summary: const OrderSummaryModel(
      subtotal: 500.0,
      discountTotal: 0.0,
      shippingFee: 0.0,
      taxAmount: 0.0,
      grandTotal: 500.0,
      currency: 'INR',
    ),
    createdAt: DateTime(2026, 8, 28),
    items: const [],
    statusHistory: const [],
  );

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    if (shouldFail) throw const ApiNotFoundException(message: 'Order not found');
    return sampleOrder;
  }

  @override
  Future<OrderModel> confirmOrder(String orderId, {String? comment, String? adminId}) async {
    if (shouldFail) throw const ApiNetworkException(message: 'Failed to confirm order');
    return OrderModel(
      id: orderId,
      orderNumber: sampleOrder.orderNumber,
      customerId: sampleOrder.customerId,
      checkoutId: sampleOrder.checkoutId,
      status: 2,
      statusName: 'Confirmed',
      paymentStatus: sampleOrder.paymentStatus,
      paymentStatusName: sampleOrder.paymentStatusName,
      paymentMethod: sampleOrder.paymentMethod,
      paymentMethodName: sampleOrder.paymentMethodName,
      summary: sampleOrder.summary,
      createdAt: sampleOrder.createdAt,
      items: sampleOrder.items,
      statusHistory: sampleOrder.statusHistory,
    );
  }

  @override
  Future<PagedResult<OrderListModel>> getOrders({int page = 1, int pageSize = 20, int? status, String? search, String? sortBy, String? sortDirection}) => throw UnimplementedError();
  @override
  Future<OrderModel> getOrderByOrderNumber(String orderNumber) => throw UnimplementedError();
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
  group('MerchantOrderDetailCubit Tests', () {
    late MockDetailMerchantOrderRepository repository;
    late MerchantOrderDetailCubit cubit;

    setUp(() {
      repository = MockDetailMerchantOrderRepository();
      cubit = MerchantOrderDetailCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is MerchantOrderDetailStatus.initial', () {
      expect(cubit.state.status, MerchantOrderDetailStatus.initial);
    });

    test('loadOrder emits loading then success state', () async {
      final states = <MerchantOrderDetailState>[];
      cubit.stream.listen(states.add);

      await cubit.loadOrder('ord-123');
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, MerchantOrderDetailStatus.loading);
      expect(states[1].status, MerchantOrderDetailStatus.success);
      expect(states[1].order?.id, 'ord-123');
    });

    test('confirmOrder emits updating then success with updated status', () async {
      final states = <MerchantOrderDetailState>[];
      cubit.stream.listen(states.add);

      await cubit.confirmOrder('ord-123');
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, MerchantOrderDetailStatus.updating);
      expect(states[1].status, MerchantOrderDetailStatus.success);
      expect(states[1].order?.status, 2);
      expect(states[1].order?.statusName, 'Confirmed');
    });
  });
}

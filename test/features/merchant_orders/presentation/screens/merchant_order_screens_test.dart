import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_list_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/data/models/order_model.dart';
import 'package:wovzo_mobile/features/merchant_orders/domain/repositories/merchant_order_repository.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/bloc/merchant_order_detail_cubit.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/bloc/merchant_order_list_cubit.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/screens/merchant_order_detail_screen.dart';
import 'package:wovzo_mobile/features/merchant_orders/presentation/screens/merchant_order_list_screen.dart';

class MockUIOrdersRepository implements MerchantOrderRepository {
  final sampleOrder = OrderModel(
    id: 'ord-123',
    orderNumber: 'WVZ-20260828-0001',
    customerId: 'cust-1',
    checkoutId: 'chk-1',
    status: 1,
    statusName: 'Placed',
    paymentStatus: 1,
    paymentStatusName: 'Paid',
    paymentMethod: 1,
    paymentMethodName: 'Online',
    shippingAddress: const AddressSnapshotModel(
      fullName: 'Jane Doe',
      phoneNumber: '9876543210',
      line1: '456 Tech Park',
      city: 'Bangalore',
      state: 'Karnataka',
      pinCode: '560002',
      country: 'India',
    ),
    summary: const OrderSummaryModel(
      subtotal: 1000.0,
      discountTotal: 0.0,
      shippingFee: 50.0,
      taxAmount: 0.0,
      grandTotal: 1050.0,
      currency: 'INR',
    ),
    createdAt: DateTime(2026, 8, 28),
    items: const [
      OrderItemModel(
        id: 'item-1',
        orderId: 'ord-123',
        productVariantId: 'var-1',
        productId: 'prod-1',
        sku: 'SKU-100',
        productName: 'Cotton Hoodie',
        variantName: 'Black L',
        unitPrice: 1000.0,
        quantity: 1,
        lineTotal: 1000.0,
      ),
    ],
    statusHistory: const [],
  );

  @override
  Future<PagedResult<OrderListModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? search,
    String? sortBy,
    String? sortDirection,
  }) async {
    return PagedResult<OrderListModel>(
      data: [
        OrderListModel(
          id: 'ord-123',
          orderNumber: 'WVZ-20260828-0001',
          customerId: 'cust-1',
          status: status ?? 1,
          statusName: 'Placed',
          paymentStatus: 1,
          paymentStatusName: 'Paid',
          paymentMethod: 1,
          paymentMethodName: 'Online',
          grandTotal: 1050.0,
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
  Future<OrderModel> getOrderById(String orderId) async => sampleOrder;
  @override
  Future<OrderModel> getOrderByOrderNumber(String orderNumber) async => sampleOrder;
  @override
  Future<OrderModel> confirmOrder(String orderId, {String? comment, String? adminId}) async => sampleOrder;
  @override
  Future<OrderModel> startProcessingOrder(String orderId, {String? comment, String? adminId}) async => sampleOrder;
  @override
  Future<OrderModel> packOrder(String orderId, {String? comment, String? adminId}) async => sampleOrder;
  @override
  Future<OrderModel> shipOrder(String orderId, {String? comment, String? adminId}) async => sampleOrder;
  @override
  Future<OrderModel> markOutForDelivery(String orderId, {String? comment, String? adminId}) async => sampleOrder;
  @override
  Future<OrderModel> deliverOrder(String orderId, {String? comment, String? adminId}) async => sampleOrder;
  @override
  Future<OrderModel> cancelOrder(String orderId, String reason) async => sampleOrder;
  @override
  Future<OrderModel> approveReturn(String orderId, {String? comment, String? adminId}) async => sampleOrder;
  @override
  Future<OrderModel> completeReturn(String orderId, {String? comment, String? adminId}) async => sampleOrder;
}

void main() {
  final sl = GetIt.instance;
  late MockUIOrdersRepository repository;
  late MerchantOrderListCubit listCubit;
  late MerchantOrderDetailCubit detailCubit;

  setUp(() {
    sl.reset();
    repository = MockUIOrdersRepository();
    listCubit = MerchantOrderListCubit(repository: repository);
    detailCubit = MerchantOrderDetailCubit(repository: repository);

    sl.registerLazySingleton<MerchantOrderRepository>(() => repository);
    sl.registerFactory<MerchantOrderListCubit>(() => listCubit);
    sl.registerFactory<MerchantOrderDetailCubit>(() => detailCubit);
  });

  tearDown(() {
    sl.reset();
  });

  group('Merchant Order Screens Widget Tests', () {
    testWidgets('MerchantOrderListScreen renders status tabs, search bar, and order cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantOrderListScreen(cubit: listCubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Processing & Fulfillment'), findsOneWidget);
      expect(find.text('WVZ-20260828-0001'), findsOneWidget);
      expect(find.text('Total: ₹1050.00'), findsOneWidget);
      expect(find.text('All Orders'), findsOneWidget);
      expect(find.text('Placed'), findsAtLeast(1));
    });

    testWidgets('MerchantOrderDetailScreen renders customer info, items, and action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantOrderDetailScreen(
            orderId: 'ord-123',
            cubit: detailCubit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('WVZ-20260828-0001'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Cotton Hoodie'), findsOneWidget);
      expect(find.text('Confirm Order'), findsOneWidget);
    });

    testWidgets('Tapping action button opens OrderStatusActionDialog and submits transition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MerchantOrderDetailScreen(
            orderId: 'ord-123',
            cubit: detailCubit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm Order'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Order'), findsAtLeast(1));
      expect(find.text('Comment (Optional)'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
    });
  });
}

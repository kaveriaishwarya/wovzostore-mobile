import 'package:dio/dio.dart';
import '../../../analytics/data/models/paged_result_model.dart';
import '../../../catalog/data/models/product_model.dart';
import '../models/pos_cart_item_model.dart';
import '../models/pos_customer_model.dart';
import '../models/pos_sale_result_model.dart';

abstract class PosRemoteDataSource {
  Future<PagedResult<ProductModel>> searchProducts(String query, {int page = 1, int pageSize = 20});
  Future<List<PosCustomerModel>> getCustomers(String query);
  Future<PosSaleResultModel> processPosSale({
    required PosCustomerModel customer,
    required List<PosCartItemModel> items,
    required int paymentMethod,
    required String paymentMethodName,
  });
}

class PosRemoteDataSourceImpl implements PosRemoteDataSource {
  final Dio _dio;

  PosRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PagedResult<ProductModel>> searchProducts(String query, {int page = 1, int pageSize = 20}) async {
    final response = await _dio.get(
      '/api/v1/catalog/products',
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        'includeInactive': false,
        'page': page,
        'pageSize': pageSize,
      },
    );

    return PagedResult<ProductModel>.fromJson(
      response.data,
      (itemJson) => ProductModel.fromJson(itemJson),
    );
  }

  @override
  Future<List<PosCustomerModel>> getCustomers(String query) async {
    final response = await _dio.get(
      '/api/v1/customers',
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        'page': 1,
        'pageSize': 10,
      },
    );

    final rawData = response.data['data'] as List<dynamic>? ?? [];
    return rawData.map((item) => PosCustomerModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<PosSaleResultModel> processPosSale({
    required PosCustomerModel customer,
    required List<PosCartItemModel> items,
    required int paymentMethod,
    required String paymentMethodName,
  }) async {
    // 1. Add items to cart for customer
    for (final item in items) {
      await _dio.post(
        '/api/v1/cart/items',
        data: {
          'customerId': customer.id,
          'productVariantId': item.productVariantId,
          'quantity': item.quantity,
        },
      );
    }

    // 2. Start Checkout
    final startCheckoutResponse = await _dio.post(
      '/api/v1/checkout',
      data: {'customerId': customer.id},
    );
    final checkoutId = startCheckoutResponse.data['id'] as String;

    // 3. Attach default store address
    await _dio.put(
      '/api/v1/checkout/$checkoutId/shipping-address',
      data: {
        'customerId': customer.id,
        'fullName': customer.fullName,
        'phoneNumber': customer.phoneNumber.isEmpty ? '0000000000' : customer.phoneNumber,
        'line1': 'WOVZO Store Terminal',
        'city': 'Store Location',
        'state': 'State',
        'pinCode': '000000',
        'country': 'India',
      },
    );

    // 4. Complete Checkout
    await _dio.post(
      '/api/v1/checkout/$checkoutId/complete',
      data: {'customerId': customer.id},
    );

    // 5. Place Order
    final placeOrderResponse = await _dio.post(
      '/api/v1/orders',
      data: {
        'customerId': customer.id,
        'checkoutId': checkoutId,
      },
    );
    final orderId = placeOrderResponse.data['id'] as String;
    final orderNumber = placeOrderResponse.data['orderNumber'] as String? ?? 'WVZ-POS';
    final computedTotal = items.fold<double>(0.0, (sum, i) => sum + i.lineTotal);
    final grandTotal = (placeOrderResponse.data['summary']?['grandTotal'] as num?)?.toDouble() ?? computedTotal;

    // 6. Confirm Order
    await _dio.post(
      '/api/v1/orders/$orderId/confirm',
      data: {'comment': 'Instant POS store checkout'},
    );

    // 7. Initiate Payment
    await _dio.post(
      '/api/v1/payments',
      data: {
        'orderId': orderId,
        'method': paymentMethod,
        'provider': 'StorePOS',
      },
    );

    return PosSaleResultModel(
      orderId: orderId,
      orderNumber: orderNumber,
      grandTotal: grandTotal,
      paymentMethod: paymentMethod,
      paymentMethodName: paymentMethodName,
      createdAt: DateTime.now(),
    );
  }
}

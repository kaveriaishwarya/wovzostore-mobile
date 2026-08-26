import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/datasources/analytics_remote_datasource.dart';

void main() {
  late Dio dio;
  late AnalyticsRemoteDataSourceImpl dataSource;
  late RequestOptions capturedRequest;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.wovzo.com'));
    dio.httpClientAdapter = _TestAdapter((options) {
      capturedRequest = options;
      if (options.path.endsWith('/export')) {
        return ResponseBody.fromBytes(
          utf8.encode('col1,col2\nval1,val2'),
          200,
          headers: {
            'content-type': ['text/csv'],
          },
        );
      } else if (options.path.endsWith('/sales')) {
        return ResponseBody.fromString(
          jsonEncode({
            'startDate': '2026-01-01T00:00:00Z',
            'endDate': '2026-01-31T00:00:00Z',
            'grossSales': 50000.0,
            'netSales': 45000.0,
            'orderCount': 20,
            'averageOrderValue': 2500.0,
            'discountAmount': 5000.0,
            'taxAmount': 2000.0,
            'shippingAmount': 1000.0,
            'refundAmount': 0.0,
            'cancelledOrderCount': 1,
            'trend': []
          }),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      } else if (options.path.endsWith('/products')) {
        return ResponseBody.fromString(
          jsonEncode({
            'data': [
              {
                'productId': 'prod-1',
                'productName': 'Sneakers',
                'variantId': null,
                'variantName': null,
                'unitsSold': 10,
                'revenue': 20000.0,
                'averageSellingPrice': 2000.0,
              }
            ],
            'pageNumber': 1,
            'pageSize': 20,
            'totalCount': 1,
            'totalPages': 1,
            'hasPreviousPage': false,
            'hasNextPage': false,
          }),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      } else if (options.path.endsWith('/categories')) {
        return ResponseBody.fromString(
          jsonEncode([
            {
              'categoryId': 'cat-1',
              'categoryName': 'Shoes',
              'unitsSold': 10,
              'revenue': 20000.0,
            }
          ]),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      } else if (options.path.endsWith('/brands')) {
        return ResponseBody.fromString(
          jsonEncode([
            {
              'brandId': 'brand-1',
              'brandName': 'Puma',
              'unitsSold': 10,
              'revenue': 20000.0,
            }
          ]),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      } else if (options.path.endsWith('/customers')) {
        return ResponseBody.fromString(
          jsonEncode({
            'summary': {
              'totalCustomers': 10,
              'newCustomers': 5,
              'returningCustomers': 5,
              'repeatPurchaseRate': 50.0,
              'revenueFromNewCustomers': 10000.0,
              'revenueFromReturningCustomers': 10000.0,
            },
            'topCustomers': {
              'data': [],
              'pageNumber': 1,
              'pageSize': 20,
              'totalCount': 0,
              'totalPages': 0,
              'hasPreviousPage': false,
              'hasNextPage': false,
            }
          }),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      } else if (options.path.endsWith('/inventory')) {
        return ResponseBody.fromString(
          jsonEncode({
            'totalInventoryValue': 500000.0,
            'lowStockCount': 3,
            'outOfStockCount': 1,
            'totalUnits': 300,
            'items': {
              'data': [],
              'pageNumber': 1,
              'pageSize': 20,
              'totalCount': 0,
              'totalPages': 0,
              'hasPreviousPage': false,
              'hasNextPage': false,
            }
          }),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      }
      return ResponseBody.fromString('{}', 200);
    });

    dataSource = AnalyticsRemoteDataSourceImpl(dio: dio);
  });

  group('AnalyticsRemoteDataSource Tests', () {
    test('getSalesReport sends correct path and query parameters', () async {
      final result = await dataSource.getSalesReport(
        startDate: '2026-01-01',
        endDate: '2026-01-31',
        interval: 1,
      );

      expect(capturedRequest.path, '/api/v1/analytics/reports/sales');
      expect(capturedRequest.queryParameters['startDate'], '2026-01-01');
      expect(capturedRequest.queryParameters['endDate'], '2026-01-31');
      expect(capturedRequest.queryParameters['interval'], 1);
      expect(result.grossSales, 50000.0);
    });

    test('getProductPerformanceReport sends pagination and filter parameters', () async {
      final result = await dataSource.getProductPerformanceReport(
        startDate: '2026-01-01',
        endDate: '2026-01-31',
        categoryId: 'cat-123',
        page: 2,
        pageSize: 10,
        sortBy: 'revenue',
        sortDirection: 'desc',
      );

      expect(capturedRequest.path, '/api/v1/analytics/reports/products');
      expect(capturedRequest.queryParameters['categoryId'], 'cat-123');
      expect(capturedRequest.queryParameters['page'], 2);
      expect(capturedRequest.queryParameters['pageSize'], 10);
      expect(capturedRequest.queryParameters['sortBy'], 'revenue');
      expect(capturedRequest.queryParameters['sortDirection'], 'desc');
      expect(result.data.length, 1);
      expect(result.data.first.productName, 'Sneakers');
    });

    test('getCategoryPerformanceReport and getBrandPerformanceReport query correct paths', () async {
      final categories = await dataSource.getCategoryPerformanceReport(
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );
      expect(capturedRequest.path, '/api/v1/analytics/reports/categories');
      expect(categories.length, 1);

      final brands = await dataSource.getBrandPerformanceReport(
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );
      expect(capturedRequest.path, '/api/v1/analytics/reports/brands');
      expect(brands.length, 1);
    });

    test('getCustomerAnalyticsReport sends sort and date parameters', () async {
      final result = await dataSource.getCustomerAnalyticsReport(
        startDate: '2026-01-01',
        endDate: '2026-01-31',
        sortBy: 'ordercount',
        sortDirection: 'asc',
      );

      expect(capturedRequest.path, '/api/v1/analytics/reports/customers');
      expect(capturedRequest.queryParameters['sortBy'], 'ordercount');
      expect(capturedRequest.queryParameters['sortDirection'], 'asc');
      expect(result.summary.totalCustomers, 10);
    });

    test('getInventoryReport sends lowStockOnly and category parameters', () async {
      final result = await dataSource.getInventoryReport(
        lowStockOnly: true,
        categoryId: 'cat-456',
        sortBy: 'stock',
        sortDirection: 'asc',
      );

      expect(capturedRequest.path, '/api/v1/analytics/reports/inventory');
      expect(capturedRequest.queryParameters['lowStockOnly'], true);
      expect(capturedRequest.queryParameters['categoryId'], 'cat-456');
      expect(capturedRequest.queryParameters['sortBy'], 'stock');
      expect(result.totalInventoryValue, 500000.0);
    });

    test('CSV exports configure ResponseType.bytes and return Uint8List bytes', () async {
      final bytes = await dataSource.exportSalesReport(
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      );

      expect(capturedRequest.path, '/api/v1/analytics/reports/sales/export');
      expect(capturedRequest.responseType, ResponseType.bytes);
      expect(bytes, isA<Uint8List>());
      expect(bytes.isNotEmpty, true);
    });
  });
}

class _TestAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _TestAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/sales_report_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/product_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/category_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/brand_performance_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/customer_analytics_model.dart';
import 'package:wovzo_mobile/features/analytics/data/models/inventory_report_model.dart';

void main() {
  group('Analytics Models Serialization Tests', () {
    test('PagedResult deserializes and serializes correctly', () {
      final json = {
        'data': [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ],
        'pageNumber': 1,
        'pageSize': 20,
        'totalCount': 2,
        'totalPages': 1,
        'hasPreviousPage': false,
        'hasNextPage': false,
      };

      final paged = PagedResult.fromJson(
        json,
        (item) => item['name'] as String,
      );

      expect(paged.pageNumber, 1);
      expect(paged.totalCount, 2);
      expect(paged.data, ['Item 1', 'Item 2']);
      expect(paged.hasNextPage, false);

      final outJson = paged.toJson((name) => {'name': name});
      expect(outJson['totalCount'], 2);
    });

    test('SalesReportModel deserializes correctly from backend JSON', () {
      final json = {
        'startDate': '2026-01-01T00:00:00Z',
        'endDate': '2026-01-31T00:00:00Z',
        'grossSales': 150000.50,
        'netSales': 135000.00,
        'orderCount': 45,
        'averageOrderValue': 3333.33,
        'discountAmount': 10000.00,
        'taxAmount': 5000.50,
        'shippingAmount': 2000.00,
        'refundAmount': 2000.00,
        'cancelledOrderCount': 2,
        'trend': [
          {
            'periodStart': '2026-01-01T00:00:00Z',
            'periodEnd': '2026-01-07T00:00:00Z',
            'orderCount': 10,
            'grossSales': 35000.00,
            'netSales': 32000.00,
          }
        ]
      };

      final model = SalesReportModel.fromJson(json);

      expect(model.grossSales, 150000.50);
      expect(model.netSales, 135000.00);
      expect(model.orderCount, 45);
      expect(model.cancelledOrderCount, 2);
      expect(model.trend.length, 1);
      expect(model.trend.first.orderCount, 10);
      expect(model.trend.first.grossSales, 35000.00);
    });

    test('ProductPerformanceModel parses optional variants and numerical metrics', () {
      final jsonWithVariant = {
        'productId': 'prod-123',
        'productName': 'Denim Jacket',
        'variantId': 'var-456',
        'variantName': 'Size L - Blue',
        'unitsSold': 25,
        'revenue': 37500.0,
        'averageSellingPrice': 1500.0,
      };

      final modelWithVariant = ProductPerformanceModel.fromJson(jsonWithVariant);
      expect(modelWithVariant.productId, 'prod-123');
      expect(modelWithVariant.variantId, 'var-456');
      expect(modelWithVariant.unitsSold, 25);
      expect(modelWithVariant.revenue, 37500.0);

      final jsonWithoutVariant = {
        'productId': 'prod-789',
        'productName': 'Leather Belt',
        'variantId': null,
        'variantName': null,
        'unitsSold': 10,
        'revenue': 5000.0,
        'averageSellingPrice': 500.0,
      };

      final modelWithoutVariant = ProductPerformanceModel.fromJson(jsonWithoutVariant);
      expect(modelWithoutVariant.productId, 'prod-789');
      expect(modelWithoutVariant.variantId, isNull);
      expect(modelWithoutVariant.variantName, isNull);
    });

    test('CategoryPerformanceModel and BrandPerformanceModel deserialize properly', () {
      final catJson = {
        'categoryId': 'cat-1',
        'categoryName': 'Apparel',
        'unitsSold': 120,
        'revenue': 250000.0,
      };
      final catModel = CategoryPerformanceModel.fromJson(catJson);
      expect(catModel.categoryName, 'Apparel');
      expect(catModel.unitsSold, 120);
      expect(catModel.revenue, 250000.0);

      final brandJson = {
        'brandId': 'brand-1',
        'brandName': 'Nike',
        'unitsSold': 85,
        'revenue': 180000.0,
      };
      final brandModel = BrandPerformanceModel.fromJson(brandJson);
      expect(brandModel.brandName, 'Nike');
      expect(brandModel.unitsSold, 85);
      expect(brandModel.revenue, 180000.0);
    });

    test('CustomerAnalyticsReportModel deserializes summary and topCustomers', () {
      final json = {
        'summary': {
          'totalCustomers': 500,
          'newCustomers': 150,
          'returningCustomers': 350,
          'repeatPurchaseRate': 70.0,
          'revenueFromNewCustomers': 200000.0,
          'revenueFromReturningCustomers': 800000.0,
        },
        'topCustomers': {
          'data': [
            {
              'customerId': 'cust-1',
              'displayName': 'Kaveri S',
              'orderCount': 12,
              'revenue': 45000.0,
              'lastOrderDate': '2026-01-20T14:30:00Z',
            }
          ],
          'pageNumber': 1,
          'pageSize': 20,
          'totalCount': 1,
          'totalPages': 1,
          'hasPreviousPage': false,
          'hasNextPage': false,
        }
      };

      final report = CustomerAnalyticsReportModel.fromJson(json);
      expect(report.summary.totalCustomers, 500);
      expect(report.summary.repeatPurchaseRate, 70.0);
      expect(report.topCustomers.data.length, 1);
      expect(report.topCustomers.data.first.displayName, 'Kaveri S');
      expect(report.topCustomers.data.first.orderCount, 12);
      expect(report.topCustomers.data.first.lastOrderDate, isNotNull);
    });

    test('InventoryReportModel deserializes stock KPIs and SKU breakdown', () {
      final json = {
        'totalInventoryValue': 1250000.0,
        'lowStockCount': 5,
        'outOfStockCount': 2,
        'totalUnits': 850,
        'items': {
          'data': [
            {
              'productId': 'prod-001',
              'variantId': 'var-001',
              'productName': 'Slim Fit Jeans - 32',
              'currentStock': 8,
              'reservedStock': 2,
              'availableStock': 6,
              'lowStockThreshold': 10,
              'unitPrice': 1999.0,
              'inventoryValue': 15992.0,
              'unitsSoldInPeriod': 24,
              'stockVelocity': 0.8,
            }
          ],
          'pageNumber': 1,
          'pageSize': 20,
          'totalCount': 1,
          'totalPages': 1,
          'hasPreviousPage': false,
          'hasNextPage': false,
        }
      };

      final report = InventoryReportModel.fromJson(json);
      expect(report.totalInventoryValue, 1250000.0);
      expect(report.lowStockCount, 5);
      expect(report.outOfStockCount, 2);
      expect(report.totalUnits, 850);
      expect(report.items.data.length, 1);
      final item = report.items.data.first;
      expect(item.productName, 'Slim Fit Jeans - 32');
      expect(item.currentStock, 8);
      expect(item.availableStock, 6);
      expect(item.stockVelocity, 0.8);
    });
  });
}

import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/sales_report_model.dart';
import '../models/product_performance_model.dart';
import '../models/category_performance_model.dart';
import '../models/brand_performance_model.dart';
import '../models/customer_analytics_model.dart';
import '../models/inventory_report_model.dart';
import '../models/paged_result_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<SalesReportModel> getSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  });

  Future<PagedResult<ProductPerformanceModel>> getProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  });

  Future<List<CategoryPerformanceModel>> getCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<List<BrandPerformanceModel>> getBrandPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<CustomerAnalyticsReportModel> getCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  });

  Future<InventoryReportModel> getInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  });

  Future<Uint8List> exportSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  });

  Future<Uint8List> exportProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    String? sortBy,
    String? sortDirection,
  });

  Future<Uint8List> exportCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<Uint8List> exportBrandPerformanceReport({
    required String startDate,
    required String endDate,
  });

  Future<Uint8List> exportCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    String? sortBy,
    String? sortDirection,
  });

  Future<Uint8List> exportInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    String? sortBy,
    String? sortDirection,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final Dio dio;

  AnalyticsRemoteDataSourceImpl({required this.dio});

  static const String basePath = '/api/v1/analytics/reports';

  @override
  Future<SalesReportModel> getSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  }) async {
    final queryParams = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      if (interval != null) 'interval': interval,
      if (status != null) 'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };

    final response = await dio.get(
      '$basePath/sales',
      queryParameters: queryParams,
    );
    return SalesReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PagedResult<ProductPerformanceModel>> getProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (brandId != null && brandId.isNotEmpty) 'brandId': brandId,
      'page': page,
      'pageSize': pageSize,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
    };

    final response = await dio.get(
      '$basePath/products',
      queryParameters: queryParams,
    );
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      (item) => ProductPerformanceModel.fromJson(item),
    );
  }

  @override
  Future<List<CategoryPerformanceModel>> getCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    final response = await dio.get(
      '$basePath/categories',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((item) =>
            CategoryPerformanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BrandPerformanceModel>> getBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    final response = await dio.get(
      '$basePath/brands',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((item) =>
            BrandPerformanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CustomerAnalyticsReportModel> getCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      'page': page,
      'pageSize': pageSize,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
    };

    final response = await dio.get(
      '$basePath/customers',
      queryParameters: queryParams,
    );
    return CustomerAnalyticsReportModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<InventoryReportModel> getInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      if (lowStockOnly) 'lowStockOnly': true,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      'page': page,
      'pageSize': pageSize,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
    };

    final response = await dio.get(
      '$basePath/inventory',
      queryParameters: queryParams,
    );
    return InventoryReportModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<Uint8List> exportSalesReport({
    required String startDate,
    required String endDate,
    int? interval,
    int? status,
    int? paymentMethod,
  }) async {
    final queryParams = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      if (interval != null) 'interval': interval,
      if (status != null) 'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };

    final response = await dio.get<List<int>>(
      '$basePath/sales/export',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  @override
  Future<Uint8List> exportProductPerformanceReport({
    required String startDate,
    required String endDate,
    String? categoryId,
    String? brandId,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (brandId != null && brandId.isNotEmpty) 'brandId': brandId,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
    };

    final response = await dio.get<List<int>>(
      '$basePath/products/export',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  @override
  Future<Uint8List> exportCategoryPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    final response = await dio.get<List<int>>(
      '$basePath/categories/export',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  @override
  Future<Uint8List> exportBrandPerformanceReport({
    required String startDate,
    required String endDate,
  }) async {
    final response = await dio.get<List<int>>(
      '$basePath/brands/export',
      queryParameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  @override
  Future<Uint8List> exportCustomerAnalyticsReport({
    required String startDate,
    required String endDate,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
    };

    final response = await dio.get<List<int>>(
      '$basePath/customers/export',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  @override
  Future<Uint8List> exportInventoryReport({
    bool lowStockOnly = false,
    String? categoryId,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      if (lowStockOnly) 'lowStockOnly': true,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortDirection != null && sortDirection.isNotEmpty)
        'sortDirection': sortDirection,
    };

    final response = await dio.get<List<int>>(
      '$basePath/inventory/export',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }
}

import 'package:dio/dio.dart';
import '../models/banner_model.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/paged_products_model.dart';
import '../models/product_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<BannerModel>> getBanners({bool includeInactive = false});
  Future<List<CategoryModel>> getCategories({bool includeInactive = false});
  Future<List<CategoryModel>> getCategoryTree({bool includeInactive = false});
  Future<List<BrandModel>> getBrands({bool includeInactive = false});
  Future<PagedProductsModel> getProducts({
    String? categoryId,
    String? brandId,
    String? search,
    String? sortBy,
    String? sortDirection,
    int page = 1,
    int pageSize = 20,
  });
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> getProductBySlug(String slug);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio _dio;

  CatalogRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<BannerModel>> getBanners({bool includeInactive = false}) async {
    final response = await _dio.get(
      '/api/v1/catalog/banners',
      queryParameters: {'includeInactive': includeInactive},
    );
    final data = response.data as List<dynamic>;
    return data.map((json) => BannerModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories({bool includeInactive = false}) async {
    final response = await _dio.get(
      '/api/v1/catalog/categories',
      queryParameters: {'includeInactive': includeInactive},
    );
    final data = response.data as List<dynamic>;
    return data.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategoryTree({bool includeInactive = false}) async {
    final response = await _dio.get(
      '/api/v1/catalog/categories/tree',
      queryParameters: {'includeInactive': includeInactive},
    );
    final data = response.data as List<dynamic>;
    return data.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<BrandModel>> getBrands({bool includeInactive = false}) async {
    final response = await _dio.get(
      '/api/v1/catalog/brands',
      queryParameters: {'includeInactive': includeInactive},
    );
    final data = response.data as List<dynamic>;
    return data.map((json) => BrandModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<PagedProductsModel> getProducts({
    String? categoryId,
    String? brandId,
    String? search,
    String? sortBy,
    String? sortDirection,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (brandId != null && brandId.isNotEmpty) {
      queryParams['brandId'] = brandId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (sortDirection != null && sortDirection.isNotEmpty) {
      queryParams['sortDirection'] = sortDirection;
    }

    final response = await _dio.get(
      '/api/v1/catalog/products',
      queryParameters: queryParams,
    );
    return PagedProductsModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await _dio.get('/api/v1/catalog/products/$id');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _dio.get('/api/v1/catalog/products/slug/$slug');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }
}

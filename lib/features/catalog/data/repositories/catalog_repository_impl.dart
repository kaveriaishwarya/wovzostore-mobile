import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_datasource.dart';
import '../models/banner_model.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/paged_products_model.dart';
import '../models/product_model.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remoteDataSource;

  CatalogRepositoryImpl({required CatalogRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<BannerModel>> getBanners() async {
    try {
      return await _remoteDataSource.getBanners();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      return await _remoteDataSource.getCategories();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategoryTree() async {
    try {
      return await _remoteDataSource.getCategoryTree();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      return await _remoteDataSource.getBrands();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
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
    try {
      return await _remoteDataSource.getProducts(
        categoryId: categoryId,
        brandId: brandId,
        search: search,
        sortBy: sortBy,
        sortDirection: sortDirection,
        page: page,
        pageSize: pageSize,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      return await _remoteDataSource.getProductById(id);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    try {
      return await _remoteDataSource.getProductBySlug(slug);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

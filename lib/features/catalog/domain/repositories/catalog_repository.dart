import '../../data/models/banner_model.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/paged_products_model.dart';
import '../../data/models/product_model.dart';

abstract class CatalogRepository {
  Future<List<BannerModel>> getBanners();
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoryTree();
  Future<List<BrandModel>> getBrands();
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

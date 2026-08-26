import 'package:equatable/equatable.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/category_model.dart';

enum CatalogStatus { initial, loading, success, error }

class CatalogState extends Equatable {
  final CatalogStatus status;
  final List<BannerModel> banners;
  final List<CategoryModel> categoryTree;
  final List<BrandModel> brands;
  final String? errorMessage;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.banners = const [],
    this.categoryTree = const [],
    this.brands = const [],
    this.errorMessage,
  });

  bool get isLoading => status == CatalogStatus.loading;
  bool get isSuccess => status == CatalogStatus.success;
  bool get isError => status == CatalogStatus.error;

  CatalogState copyWith({
    CatalogStatus? status,
    List<BannerModel>? banners,
    List<CategoryModel>? categoryTree,
    List<BrandModel>? brands,
    String? errorMessage,
  }) {
    return CatalogState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      categoryTree: categoryTree ?? this.categoryTree,
      brands: brands ?? this.brands,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, banners, categoryTree, brands, errorMessage];
}

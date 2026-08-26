import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

enum ProductListStatus { initial, loading, success, loadingMore, refreshing, error }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<ProductModel> products;
  final String? categoryId;
  final String? brandId;
  final String? search;
  final String? sortBy;
  final String? sortDirection;
  final int page;
  final int pageSize;
  final int totalCount;
  final String? errorMessage;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.categoryId,
    this.brandId,
    this.search,
    this.sortBy,
    this.sortDirection,
    this.page = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.errorMessage,
  });

  bool get hasMore => (page * pageSize) < totalCount;
  bool get isLoading => status == ProductListStatus.loading;
  bool get isLoadingMore => status == ProductListStatus.loadingMore;
  bool get isRefreshing => status == ProductListStatus.refreshing;
  bool get isSuccess => status == ProductListStatus.success;
  bool get isError => status == ProductListStatus.error;

  ProductListState copyWith({
    ProductListStatus? status,
    List<ProductModel>? products,
    String? categoryId,
    String? brandId,
    String? search,
    String? sortBy,
    String? sortDirection,
    int? page,
    int? pageSize,
    int? totalCount,
    String? errorMessage,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categoryId,
        brandId,
        search,
        sortBy,
        sortDirection,
        page,
        pageSize,
        totalCount,
        errorMessage,
      ];
}

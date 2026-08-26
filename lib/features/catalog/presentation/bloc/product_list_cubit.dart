import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/product_model.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  final CatalogRepository _repository;

  ProductListCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const ProductListState());

  Future<void> loadProducts({
    String? categoryId,
    String? brandId,
    String? search,
    String? sortBy,
    String? sortDirection,
    int? pageSize,
  }) async {
    final effectivePageSize = pageSize ?? state.pageSize;
    emit(state.copyWith(
      status: ProductListStatus.loading,
      categoryId: categoryId,
      brandId: brandId,
      search: search,
      sortBy: sortBy,
      sortDirection: sortDirection,
      pageSize: effectivePageSize,
      page: 1,
    ));

    try {
      final result = await _repository.getProducts(
        categoryId: categoryId ?? state.categoryId,
        brandId: brandId ?? state.brandId,
        search: search ?? state.search,
        sortBy: sortBy ?? state.sortBy,
        sortDirection: sortDirection ?? state.sortDirection,
        page: 1,
        pageSize: effectivePageSize,
      );

      emit(state.copyWith(
        status: ProductListStatus.success,
        products: result.items,
        totalCount: result.totalCount,
        page: 1,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(status: ProductListStatus.loadingMore));

    try {
      final result = await _repository.getProducts(
        categoryId: state.categoryId,
        brandId: state.brandId,
        search: state.search,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
        page: nextPage,
        pageSize: state.pageSize,
      );

      final updatedProducts = List<ProductModel>.from(state.products)
        ..addAll(result.items);

      emit(state.copyWith(
        status: ProductListStatus.success,
        products: updatedProducts,
        totalCount: result.totalCount,
        page: nextPage,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateFilters({
    String? categoryId,
    String? brandId,
    String? search,
  }) async {
    await loadProducts(
      categoryId: categoryId,
      brandId: brandId,
      search: search,
      sortBy: state.sortBy,
      sortDirection: state.sortDirection,
    );
  }

  Future<void> updateSort({
    String? sortBy,
    String? sortDirection,
  }) async {
    await loadProducts(
      categoryId: state.categoryId,
      brandId: state.brandId,
      search: state.search,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  Future<void> refresh() async {
    await loadProducts(
      categoryId: state.categoryId,
      brandId: state.brandId,
      search: state.search,
      sortBy: state.sortBy,
      sortDirection: state.sortDirection,
    );
  }
}

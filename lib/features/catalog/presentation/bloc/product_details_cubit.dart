import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final CatalogRepository _repository;
  String? _lastId;
  String? _lastSlug;

  ProductDetailsCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const ProductDetailsState());

  Future<void> loadProductById(String id) async {
    _lastId = id;
    _lastSlug = null;
    emit(state.copyWith(status: ProductDetailsStatus.loading));

    try {
      final product = await _repository.getProductById(id);
      emit(state.copyWith(
        status: ProductDetailsStatus.success,
        product: product,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProductDetailsStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductDetailsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadProductBySlug(String slug) async {
    _lastSlug = slug;
    _lastId = null;
    emit(state.copyWith(status: ProductDetailsStatus.loading));

    try {
      final product = await _repository.getProductBySlug(slug);
      emit(state.copyWith(
        status: ProductDetailsStatus.success,
        product: product,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProductDetailsStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductDetailsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() async {
    if (_lastId != null) {
      await loadProductById(_lastId!);
    } else if (_lastSlug != null) {
      await loadProductBySlug(_lastSlug!);
    }
  }
}

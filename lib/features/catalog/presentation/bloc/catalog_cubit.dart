import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final CatalogRepository _repository;

  CatalogCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const CatalogState());

  Future<void> loadCatalog() async {
    emit(state.copyWith(status: CatalogStatus.loading));

    try {
      final banners = await _repository.getBanners();
      final categoryTree = await _repository.getCategoryTree();
      final brands = await _repository.getBrands();

      emit(state.copyWith(
        status: CatalogStatus.success,
        banners: banners,
        categoryTree: categoryTree,
        brands: brands,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CatalogStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() async {
    await loadCatalog();
  }
}

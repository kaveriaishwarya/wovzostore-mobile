import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/create_product_request_model.dart';
import '../../data/models/update_product_request_model.dart';
import '../../domain/repositories/merchant_product_repository.dart';
import 'merchant_product_form_state.dart';

class MerchantProductFormCubit extends Cubit<MerchantProductFormState> {
  final MerchantProductRepository _repository;

  MerchantProductFormCubit({required MerchantProductRepository repository})
      : _repository = repository,
        super(const MerchantProductFormState());

  Future<void> createProduct(CreateProductRequestModel request) async {
    emit(state.copyWith(status: MerchantProductFormStatus.submitting));
    try {
      final product = await _repository.createProduct(request);
      emit(state.copyWith(
        status: MerchantProductFormStatus.success,
        product: product,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantProductFormStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> updateProduct(String id, UpdateProductRequestModel request) async {
    emit(state.copyWith(status: MerchantProductFormStatus.submitting));
    try {
      final product = await _repository.updateProduct(id, request);
      emit(state.copyWith(
        status: MerchantProductFormStatus.success,
        product: product,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantProductFormStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> publishProduct(String id) async {
    emit(state.copyWith(status: MerchantProductFormStatus.submitting));
    try {
      await _repository.publishProduct(id);
      emit(state.copyWith(status: MerchantProductFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantProductFormStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> unpublishProduct(String id) async {
    emit(state.copyWith(status: MerchantProductFormStatus.submitting));
    try {
      await _repository.unpublishProduct(id);
      emit(state.copyWith(status: MerchantProductFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantProductFormStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> archiveProduct(String id) async {
    emit(state.copyWith(status: MerchantProductFormStatus.submitting));
    try {
      await _repository.archiveProduct(id);
      emit(state.copyWith(status: MerchantProductFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantProductFormStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> addVariant(String productId, AddVariantRequestModel request) async {
    emit(state.copyWith(status: MerchantProductFormStatus.submitting));
    try {
      await _repository.addVariant(productId, request);
      emit(state.copyWith(status: MerchantProductFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantProductFormStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

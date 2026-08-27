import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/merchant_order_repository.dart';
import '../../data/models/order_model.dart';
import 'merchant_order_detail_state.dart';

class MerchantOrderDetailCubit extends Cubit<MerchantOrderDetailState> {
  final MerchantOrderRepository _repository;

  MerchantOrderDetailCubit({required MerchantOrderRepository repository})
      : _repository = repository,
        super(const MerchantOrderDetailState());

  Future<void> loadOrder(String orderId) async {
    emit(state.copyWith(status: MerchantOrderDetailStatus.loading));
    try {
      final order = await _repository.getOrderById(orderId);
      emit(state.copyWith(
        status: MerchantOrderDetailStatus.success,
        order: order,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantOrderDetailStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantOrderDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _executeTransition(Future<OrderModel> Function() call) async {
    emit(state.copyWith(status: MerchantOrderDetailStatus.updating));
    try {
      final updatedOrder = await call();
      emit(state.copyWith(
        status: MerchantOrderDetailStatus.success,
        order: updatedOrder,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MerchantOrderDetailStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MerchantOrderDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> confirmOrder(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.confirmOrder(orderId, comment: comment, adminId: adminId));
  }

  Future<void> startProcessingOrder(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.startProcessingOrder(orderId, comment: comment, adminId: adminId));
  }

  Future<void> packOrder(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.packOrder(orderId, comment: comment, adminId: adminId));
  }

  Future<void> shipOrder(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.shipOrder(orderId, comment: comment, adminId: adminId));
  }

  Future<void> markOutForDelivery(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.markOutForDelivery(orderId, comment: comment, adminId: adminId));
  }

  Future<void> deliverOrder(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.deliverOrder(orderId, comment: comment, adminId: adminId));
  }

  Future<void> cancelOrder(String orderId, String reason) {
    return _executeTransition(() => _repository.cancelOrder(orderId, reason));
  }

  Future<void> approveReturn(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.approveReturn(orderId, comment: comment, adminId: adminId));
  }

  Future<void> completeReturn(String orderId, {String? comment, String? adminId}) {
    return _executeTransition(() => _repository.completeReturn(orderId, comment: comment, adminId: adminId));
  }
}

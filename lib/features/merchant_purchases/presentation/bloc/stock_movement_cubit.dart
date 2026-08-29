import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/stock_movement_model.dart';
import '../../domain/repositories/merchant_purchases_repository.dart';
import 'stock_movement_state.dart';

class StockMovementCubit extends Cubit<StockMovementState> {
  final MerchantPurchasesRepository repository;

  StockMovementCubit({required this.repository})
      : super(const StockMovementInitial());

  Future<void> loadStockMovements({
    String? variantId,
    StockMovementType? movementType,
    bool refresh = false,
  }) async {
    try {
      if (refresh || state is! StockMovementLoaded) {
        emit(const StockMovementLoading());
      }

      final result = await repository.getStockMovements(
        variantId: variantId,
        movementType: movementType?.value,
        page: 1,
        pageSize: 20,
      );

      emit(StockMovementLoaded(
        movements: result.data,
        totalCount: result.totalCount,
        page: 1,
        hasMore: result.hasNextPage,
        variantIdFilter: variantId,
        movementTypeFilter: movementType,
      ));
    } on ApiException catch (e) {
      emit(StockMovementError(message: e.message));
    } catch (e) {
      emit(StockMovementError(message: e.toString()));
    }
  }

  Future<void> loadMoreStockMovements() async {
    final currentState = state;
    if (currentState is! StockMovementLoaded || !currentState.hasMore) {
      return;
    }

    try {
      final nextPage = currentState.page + 1;
      final result = await repository.getStockMovements(
        variantId: currentState.variantIdFilter,
        movementType: currentState.movementTypeFilter?.value,
        page: nextPage,
        pageSize: 20,
      );

      final updatedMovements = [...currentState.movements, ...result.data];

      emit(currentState.copyWith(
        movements: updatedMovements,
        totalCount: result.totalCount,
        page: nextPage,
        hasMore: result.hasNextPage,
      ));
    } catch (_) {
      // Keep current state on loadMore failure
    }
  }

  Future<void> lookupBarcode(String barcode) async {
    final currentState = state;
    if (currentState is StockMovementLoaded) {
      emit(currentState.copyWith(
        isScanning: true,
        clearScanError: true,
        clearScannedVariant: true,
      ));
    }

    try {
      final variant = await repository.getVariantByBarcode(barcode);
      if (currentState is StockMovementLoaded) {
        emit(currentState.copyWith(
          scannedVariant: variant,
          isScanning: false,
        ));
      } else {
        emit(StockMovementLoaded(
          movements: const [],
          totalCount: 0,
          page: 1,
          hasMore: false,
          scannedVariant: variant,
        ));
      }
    } on ApiException catch (e) {
      if (currentState is StockMovementLoaded) {
        emit(currentState.copyWith(
          isScanning: false,
          scanError: e.message,
        ));
      } else {
        emit(StockMovementError(message: e.message));
      }
    } catch (e) {
      if (currentState is StockMovementLoaded) {
        emit(currentState.copyWith(
          isScanning: false,
          scanError: e.toString(),
        ));
      } else {
        emit(StockMovementError(message: e.toString()));
      }
    }
  }
}

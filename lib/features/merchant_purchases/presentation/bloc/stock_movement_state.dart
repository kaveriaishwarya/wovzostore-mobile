import 'package:equatable/equatable.dart';
import '../../../../features/catalog/data/models/product_variant_model.dart';
import '../../data/models/stock_movement_model.dart';

abstract class StockMovementState extends Equatable {
  const StockMovementState();

  @override
  List<Object?> get props => [];
}

class StockMovementInitial extends StockMovementState {
  const StockMovementInitial();
}

class StockMovementLoading extends StockMovementState {
  const StockMovementLoading();
}

class StockMovementLoaded extends StockMovementState {
  final List<StockMovementModel> movements;
  final int totalCount;
  final int page;
  final bool hasMore;
  final String? variantIdFilter;
  final StockMovementType? movementTypeFilter;
  final ProductVariantModel? scannedVariant;
  final bool isScanning;
  final String? scanError;

  const StockMovementLoaded({
    required this.movements,
    required this.totalCount,
    required this.page,
    required this.hasMore,
    this.variantIdFilter,
    this.movementTypeFilter,
    this.scannedVariant,
    this.isScanning = false,
    this.scanError,
  });

  StockMovementLoaded copyWith({
    List<StockMovementModel>? movements,
    int? totalCount,
    int? page,
    bool? hasMore,
    String? variantIdFilter,
    bool clearVariantFilter = false,
    StockMovementType? movementTypeFilter,
    bool clearTypeFilter = false,
    ProductVariantModel? scannedVariant,
    bool clearScannedVariant = false,
    bool? isScanning,
    String? scanError,
    bool clearScanError = false,
  }) {
    return StockMovementLoaded(
      movements: movements ?? this.movements,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      variantIdFilter: clearVariantFilter
          ? null
          : (variantIdFilter ?? this.variantIdFilter),
      movementTypeFilter: clearTypeFilter
          ? null
          : (movementTypeFilter ?? this.movementTypeFilter),
      scannedVariant: clearScannedVariant
          ? null
          : (scannedVariant ?? this.scannedVariant),
      isScanning: isScanning ?? this.isScanning,
      scanError: clearScanError ? null : (scanError ?? this.scanError),
    );
  }

  @override
  List<Object?> get props => [
        movements,
        totalCount,
        page,
        hasMore,
        variantIdFilter,
        movementTypeFilter,
        scannedVariant,
        isScanning,
        scanError,
      ];
}

class StockMovementError extends StockMovementState {
  final String message;

  const StockMovementError({required this.message});

  @override
  List<Object?> get props => [message];
}

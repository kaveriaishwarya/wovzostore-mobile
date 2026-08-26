import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

enum ProductDetailsStatus { initial, loading, success, error }

class ProductDetailsState extends Equatable {
  final ProductDetailsStatus status;
  final ProductModel? product;
  final String? errorMessage;

  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.errorMessage,
  });

  bool get isLoading => status == ProductDetailsStatus.loading;
  bool get isSuccess => status == ProductDetailsStatus.success;
  bool get isError => status == ProductDetailsStatus.error;

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    ProductModel? product,
    String? errorMessage,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, product, errorMessage];
}

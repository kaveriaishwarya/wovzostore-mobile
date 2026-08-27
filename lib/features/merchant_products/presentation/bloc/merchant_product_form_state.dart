import 'package:equatable/equatable.dart';
import '../../../catalog/data/models/product_model.dart';

enum MerchantProductFormStatus { initial, loading, submitting, success, error }

class MerchantProductFormState extends Equatable {
  final MerchantProductFormStatus status;
  final ProductModel? product;
  final String? errorMessage;

  const MerchantProductFormState({
    this.status = MerchantProductFormStatus.initial,
    this.product,
    this.errorMessage,
  });

  bool get isLoading => status == MerchantProductFormStatus.loading;
  bool get isSubmitting => status == MerchantProductFormStatus.submitting;
  bool get isSuccess => status == MerchantProductFormStatus.success;
  bool get isError => status == MerchantProductFormStatus.error;

  MerchantProductFormState copyWith({
    MerchantProductFormStatus? status,
    ProductModel? product,
    String? errorMessage,
  }) {
    return MerchantProductFormState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, product, errorMessage];
}

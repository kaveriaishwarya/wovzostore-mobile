import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../data/models/pos_cart_item_model.dart';
import '../../data/models/pos_customer_model.dart';
import '../../data/models/pos_sale_result_model.dart';

enum PosStatus { initial, loadingProducts, success, submitting, saleCompleted, error }

class PosState extends Equatable {
  final PosStatus status;
  final List<ProductModel> searchResults;
  final List<PosCartItemModel> cartItems;
  final PosCustomerModel selectedCustomer;
  final int selectedPaymentMethod;
  final String selectedPaymentMethodName;
  final PosSaleResultModel? completedSale;
  final String? errorMessage;
  final bool isInvoiceLoading;
  final Uint8List? invoiceBytes;
  final String? invoiceError;

  const PosState({
    this.status = PosStatus.initial,
    this.searchResults = const [],
    this.cartItems = const [],
    this.selectedCustomer = PosCustomerModel.walkIn,
    this.selectedPaymentMethod = 1,
    this.selectedPaymentMethodName = 'Cash',
    this.completedSale,
    this.errorMessage,
    this.isInvoiceLoading = false,
    this.invoiceBytes,
    this.invoiceError,
  });

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get taxAmount => 0.0;
  double get grandTotal => subtotal + taxAmount;
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get isLoading => status == PosStatus.loadingProducts;
  bool get isSubmitting => status == PosStatus.submitting;
  bool get isSaleCompleted => status == PosStatus.saleCompleted;
  bool get isError => status == PosStatus.error;

  PosState copyWith({
    PosStatus? status,
    List<ProductModel>? searchResults,
    List<PosCartItemModel>? cartItems,
    PosCustomerModel? selectedCustomer,
    int? selectedPaymentMethod,
    String? selectedPaymentMethodName,
    PosSaleResultModel? completedSale,
    bool clearCompletedSale = false,
    String? errorMessage,
    bool? isInvoiceLoading,
    Uint8List? invoiceBytes,
    bool clearInvoiceBytes = false,
    String? invoiceError,
  }) {
    return PosState(
      status: status ?? this.status,
      searchResults: searchResults ?? this.searchResults,
      cartItems: cartItems ?? this.cartItems,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedPaymentMethodName: selectedPaymentMethodName ?? this.selectedPaymentMethodName,
      completedSale: clearCompletedSale ? null : (completedSale ?? this.completedSale),
      errorMessage: errorMessage,
      isInvoiceLoading: isInvoiceLoading ?? this.isInvoiceLoading,
      invoiceBytes: clearInvoiceBytes ? null : (invoiceBytes ?? this.invoiceBytes),
      invoiceError: invoiceError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        searchResults,
        cartItems,
        selectedCustomer,
        selectedPaymentMethod,
        selectedPaymentMethodName,
        completedSale,
        errorMessage,
        isInvoiceLoading,
        invoiceBytes,
        invoiceError,
      ];
}

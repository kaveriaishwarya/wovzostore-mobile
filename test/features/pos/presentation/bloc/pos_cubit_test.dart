import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_cart_item_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_customer_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_sale_result_model.dart';
import 'package:wovzo_mobile/features/pos/domain/repositories/pos_repository.dart';
import 'package:wovzo_mobile/features/pos/presentation/bloc/pos_cubit.dart';
import 'package:wovzo_mobile/features/pos/presentation/bloc/pos_state.dart';

class MockPosRepository implements PosRepository {
  bool shouldFail = false;

  final sampleProduct = const ProductModel(
    id: 'prod-1',
    name: 'Cotton T-Shirt',
    slug: 'cotton-tshirt',
    categoryId: 'cat-1',
    status: 1,
    basePrice: 499.0,
    isActive: true,
    isFeatured: false,
    variants: [
      ProductVariantModel(
        id: 'var-1',
        productId: 'prod-1',
        sku: 'TSHIRT-BLK-M',
        name: 'Black M',
        price: 499.0,
        isActive: true,
        stockQuantity: 10,
      ),
    ],
  );

  @override
  Future<PagedResult<ProductModel>> searchProducts(String query, {int page = 1, int pageSize = 20}) async {
    return PagedResult<ProductModel>(
      data: [sampleProduct],
      pageNumber: page,
      pageSize: pageSize,
      totalCount: 1,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<List<PosCustomerModel>> getCustomers(String query) async {
    return const [
      PosCustomerModel.walkIn,
      PosCustomerModel(id: 'cust-1', fullName: 'Alice Smith', phoneNumber: '9876543210'),
    ];
  }

  @override
  Future<PosSaleResultModel> processPosSale({
    required PosCustomerModel customer,
    required List<PosCartItemModel> items,
    required int paymentMethod,
    required String paymentMethodName,
  }) async {
    return PosSaleResultModel(
      orderId: 'ord-100',
      orderNumber: 'WVZ-POS-001',
      grandTotal: items.fold(0.0, (sum, i) => sum + i.lineTotal),
      paymentMethod: paymentMethod,
      paymentMethodName: paymentMethodName,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  group('PosCubit Tests', () {
    late MockPosRepository repository;
    late PosCubit cubit;

    setUp(() {
      repository = MockPosRepository();
      cubit = PosCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is PosStatus.initial', () {
      expect(cubit.state.status, PosStatus.initial);
      expect(cubit.state.cartItems, isEmpty);
      expect(cubit.state.grandTotal, 0.0);
    });

    test('addItemFromProduct adds item and calculates totals correctly', () {
      cubit.addItemFromProduct(repository.sampleProduct);

      expect(cubit.state.cartItems.length, 1);
      expect(cubit.state.subtotal, 499.0);
      expect(cubit.state.grandTotal, 499.0);

      cubit.updateQuantity('var-1', 3);
      expect(cubit.state.subtotal, 1497.0);

      cubit.removeItem('var-1');
      expect(cubit.state.cartItems, isEmpty);
      expect(cubit.state.grandTotal, 0.0);
    });

    test('selectCustomer and searchCustomers work properly', () async {
      final customers = await cubit.searchCustomers('Alice');
      expect(customers.length, 2);

      cubit.selectCustomer(customers.last);
      expect(cubit.state.selectedCustomer.fullName, 'Alice Smith');
    });

    test('clearCart resets cart items and selected customer', () {
      cubit.addItemFromProduct(repository.sampleProduct);
      cubit.selectCustomer(const PosCustomerModel(id: 'c-1', fullName: 'John', phoneNumber: '123'));
      expect(cubit.state.cartItems.length, 1);

      cubit.clearCart();
      expect(cubit.state.cartItems, isEmpty);
      expect(cubit.state.selectedCustomer, PosCustomerModel.walkIn);
    });

    test('completeSale processes sale and resets cart state', () async {
      cubit.addItemFromProduct(repository.sampleProduct);
      await cubit.completeSale();

      expect(cubit.state.status, PosStatus.saleCompleted);
      expect(cubit.state.completedSale?.orderId, 'ord-100');
      expect(cubit.state.cartItems, isEmpty);
    });
  });
}

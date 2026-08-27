import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:wovzo_mobile/features/analytics/data/models/paged_result_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_cart_item_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_customer_model.dart';
import 'package:wovzo_mobile/features/pos/data/models/pos_sale_result_model.dart';
import 'package:wovzo_mobile/features/pos/domain/repositories/pos_repository.dart';
import 'package:wovzo_mobile/features/pos/presentation/bloc/pos_cubit.dart';
import 'package:wovzo_mobile/features/pos/presentation/screens/pos_screen.dart';

class MockUIPosRepository implements PosRepository {
  final sampleProduct = const ProductModel(
    id: 'prod-1',
    name: 'Denim Jacket',
    slug: 'denim-jacket',
    categoryId: 'cat-1',
    status: 1,
    basePrice: 1299.0,
    isActive: true,
    isFeatured: false,
    variants: [
      ProductVariantModel(
        id: 'var-1',
        productId: 'prod-1',
        sku: 'JKT-BLU-L',
        name: 'Blue L',
        price: 1299.0,
        isActive: true,
        stockQuantity: 5,
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
      PosCustomerModel(id: 'cust-1', fullName: 'Bob Builder', phoneNumber: '1234567890'),
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
      orderId: 'ord-555',
      orderNumber: 'WVZ-POS-055',
      grandTotal: items.fold(0.0, (sum, i) => sum + i.lineTotal),
      paymentMethod: paymentMethod,
      paymentMethodName: paymentMethodName,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  final sl = GetIt.instance;
  late MockUIPosRepository repository;
  late PosCubit cubit;

  setUp(() {
    sl.reset();
    repository = MockUIPosRepository();
    cubit = PosCubit(repository: repository);

    sl.registerLazySingleton<PosRepository>(() => repository);
    sl.registerFactory<PosCubit>(() => cubit);
  });

  tearDown(() {
    sl.reset();
  });

  group('PosScreen Widget Tests', () {
    testWidgets('PosScreen renders catalog search, cart panel, and payment options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('POS Terminal & Billing'), findsOneWidget);
      expect(find.text('Denim Jacket'), findsOneWidget);
      expect(find.text('Walk-In Customer'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Complete Sale (₹0.00)'), findsOneWidget);
    });

    testWidgets('Adding product builds cart and updates grand total button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Complete Sale (₹1299.00)'), findsOneWidget);
    });

    testWidgets('Customer picker opens and allows customer selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      expect(find.text('Select Customer'), findsOneWidget);
    });

    testWidgets('Complete sale opens confirmation modal then completes sale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete Sale (₹1299.00)'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Sale'), findsOneWidget);

      await tester.tap(find.text('Confirm & Pay'));
      await tester.pumpAndSettle();

      expect(find.text('Sale Completed!'), findsOneWidget);
      expect(find.text('Order #: WVZ-POS-055'), findsOneWidget);
    });
  });
}

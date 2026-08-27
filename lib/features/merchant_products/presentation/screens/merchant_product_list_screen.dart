import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../catalog/presentation/bloc/product_list_cubit.dart';
import '../../../catalog/presentation/bloc/product_list_state.dart';
import '../bloc/merchant_product_form_cubit.dart';
import '../bloc/merchant_stock_cubit.dart';
import '../widgets/stock_adjustment_dialog.dart';

class MerchantProductListScreen extends StatelessWidget {
  final ProductListCubit? productListCubit;
  final VoidCallback? onAddProductTap;
  final Function(String productId)? onEditProductTap;

  const MerchantProductListScreen({
    super.key,
    this.productListCubit,
    this.onAddProductTap,
    this.onEditProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeProductListCubit = productListCubit ?? sl<ProductListCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductListCubit>.value(
          value: activeProductListCubit..loadProducts(),
        ),
        BlocProvider<MerchantProductFormCubit>(
          create: (_) => sl<MerchantProductFormCubit>(),
        ),
        BlocProvider<MerchantStockCubit>(
          create: (_) => sl<MerchantStockCubit>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products & Stock Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAddProductTap,
              tooltip: 'Add Product',
            ),
          ],
        ),
        body: BlocBuilder<ProductListCubit, ProductListState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage ?? 'Failed to load products'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<ProductListCubit>().loadProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final products = state.products;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search products by name or SKU...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      context.read<ProductListCubit>().updateFilters(search: query);
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<ProductListCubit>().loadProducts(),
                    child: products.isEmpty
                        ? const Center(child: Text('No products found.'))
                        : ListView.builder(
                            itemCount: products.length,
                            padding: const EdgeInsets.all(12.0),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.name,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              product.isActive ? 'Active' : 'Inactive',
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                            backgroundColor: product.isActive ? Colors.green.shade100 : Colors.grey.shade200,
                                          ),
                                        ],
                                      ),
                                      Text('Base Price: ₹${product.basePrice.toStringAsFixed(2)}'),
                                      const SizedBox(height: 8),
                                      if (product.variants.isNotEmpty) ...[
                                        const Text('Variants:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ...product.variants.map((variant) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${variant.name} (${variant.sku}) - ₹${variant.price}'),
                                                IconButton(
                                                  icon: const Icon(Icons.edit_note, size: 20),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => StockAdjustmentDialog(
                                                        variantId: variant.id,
                                                        variantName: variant.name,
                                                        currentQuantity: 0,
                                                        cubit: context.read<MerchantStockCubit>(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.edit, size: 16),
                                            label: const Text('Edit'),
                                            onPressed: () => onEditProductTap?.call(product.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onAddProductTap,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

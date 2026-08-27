import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../catalog/data/models/category_model.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../catalog/presentation/bloc/product_list_cubit.dart';
import '../../../catalog/presentation/bloc/product_list_state.dart';
import '../bloc/merchant_product_form_cubit.dart';
import '../bloc/merchant_stock_cubit.dart';
import '../widgets/stock_adjustment_dialog.dart';

class MerchantProductListScreen extends StatefulWidget {
  final ProductListCubit? productListCubit;
  final CatalogRepository? catalogRepository;
  final VoidCallback? onAddProductTap;
  final Function(String productId)? onEditProductTap;

  const MerchantProductListScreen({
    super.key,
    this.productListCubit,
    this.catalogRepository,
    this.onAddProductTap,
    this.onEditProductTap,
  });

  @override
  State<MerchantProductListScreen> createState() => _MerchantProductListScreenState();
}

class _MerchantProductListScreenState extends State<MerchantProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final repo = widget.catalogRepository ?? sl<CatalogRepository>();
    try {
      final categories = await repo.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (_) {}
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductListCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProductListCubit = widget.productListCubit ?? sl<ProductListCubit>();

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
              onPressed: widget.onAddProductTap,
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
                if (_categories.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: _categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedCategoryId == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: const Text('All Categories'),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() => _selectedCategoryId = null);
                                context.read<ProductListCubit>().updateFilters(categoryId: null);
                              },
                            ),
                          );
                        }
                        final cat = _categories[index - 1];
                        final isSelected = _selectedCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedCategoryId = cat.id);
                              context.read<ProductListCubit>().updateFilters(categoryId: cat.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<ProductListCubit>().loadProducts(),
                    child: products.isEmpty
                        ? const Center(child: Text('No products found.'))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: products.length + (state.isLoadingMore ? 1 : 0),
                            padding: const EdgeInsets.all(12.0),
                            itemBuilder: (context, index) {
                              if (index == products.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

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
                                        const Text('Variants & Stock:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ...product.variants.map((variant) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text('${variant.name} (${variant.sku}) - ₹${variant.price}'),
                                                ),
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
                                            onPressed: () => widget.onEditProductTap?.call(product.id),
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
          onPressed: widget.onAddProductTap,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

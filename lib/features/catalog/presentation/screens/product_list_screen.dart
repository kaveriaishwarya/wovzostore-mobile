import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_list_cubit.dart';
import '../bloc/product_list_state.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? searchQuery;
  final void Function(String productId)? onProductTap;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.searchQuery,
    this.onProductTap,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
    _scrollController.addListener(_onScroll);
    context.read<ProductListCubit>().loadProducts(
          categoryId: widget.categoryId,
          brandId: widget.brandId,
          search: widget.searchQuery,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductListCubit>().loadNextPage();
    }
  }

  void _onSearchSubmitted(String query) {
    context.read<ProductListCubit>().updateFilters(search: query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.categoryName ?? 'Products';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              switch (value) {
                case 'price_asc':
                  context.read<ProductListCubit>().updateSort(sortBy: 'price', sortDirection: 'asc');
                  break;
                case 'price_desc':
                  context.read<ProductListCubit>().updateSort(sortBy: 'price', sortDirection: 'desc');
                  break;
                case 'name_asc':
                  context.read<ProductListCubit>().updateSort(sortBy: 'name', sortDirection: 'asc');
                  break;
                case 'created_desc':
                  context.read<ProductListCubit>().updateSort(sortBy: 'createdAt', sortDirection: 'desc');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
              const PopupMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
              const PopupMenuItem(value: 'name_asc', child: Text('Name: A-Z')),
              const PopupMenuItem(value: 'created_desc', child: Text('Newest Arrivals')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmitted('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),

          // Product Grid
          Expanded(
            child: BlocBuilder<ProductListCubit, ProductListState>(
              builder: (context, state) {
                if (state.isLoading && state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.isError && state.products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(state.errorMessage ?? 'Failed to load products'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<ProductListCubit>().refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.products.isEmpty) {
                  return const Center(
                    child: Text('No products found matching your criteria.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<ProductListCubit>().refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => widget.onProductTap?.call(product.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

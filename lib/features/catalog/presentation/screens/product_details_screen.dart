import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_details_cubit.dart';
import '../bloc/product_details_state.dart';
import '../../data/models/product_variant_model.dart';
import '../widgets/variant_selector.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  final String? productSlug;

  const ProductDetailsScreen({
    super.key,
    this.productId,
    this.productSlug,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductVariantModel? _selectedVariant;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProductDetailsCubit>();
    if (widget.productId != null) {
      cubit.loadProductById(widget.productId!);
    } else if (widget.productSlug != null) {
      cubit.loadProductBySlug(widget.productSlug!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
        listener: (context, state) {
          if (state.isSuccess && state.product != null && state.product!.variants.isNotEmpty) {
            if (_selectedVariant == null) {
              setState(() {
                _selectedVariant = state.product!.variants.firstWhere(
                  (v) => v.isActive && v.stockQuantity > 0,
                  orElse: () => state.product!.variants.first,
                );
              });
            }
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isError || state.product == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(state.errorMessage ?? 'Product details not found.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProductDetailsCubit>().refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final product = state.product!;
          final displayPrice = _selectedVariant?.price ?? product.basePrice;
          final primaryImg = product.primaryImage?.imageUrl ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade100,
                    image: primaryImg.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(primaryImg),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: primaryImg.isEmpty
                      ? Center(
                          child: Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade400),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // Brand Tag
                if (product.brand != null && product.brand!.isNotEmpty) ...[
                  Text(
                    product.brand!.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Title
                Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  '₹${displayPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Variants Selector
                if (product.variants.isNotEmpty) ...[
                  VariantSelector(
                    variants: product.variants,
                    selectedVariant: _selectedVariant,
                    onVariantSelected: (variant) {
                      setState(() {
                        _selectedVariant = variant;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Short Description / Description
                if (product.shortDescription != null && product.shortDescription!.isNotEmpty) ...[
                  Text(
                    product.shortDescription!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (product.description != null && product.description!.isNotEmpty) ...[
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                // Add to Cart (Placeholder button for Phase 7.0.10.5)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cart functionality will be enabled in Phase 7.0.10.5'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

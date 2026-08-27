import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/pos_cubit.dart';
import '../bloc/pos_state.dart';
import '../../data/models/pos_customer_model.dart';

class PosScreen extends StatefulWidget {
  final PosCubit? cubit;

  const PosScreen({
    super.key,
    this.cubit,
  });

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showReceiptDialog(BuildContext context, state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Sale Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #: ${state.completedSale?.orderNumber ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Total Paid: ₹${state.completedSale?.grandTotal.toStringAsFixed(2) ?? '0.00'}'),
            Text('Payment Method: ${state.completedSale?.paymentMethodName ?? 'Cash'}'),
            Text('Customer: ${state.selectedCustomer.fullName}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PosCubit>().clearCart();
            },
            child: const Text('New Sale'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = widget.cubit ?? sl<PosCubit>();

    return BlocProvider<PosCubit>.value(
      value: activeCubit..searchProducts(''),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('POS Terminal & Billing'),
        ),
        body: BlocConsumer<PosCubit, PosState>(
          listener: (context, state) {
            if (state.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Error processing sale')),
              );
            } else if (state.isSaleCompleted && state.completedSale != null) {
              _showReceiptDialog(context, state);
            }
          },
          builder: (context, state) {
            return Row(
              children: [
                // Left Panel: Catalog Product Search & Selection
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search product or SKU...',
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<PosCubit>().searchProducts('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (query) {
                            context.read<PosCubit>().searchProducts(query);
                          },
                        ),
                      ),
                      Expanded(
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : state.searchResults.isEmpty
                                ? const Center(child: Text('No products found.'))
                                : ListView.builder(
                                    itemCount: state.searchResults.length,
                                    padding: const EdgeInsets.all(12.0),
                                    itemBuilder: (context, index) {
                                      final product = state.searchResults[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(product.name),
                                          subtitle: Text('Base Price: ₹${product.basePrice.toStringAsFixed(2)} | Variants: ${product.variants.length}'),
                                          trailing: ElevatedButton.icon(
                                            onPressed: () => context.read<PosCubit>().addItemFromProduct(product),
                                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                                            label: const Text('Add'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // Right Panel: Active POS Cart & Bill Summary
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Bar
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.selectedCustomer.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Walk-In'),
                              selected: state.selectedCustomer == PosCustomerModel.walkIn,
                              onSelected: (_) => context.read<PosCubit>().selectCustomer(PosCustomerModel.walkIn),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text('Current Bill (${state.itemCount} items)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: state.cartItems.isEmpty
                              ? const Center(child: Text('Cart is empty. Select products to build bill.'))
                              : ListView.builder(
                                  itemCount: state.cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = state.cartItems[index];
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Text('₹${item.unitPrice.toStringAsFixed(2)} x ${item.quantity} = ₹${item.lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                                              onPressed: () => context.read<PosCubit>().updateQuantity(item.productVariantId, item.quantity - 1),
                                            ),
                                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, size: 20),
                                              onPressed: () => context.read<PosCubit>().updateQuantity(item.productVariantId, item.quantity + 1),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              onPressed: () => context.read<PosCubit>().removeItem(item.productVariantId),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const Divider(),
                        // Totals & Payment Select
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text('₹${state.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold)),
                            Flexible(
                              child: Text(
                                '₹${state.grandTotal.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Payment Method:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            ChoiceChip(
                              label: const Text('Cash'),
                              selected: state.selectedPaymentMethod == 1,
                              onSelected: (_) => context.read<PosCubit>().selectPaymentMethod(1, 'Cash'),
                            ),
                            ChoiceChip(
                              label: const Text('UPI'),
                              selected: state.selectedPaymentMethod == 2,
                              onSelected: (_) => context.read<PosCubit>().selectPaymentMethod(2, 'UPI'),
                            ),
                            ChoiceChip(
                              label: const Text('Card'),
                              selected: state.selectedPaymentMethod == 3,
                              onSelected: (_) => context.read<PosCubit>().selectPaymentMethod(3, 'Card'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (state.cartItems.isEmpty || state.isSubmitting)
                                ? null
                                : () => context.read<PosCubit>().completeSale(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: state.isSubmitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.point_of_sale),
                            label: Text(state.isSubmitting ? 'Processing Sale...' : 'Complete Sale (₹${state.grandTotal.toStringAsFixed(2)})'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

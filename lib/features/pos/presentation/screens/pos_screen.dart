import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../catalog/data/models/product_model.dart';
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

  void _showVariantSelector(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Variant for ${product.name}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: product.variants.length,
                itemBuilder: (context, index) {
                  final variant = product.variants[index];
                  return ListTile(
                    title: Text(variant.name),
                    subtitle: Text('SKU: ${variant.sku} | Stock: ${variant.stockQuantity}'),
                    trailing: Text('₹${variant.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      context.read<PosCubit>().addItemFromProduct(product, variant: variant);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final searchCtrl = TextEditingController();
        List<PosCustomerModel> customers = [PosCustomerModel.walkIn];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Select Customer'),
              content: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search customer by name or phone...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) async {
                        final cubit = context.read<PosCubit>();
                        final results = await cubit.searchCustomers(val);
                        setStateDialog(() {
                          customers = [PosCustomerModel.walkIn, ...results];
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final c = customers[index];
                          return ListTile(
                            leading: Icon(c.id == PosCustomerModel.walkIn.id ? Icons.directions_walk : Icons.person),
                            title: Text(c.fullName),
                            subtitle: Text(c.phoneNumber.isEmpty ? 'Default Walk-In' : c.phoneNumber),
                            onTap: () {
                              context.read<PosCubit>().selectCustomer(c);
                              Navigator.of(dialogContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentConfirmation(BuildContext context, PosState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${state.selectedCustomer.fullName}'),
            Text('Payment Method: ${state.selectedPaymentMethodName}'),
            Text('Total Items: ${state.itemCount}'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount Payable:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${state.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PosCubit>().completeSale();
            },
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, PosState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            Text('Order #: ${state.completedSale?.orderNumber ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Total Paid: ₹${state.completedSale?.grandTotal.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Payment Method: ${state.completedSale?.paymentMethodName ?? 'Cash'}'),
            Text('Customer: ${state.selectedCustomer.fullName}'),
            Text('Time: ${DateTime.now().hour}:${DateTime.now().minute}'),
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

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Active Bill?'),
        content: const Text('All line items will be removed from the current POS session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PosCubit>().clearCart();
            },
            child: const Text('Clear All'),
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
                                            onPressed: () {
                                              if (product.variants.length > 1) {
                                                _showVariantSelector(context, product);
                                              } else {
                                                context.read<PosCubit>().addItemFromProduct(product);
                                              }
                                            },
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
                        // Customer Header Bar
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.selectedCustomer.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showCustomerPicker(context),
                              icon: const Icon(Icons.swap_horiz, size: 16),
                              label: const Text('Change'),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Current Bill (${state.itemCount} items)',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (state.cartItems.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                                tooltip: 'Clear Bill',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _confirmClearCart(context),
                              ),
                          ],
                        ),
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
                                                  Text('${item.variantName} (SKU: ${item.sku})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                              onSelected: state.isSubmitting
                                  ? null
                                  : (_) => context.read<PosCubit>().selectPaymentMethod(1, 'Cash'),
                            ),
                            ChoiceChip(
                              label: const Text('UPI'),
                              selected: state.selectedPaymentMethod == 2,
                              onSelected: state.isSubmitting
                                  ? null
                                  : (_) => context.read<PosCubit>().selectPaymentMethod(2, 'UPI'),
                            ),
                            ChoiceChip(
                              label: const Text('Card'),
                              selected: state.selectedPaymentMethod == 3,
                              onSelected: state.isSubmitting
                                  ? null
                                  : (_) => context.read<PosCubit>().selectPaymentMethod(3, 'Card'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (state.cartItems.isEmpty || state.isSubmitting)
                                ? null
                                : () => _showPaymentConfirmation(context, state),
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

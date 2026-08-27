import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/merchant_order_detail_cubit.dart';
import '../bloc/merchant_order_detail_state.dart';
import '../widgets/order_status_action_dialog.dart';
import '../widgets/order_status_badge.dart';

class MerchantOrderDetailScreen extends StatelessWidget {
  final String orderId;
  final MerchantOrderDetailCubit? cubit;

  const MerchantOrderDetailScreen({
    super.key,
    required this.orderId,
    this.cubit,
  });

  void _showActionDialog(
    BuildContext context,
    String title,
    bool isCancellation,
    Function(String comment) onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (_) => OrderStatusActionDialog(
        title: title,
        isCancellation: isCancellation,
        onConfirm: onConfirm,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, int status) {
    final cubit = context.read<MerchantOrderDetailCubit>();

    final buttons = <Widget>[];

    if (status == 1) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Confirm Order',
            false,
            (comment) => cubit.confirmOrder(orderId, comment: comment),
          ),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm Order'),
        ),
      );
    }

    if (status == 2) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Start Processing Order',
            false,
            (comment) => cubit.startProcessingOrder(orderId, comment: comment),
          ),
          icon: const Icon(Icons.build_circle_outlined),
          label: const Text('Process Order'),
        ),
      );
    }

    if (status == 7) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Pack Order',
            false,
            (comment) => cubit.packOrder(orderId, comment: comment),
          ),
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Pack Order'),
        ),
      );
    }

    if (status == 3) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Ship Order',
            false,
            (comment) => cubit.shipOrder(orderId, comment: comment),
          ),
          icon: const Icon(Icons.local_shipping_outlined),
          label: const Text('Ship Order'),
        ),
      );
    }

    if (status == 4) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Out for Delivery',
            false,
            (comment) => cubit.markOutForDelivery(orderId, comment: comment),
          ),
          icon: const Icon(Icons.two_wheeler),
          label: const Text('Out for Delivery'),
        ),
      );
    }

    if (status == 4 || status == 5) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Deliver Order',
            false,
            (comment) => cubit.deliverOrder(orderId, comment: comment),
          ),
          icon: const Icon(Icons.check_circle),
          label: const Text('Mark Delivered'),
        ),
      );
    }

    if (status >= 1 && status < 6 && status != 10) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Cancel Order',
            true,
            (reason) => cubit.cancelOrder(orderId, reason),
          ),
          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
          label: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (status == 20) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Approve Return',
            false,
            (comment) => cubit.approveReturn(orderId, comment: comment),
          ),
          icon: const Icon(Icons.assignment_return),
          label: const Text('Approve Return'),
        ),
      );
    }

    if (status == 21) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showActionDialog(
            context,
            'Complete Return',
            false,
            (comment) => cubit.completeReturn(orderId, comment: comment),
          ),
          icon: const Icon(Icons.check),
          label: const Text('Complete Return'),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: buttons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = cubit ?? sl<MerchantOrderDetailCubit>();

    return BlocProvider<MerchantOrderDetailCubit>.value(
      value: activeCubit..loadOrder(orderId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
        ),
        body: BlocConsumer<MerchantOrderDetailCubit, MerchantOrderDetailState>(
          listener: (context, state) {
            if (state.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Operation failed')),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isError && state.order == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage ?? 'Failed to load order'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<MerchantOrderDetailCubit>().loadOrder(orderId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final order = state.order;
            if (order == null) {
              return const Center(child: Text('Order not found.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderNumber,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              OrderStatusBadge(
                                status: order.status,
                                statusName: order.statusName,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Placed on: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute}'),
                          Text('Payment: ${order.paymentStatusName} via ${order.paymentMethodName}'),
                          _buildActionButtons(context, order.status),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (order.shippingAddress != null) ...[
                    Text('Shipping Address', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.shippingAddress!.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(order.shippingAddress!.phoneNumber),
                            Text('${order.shippingAddress!.line1}${order.shippingAddress!.line2 != null ? ', ${order.shippingAddress!.line2}' : ''}'),
                            Text('${order.shippingAddress!.city}, ${order.shippingAddress!.state} - ${order.shippingAddress!.pinCode}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Order Items (${order.items.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...order.items.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.productName),
                        subtitle: Text('${item.variantName} (SKU: ${item.sku}) x ${item.quantity}'),
                        trailing: Text('₹${item.lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text('Payment & Pricing Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), Text('₹${order.summary.subtotal.toStringAsFixed(2)}')]),
                          const SizedBox(height: 4),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Shipping Fee'), Text('₹${order.summary.shippingFee.toStringAsFixed(2)}')]),
                          const SizedBox(height: 4),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Discount'), Text('-₹${order.summary.discountTotal.toStringAsFixed(2)}')]),
                          const SizedBox(height: 4),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax'), Text('₹${order.summary.taxAmount.toStringAsFixed(2)}')]),
                          const Divider(),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('Grand Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text('₹${order.summary.grandTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  if (order.statusHistory.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Status History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: order.statusHistory.map((history) {
                            return ListTile(
                              dense: true,
                              title: Text(history.statusName),
                              subtitle: Text(history.comment ?? 'No comment'),
                              trailing: Text('${history.changedAt.day}/${history.changedAt.month}'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

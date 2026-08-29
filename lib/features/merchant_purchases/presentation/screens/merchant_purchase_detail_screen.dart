import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/purchase_order_model.dart';
import '../bloc/merchant_purchase_detail_cubit.dart';
import '../bloc/merchant_purchase_detail_state.dart';

class MerchantPurchaseDetailScreen extends StatefulWidget {
  final String purchaseId;
  final MerchantPurchaseDetailCubit? cubit;
  final VoidCallback? onReceiveGoodsTap;

  const MerchantPurchaseDetailScreen({
    super.key,
    required this.purchaseId,
    this.cubit,
    this.onReceiveGoodsTap,
  });

  @override
  State<MerchantPurchaseDetailScreen> createState() => _MerchantPurchaseDetailScreenState();
}

class _MerchantPurchaseDetailScreenState extends State<MerchantPurchaseDetailScreen> {
  late final MerchantPurchaseDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? sl<MerchantPurchaseDetailCubit>();
    _cubit.loadPurchaseDetail(widget.purchaseId);
  }

  Color _getStatusColor(PurchaseOrderStatus status) {
    switch (status) {
      case PurchaseOrderStatus.draft:
        return Colors.grey;
      case PurchaseOrderStatus.ordered:
        return Colors.blue;
      case PurchaseOrderStatus.partiallyReceived:
        return Colors.orange;
      case PurchaseOrderStatus.received:
        return Colors.green;
      case PurchaseOrderStatus.cancelled:
        return Colors.red;
    }
  }

  void _showCancelConfirm(PurchaseOrderModel purchase) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Cancel PO ${purchase.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this purchase order?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Cancellation Reason (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _cubit.cancelPurchaseOrder(reason: reasonController.text.trim());
            },
            child: const Text('Cancel PO', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Purchase Order Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _cubit.loadPurchaseDetail(widget.purchaseId),
            ),
          ],
        ),
        body: BlocConsumer<MerchantPurchaseDetailCubit, MerchantPurchaseDetailState>(
          listener: (context, state) {
            if (state is MerchantPurchaseDetailLoaded) {
              if (state.actionSuccessMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.actionSuccessMessage!), backgroundColor: Colors.green),
                );
              }
              if (state.actionError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.actionError!), backgroundColor: Colors.red),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is MerchantPurchaseDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MerchantPurchaseDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _cubit.loadPurchaseDetail(widget.purchaseId),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is MerchantPurchaseDetailLoaded) {
              final po = state.purchase;
              final statusColor = _getStatusColor(po.status);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    po.orderNumber,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Chip(
                                  label: Text(po.statusName, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                  backgroundColor: statusColor,
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text('Supplier: ${po.supplierName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text('Created: ${po.createdAt.toLocal().toString().split(' ')[0]}'),
                            if (po.expectedDeliveryDate != null)
                              Text('Expected Delivery: ${po.expectedDeliveryDate!.toLocal().toString().split(' ')[0]}'),
                            if (po.notes != null && po.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text('Notes: ${po.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              'Total Amount: ₹${po.totalAmount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Items (${po.items.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: po.items.length,
                      itemBuilder: (context, index) {
                        final item = po.items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.variantName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text('SKU: ${item.sku}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Ordered: ${item.quantityOrdered}'),
                                    Text('Received: ${item.quantityReceived}'),
                                    Text('Unit Cost: ₹${item.unitCost.toStringAsFixed(2)}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subtotal: ₹${item.totalCost.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (item.isFullyReceived)
                                      const Chip(
                                        label: Text('Fully Received', style: TextStyle(fontSize: 10, color: Colors.white)),
                                        backgroundColor: Colors.green,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (state.isSubmitting)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          if (po.status == PurchaseOrderStatus.draft) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: () => _cubit.markAsOrdered(),
                                icon: const Icon(Icons.send, color: Colors.white),
                                label: const Text('Mark as Ordered', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (po.status == PurchaseOrderStatus.ordered || po.status == PurchaseOrderStatus.partiallyReceived) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                onPressed: () {
                                  if (widget.onReceiveGoodsTap != null) {
                                    widget.onReceiveGoodsTap!();
                                  }
                                },
                                icon: const Icon(Icons.input, color: Colors.white),
                                label: const Text('Receive Goods', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (po.status == PurchaseOrderStatus.draft || po.status == PurchaseOrderStatus.ordered)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => _showCancelConfirm(po),
                              icon: const Icon(Icons.cancel, color: Colors.white),
                              label: const Text('Cancel PO', style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

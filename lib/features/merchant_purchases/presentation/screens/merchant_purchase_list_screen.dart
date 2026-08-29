import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/purchase_order_model.dart';
import '../bloc/merchant_purchase_cubit.dart';
import '../bloc/merchant_purchase_state.dart';

class MerchantPurchaseListScreen extends StatefulWidget {
  final MerchantPurchaseCubit? cubit;
  final ValueChanged<String>? onPurchaseTap;
  final VoidCallback? onCreatePurchaseTap;

  const MerchantPurchaseListScreen({
    super.key,
    this.cubit,
    this.onPurchaseTap,
    this.onCreatePurchaseTap,
  });

  @override
  State<MerchantPurchaseListScreen> createState() => _MerchantPurchaseListScreenState();
}

class _MerchantPurchaseListScreenState extends State<MerchantPurchaseListScreen> {
  late final MerchantPurchaseCubit _cubit;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? sl<MerchantPurchaseCubit>();
    _cubit.loadPurchases();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMorePurchases();
    }
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
              _cubit.cancelPurchaseOrder(purchase.id, reason: reasonController.text.trim());
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
          title: const Text('Purchase Orders'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Purchase Order',
              onPressed: () {
                if (widget.onCreatePurchaseTap != null) {
                  widget.onCreatePurchaseTap!();
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<MerchantPurchaseCubit, MerchantPurchaseState>(
          listener: (context, state) {
            if (state is MerchantPurchaseLoaded) {
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
            if (state is MerchantPurchaseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MerchantPurchaseError) {
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
                        onPressed: () => _cubit.loadPurchases(refresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is MerchantPurchaseLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search PO number or supplier...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _cubit.loadPurchases(
                                        search: null,
                                        status: state.statusFilter,
                                        supplierId: state.supplierIdFilter,
                                        refresh: true,
                                      );
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (val) {
                            _cubit.loadPurchases(
                              search: val.trim(),
                              status: state.statusFilter,
                              supplierId: state.supplierIdFilter,
                              refresh: true,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: state.statusFilter == null,
                                onSelected: (_) {
                                  _cubit.loadPurchases(
                                    search: state.search,
                                    status: null,
                                    supplierId: state.supplierIdFilter,
                                    refresh: true,
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              ...PurchaseOrderStatus.values.map((status) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: FilterChip(
                                    label: Text(status.displayName),
                                    selected: state.statusFilter == status,
                                    onSelected: (_) {
                                      _cubit.loadPurchases(
                                        search: state.search,
                                        status: status,
                                        supplierId: state.supplierIdFilter,
                                        refresh: true,
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.purchases.isEmpty
                        ? const Center(child: Text('No purchase orders found.'))
                        : RefreshIndicator(
                            onRefresh: () => _cubit.loadPurchases(
                              search: state.search,
                              status: state.statusFilter,
                              supplierId: state.supplierIdFilter,
                              refresh: true,
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: state.purchases.length + (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= state.purchases.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final purchase = state.purchases[index];
                                final statusColor = _getStatusColor(purchase.status);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    onTap: () {
                                      widget.onPurchaseTap?.call(purchase.id);
                                    },
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            purchase.orderNumber,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            purchase.statusName,
                                            style: const TextStyle(fontSize: 10, color: Colors.white),
                                          ),
                                          backgroundColor: statusColor,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Supplier: ${purchase.supplierName}'),
                                        Text(
                                          'Total: ₹${purchase.totalAmount.toStringAsFixed(2)} • ${purchase.items.length} items',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        if (purchase.expectedDeliveryDate != null)
                                          Text('Expected Delivery: ${purchase.expectedDeliveryDate!.toLocal().toString().split(' ')[0]}'),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'details') {
                                          widget.onPurchaseTap?.call(purchase.id);
                                        } else if (val == 'order') {
                                          _cubit.markAsOrdered(purchase.id);
                                        } else if (val == 'cancel') {
                                          _showCancelConfirm(purchase);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'details', child: Text('View Details')),
                                        if (purchase.status == PurchaseOrderStatus.draft)
                                          const PopupMenuItem(value: 'order', child: Text('Mark as Ordered')),
                                        if (purchase.status == PurchaseOrderStatus.draft ||
                                            purchase.status == PurchaseOrderStatus.ordered)
                                          const PopupMenuItem(value: 'cancel', child: Text('Cancel Order')),
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
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

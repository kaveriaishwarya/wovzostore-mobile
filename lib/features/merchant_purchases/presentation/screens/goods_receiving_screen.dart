import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/purchase_order_model.dart';
import '../bloc/merchant_purchase_detail_cubit.dart';
import '../bloc/merchant_purchase_detail_state.dart';

class GoodsReceivingScreen extends StatefulWidget {
  final String purchaseId;
  final MerchantPurchaseDetailCubit? cubit;
  final VoidCallback? onReceivedSuccess;

  const GoodsReceivingScreen({
    super.key,
    required this.purchaseId,
    this.cubit,
    this.onReceivedSuccess,
  });

  @override
  State<GoodsReceivingScreen> createState() => _GoodsReceivingScreenState();
}

class _GoodsReceivingScreenState extends State<GoodsReceivingScreen> {
  late final MerchantPurchaseDetailCubit _cubit;
  final Map<String, TextEditingController> _qtyControllers = {};
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? sl<MerchantPurchaseDetailCubit>();
    _cubit.loadPurchaseDetail(widget.purchaseId);
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  void _initControllers(List<PurchaseOrderItemModel> items) {
    for (final item in items) {
      if (!_qtyControllers.containsKey(item.id)) {
        final remaining = item.quantityOrdered - item.quantityReceived;
        _qtyControllers[item.id] = TextEditingController(text: remaining > 0 ? remaining.toString() : '0');
      }
    }
  }

  void _submitReceiving(PurchaseOrderModel purchase) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final receiveItemsList = <ReceivePurchaseItemRequestModel>[];
    for (final item in purchase.items) {
      final controller = _qtyControllers[item.id];
      if (controller != null) {
        final qty = int.tryParse(controller.text.trim()) ?? 0;
        if (qty > 0) {
          receiveItemsList.add(ReceivePurchaseItemRequestModel(
            itemId: item.id,
            quantityToReceive: qty,
          ));
        }
      }
    }

    if (receiveItemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quantity greater than 0 for at least one item.')),
      );
      return;
    }

    final req = ReceivePurchaseItemsRequestModel(
      items: receiveItemsList,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    _cubit.receiveItems(req);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goods Receiving'),
        ),
        body: BlocConsumer<MerchantPurchaseDetailCubit, MerchantPurchaseDetailState>(
          listener: (context, state) {
            if (state is MerchantPurchaseDetailLoaded) {
              if (state.actionSuccessMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.actionSuccessMessage!), backgroundColor: Colors.green),
                );
                if (widget.onReceivedSuccess != null) {
                  widget.onReceivedSuccess!();
                } else {
                  Navigator.pop(context);
                }
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
              final purchase = state.purchase;
              _initControllers(purchase.items);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
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
                              Text(
                                'PO: ${purchase.orderNumber}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Supplier: ${purchase.supplierName}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Enter Received Quantities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: purchase.items.length,
                        itemBuilder: (context, index) {
                          final item = purchase.items[index];
                          final remaining = item.quantityOrdered - item.quantityReceived;
                          final controller = _qtyControllers[item.id];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.variantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('SKU: ${item.sku}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text('Ordered: ${item.quantityOrdered}\nReceived: ${item.quantityReceived}\nRemaining: $remaining'),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 120,
                                        child: TextFormField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Receive Qty',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (val) {
                                            if (val == null || val.trim().isEmpty) return 'Required';
                                            final parsed = int.tryParse(val.trim());
                                            if (parsed == null || parsed < 0) return 'Invalid';
                                            if (parsed > remaining) return 'Max $remaining';
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Receiving Notes / Reference (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: state.isSubmitting ? null : () => _submitReceiving(purchase),
                          icon: state.isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: Text(
                            state.isSubmitting ? 'Receiving Goods...' : 'Confirm Goods Receiving',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
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

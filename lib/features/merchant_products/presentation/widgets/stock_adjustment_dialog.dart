import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/merchant_stock_cubit.dart';
import '../bloc/merchant_stock_state.dart';

class StockAdjustmentDialog extends StatefulWidget {
  final String variantId;
  final String variantName;
  final int currentQuantity;
  final MerchantStockCubit? cubit;

  const StockAdjustmentDialog({
    super.key,
    required this.variantId,
    required this.variantName,
    required this.currentQuantity,
    this.cubit,
  });

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  late TextEditingController _quantityController;
  late TextEditingController _adjustmentController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.currentQuantity.toString());
    _adjustmentController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _adjustmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adjust Stock: ${widget.variantName}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const TabBar(
            tabs: [
              Tab(text: 'Set Absolute'),
              Tab(text: 'Adjust Relative'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: TabBarView(
              children: [
                Column(
                  children: [
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'New Absolute Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<MerchantStockCubit, MerchantStockState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isUpdating
                              ? null
                              : () {
                                  final val = int.tryParse(_quantityController.text);
                                  if (val != null) {
                                    context.read<MerchantStockCubit>().setQuantity(widget.variantId, val);
                                  }
                                },
                          child: const Text('Set Quantity'),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextField(
                      controller: _adjustmentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Adjustment (+/- Amount)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<MerchantStockCubit, MerchantStockState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isUpdating
                              ? null
                              : () {
                                  final val = int.tryParse(_adjustmentController.text);
                                  if (val != null) {
                                    context.read<MerchantStockCubit>().adjustQuantity(widget.variantId, val);
                                  }
                                },
                          child: const Text('Apply Adjustment'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.cubit != null) {
      content = BlocProvider<MerchantStockCubit>.value(
        value: widget.cubit!,
        child: content,
      );
    }

    return BlocListener<MerchantStockCubit, MerchantStockState>(
      bloc: widget.cubit,
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop(true);
        } else if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Failed to update stock')),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
      ),
    );
  }
}

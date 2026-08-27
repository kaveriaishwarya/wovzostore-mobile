import 'package:flutter/material.dart';
import '../../../catalog/data/models/product_variant_model.dart';
import '../bloc/merchant_product_form_cubit.dart';
import '../../data/models/create_product_request_model.dart';

class VariantEditorDialog extends StatefulWidget {
  final String productId;
  final MerchantProductFormCubit cubit;

  const VariantEditorDialog({
    super.key,
    required this.productId,
    required this.cubit,
  });

  @override
  State<VariantEditorDialog> createState() => _VariantEditorDialogState();
}

class _VariantEditorDialogState extends State<VariantEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _comparePriceController = TextEditingController();

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final request = AddVariantRequestModel(
      sku: _skuController.text.trim(),
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      compareAtPrice: double.tryParse(_comparePriceController.text.trim()),
    );

    widget.cubit.addVariant(widget.productId, request);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Product Variant'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU *', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Variant Name (e.g. Size L / Red) *', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₹) *', border: OutlineInputBorder()),
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid price' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _comparePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Compare At Price (MRP)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Add Variant'),
        ),
      ],
    );
  }
}

class VariantListTile extends StatelessWidget {
  final ProductVariantModel variant;
  final VoidCallback onAdjustStock;

  const VariantListTile({
    super.key,
    required this.variant,
    required this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${variant.name} (${variant.sku})',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${variant.price.toStringAsFixed(2)} ${variant.compareAtPrice != null ? '(MRP ₹${variant.compareAtPrice!.toStringAsFixed(2)})' : ''}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAdjustStock,
            icon: const Icon(Icons.inventory_2_outlined, size: 16),
            label: const Text('Stock'),
            style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/models/product_variant_model.dart';

class VariantSelector extends StatelessWidget {
  final List<ProductVariantModel> variants;
  final ProductVariantModel? selectedVariant;
  final ValueChanged<ProductVariantModel>? onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    this.selectedVariant,
    this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Variant',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.map((variant) {
            final isSelected = selectedVariant?.id == variant.id;
            final isAvailable = variant.isActive && variant.stockQuantity > 0;

            return ChoiceChip(
              label: Text(
                '${variant.name} (${isAvailable ? "₹${variant.price.toStringAsFixed(2)}" : "Out of Stock"})',
              ),
              selected: isSelected,
              onSelected: isAvailable
                  ? (selected) {
                      if (selected) onVariantSelected?.call(variant);
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

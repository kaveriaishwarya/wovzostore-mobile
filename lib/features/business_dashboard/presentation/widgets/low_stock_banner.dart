import 'package:flutter/material.dart';

class LowStockBanner extends StatelessWidget {
  final int lowStockCount;
  final VoidCallback? onViewInventory;

  const LowStockBanner({
    super.key,
    required this.lowStockCount,
    this.onViewInventory,
  });

  @override
  Widget build(BuildContext context) {
    if (lowStockCount <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Low Stock Alert',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  '$lowStockCount products require inventory replenishment.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          if (onViewInventory != null)
            TextButton(
              onPressed: onViewInventory,
              child: const Text('View'),
            ),
        ],
      ),
    );
  }
}

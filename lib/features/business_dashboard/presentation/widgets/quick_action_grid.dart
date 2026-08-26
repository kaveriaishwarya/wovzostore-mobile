import 'package:flutter/material.dart';

class QuickActionGrid extends StatelessWidget {
  final VoidCallback? onPosTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onProductsTap;
  final VoidCallback? onInventoryTap;
  final VoidCallback? onCustomersTap;
  final VoidCallback? onAnalyticsTap;

  const QuickActionGrid({
    super.key,
    this.onPosTap,
    this.onOrdersTap,
    this.onProductsTap,
    this.onInventoryTap,
    this.onCustomersTap,
    this.onAnalyticsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = [
      _ActionItem('POS', Icons.point_of_sale, Colors.blue, onPosTap),
      _ActionItem('Orders', Icons.shopping_bag_outlined, Colors.orange, onOrdersTap),
      _ActionItem('Products', Icons.inventory_2_outlined, Colors.green, onProductsTap),
      _ActionItem('Inventory', Icons.warehouse_outlined, Colors.purple, onInventoryTap),
      _ActionItem('Customers', Icons.people_outline, Colors.teal, onCustomersTap),
      _ActionItem('Analytics', Icons.analytics_outlined, Colors.indigo, onAnalyticsTap),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final item = actions[index];
            return InkWell(
              onTap: item.onTap ?? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.title} feature coming soon'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: item.color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _ActionItem(this.title, this.icon, this.color, this.onTap);
}

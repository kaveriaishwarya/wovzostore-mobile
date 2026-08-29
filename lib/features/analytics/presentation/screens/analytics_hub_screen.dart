import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnalyticsHubScreen extends StatelessWidget {
  const AnalyticsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final basePath = currentPath.startsWith('/business') ? '/business/analytics' : '/analytics';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Store Analytics & Reports',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Access real-time sales trends, product metrics, and business operations data.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            _buildNavigationCard(
              context: context,
              title: 'Sales Report',
              description: 'Gross and net revenue, order volume, and periodic trend charts.',
              icon: Icons.trending_up,
              iconColor: Colors.blue.shade600,
              route: '$basePath/sales',
            ),
            const SizedBox(height: 12),
            _buildNavigationCard(
              context: context,
              title: 'Product Performance',
              description: 'Units sold, revenue, average selling price, and category/brand breakdown.',
              icon: Icons.shopping_bag_outlined,
              iconColor: Colors.teal.shade600,
              route: '$basePath/products',
            ),
            const SizedBox(height: 12),
            _buildNavigationCard(
              context: context,
              title: 'Categories & Brands',
              description: 'Performance rankings and revenue distribution across categories and brands.',
              icon: Icons.category_outlined,
              iconColor: Colors.indigo.shade600,
              route: '$basePath/categories-brands',
            ),
            const SizedBox(height: 12),
            _buildNavigationCard(
              context: context,
              title: 'Customer Analytics',
              description: 'Customer acquisition, repeat purchase rates, and top customer spenders.',
              icon: Icons.people_outline,
              iconColor: Colors.purple.shade600,
              route: '$basePath/customers',
            ),
            const SizedBox(height: 12),
            _buildNavigationCard(
              context: context,
              title: 'Inventory Report',
              description: 'Stock valuation, low stock threshold alerts, and inventory velocity.',
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.amber.shade800,
              route: '$basePath/inventory',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String route,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

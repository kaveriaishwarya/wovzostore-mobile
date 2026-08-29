import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/merchant_dashboard_cubit.dart';
import '../bloc/merchant_dashboard_state.dart';
import '../widgets/kpi_summary_card.dart';
import '../widgets/low_stock_banner.dart';
import '../widgets/quick_action_grid.dart';

class MerchantDashboardScreen extends StatelessWidget {
  final MerchantDashboardCubit? cubit;
  final VoidCallback? onPosTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onProductsTap;
  final VoidCallback? onInventoryTap;
  final VoidCallback? onCustomersTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onStaffTap;
  final VoidCallback? onSuppliersTap;
  final VoidCallback? onPurchasesTap;
  final VoidCallback? onStockMovementsTap;

  const MerchantDashboardScreen({
    super.key,
    this.cubit,
    this.onPosTap,
    this.onOrdersTap,
    this.onProductsTap,
    this.onInventoryTap,
    this.onCustomersTap,
    this.onAnalyticsTap,
    this.onSettingsTap,
    this.onStaffTap,
    this.onSuppliersTap,
    this.onPurchasesTap,
    this.onStockMovementsTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeCubit = cubit ?? sl<MerchantDashboardCubit>();

    return BlocProvider<MerchantDashboardCubit>.value(
      value: activeCubit..loadDashboard(),
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WOVZO BUSINESS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Merchant Dashboard', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
            ],
          ),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ctx.read<MerchantDashboardCubit>().loadDashboard(),
                tooltip: 'Refresh Dashboard',
              ),
            ),
          ],
        ),
        body: BlocBuilder<MerchantDashboardCubit, MerchantDashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Failed to load dashboard data',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.read<MerchantDashboardCubit>().loadDashboard(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final snapshot = state.summary?.latestDaily ?? state.summary?.latestWeekly ?? state.summary?.latestMonthly;

            return RefreshIndicator(
              onRefresh: () => context.read<MerchantDashboardCubit>().loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (snapshot != null)
                      LowStockBanner(
                        lowStockCount: snapshot.lowStockCount,
                        onViewInventory: onInventoryTap,
                      ),
                    Text(
                      "Today's Overview",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          children: [
                            KpiSummaryCard(
                              title: 'Total Revenue',
                              value: '₹${(snapshot?.totalRevenue ?? 0).toStringAsFixed(2)}',
                              icon: Icons.currency_rupee,
                              color: Colors.green,
                            ),
                            KpiSummaryCard(
                              title: 'Total Orders',
                              value: '${snapshot?.totalOrders ?? 0}',
                              icon: Icons.shopping_bag_outlined,
                              color: Colors.blue,
                            ),
                            KpiSummaryCard(
                              title: 'Avg Order Value',
                              value: '₹${(snapshot?.averageOrderValue ?? 0).toStringAsFixed(2)}',
                              icon: Icons.trending_up,
                              color: Colors.purple,
                            ),
                            KpiSummaryCard(
                              title: 'Total Customers',
                              value: '${snapshot?.totalCustomers ?? 0}',
                              icon: Icons.people_outline,
                              color: Colors.teal,
                              subtitle: '+${snapshot?.newCustomers ?? 0} new today',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    QuickActionGrid(
                      onPosTap: onPosTap,
                      onOrdersTap: onOrdersTap,
                      onProductsTap: onProductsTap,
                      onInventoryTap: onInventoryTap,
                      onCustomersTap: onCustomersTap,
                      onAnalyticsTap: onAnalyticsTap,
                      onSettingsTap: onSettingsTap,
                      onStaffTap: onStaffTap,
                      onSuppliersTap: onSuppliersTap,
                      onPurchasesTap: onPurchasesTap,
                      onStockMovementsTap: onStockMovementsTap,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

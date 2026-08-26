import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_status.dart';
import '../bloc/sales_cubit.dart';
import '../bloc/sales_state.dart';
import '../utils/analytics_formatters.dart';
import '../widgets/analytics_kpi_card.dart';
import '../widgets/date_range_filter.dart';
import '../widgets/order_volume_chart.dart';
import '../widgets/sales_trend_chart.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalesCubit>().loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Sales Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SalesCubit>().reload(),
            tooltip: 'Reload report',
          ),
        ],
      ),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading && state.report == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == AnalyticsStatus.error && state.report == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load sales report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.errorMessage ?? 'An unexpected error occurred.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<SalesCubit>().reload(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = state.report;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SalesCubit>().reload();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DateRangeFilter(
                            startDate: state.startDate,
                            endDate: state.endDate,
                            onDateRangeChanged: (start, end) {
                              context
                                  .read<SalesCubit>()
                                  .updateDateRange(startDate: start, endDate: end);
                            },
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _buildIntervalSelector(context, state.interval),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (report != null) ...[
                    // Primary KPI Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth > 600;
                        final crossAxisCount = isTablet ? 4 : 2;

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: isTablet ? 1.4 : 1.3,
                          children: [
                            AnalyticsKpiCard(
                              title: 'Gross Sales',
                              value: AnalyticsFormatters.formatCurrency(report.grossSales),
                              icon: Icons.attach_money,
                              iconColor: Colors.blue.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'Net Sales',
                              value: AnalyticsFormatters.formatCurrency(report.netSales),
                              icon: Icons.account_balance_wallet,
                              iconColor: Colors.teal.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'Total Orders',
                              value: AnalyticsFormatters.formatNumber(report.orderCount),
                              icon: Icons.shopping_bag_outlined,
                              iconColor: Colors.indigo.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'Average Order Value',
                              value: AnalyticsFormatters.formatCurrency(report.averageOrderValue),
                              icon: Icons.trending_up,
                              iconColor: Colors.purple.shade600,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Charts
                    SalesTrendChart(trend: report.trend),
                    const SizedBox(height: 16),
                    OrderVolumeChart(trend: report.trend),
                    const SizedBox(height: 16),

                    // Secondary Financial Breakdown
                    _buildSecondaryMetricsCard(report),
                  ] else if (state.status == AnalyticsStatus.success) ...[
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No sales recorded for this timeframe',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntervalSelector(BuildContext context, int? currentInterval) {
    final intervals = [
      {'label': 'Daily', 'value': 0},
      {'label': 'Weekly', 'value': 1},
      {'label': 'Monthly', 'value': 2},
      {'label': 'Yearly', 'value': 3},
    ];

    return Row(
      children: [
        Text(
          'Interval: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: intervals.map((item) {
                final isSelected = (currentInterval ?? 0) == item['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(item['label'] as String),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                    onSelected: (_) {
                      context
                          .read<SalesCubit>()
                          .updateInterval(item['value'] as int);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryMetricsCard(dynamic report) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secondary Breakdown',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Total Discounts', AnalyticsFormatters.formatCurrency(report.discountAmount), Colors.orange.shade700),
            const Divider(height: 20),
            _buildMetricRow('Taxes Collected', AnalyticsFormatters.formatCurrency(report.taxAmount), Colors.grey.shade800),
            const Divider(height: 20),
            _buildMetricRow('Shipping Charges', AnalyticsFormatters.formatCurrency(report.shippingAmount), Colors.grey.shade800),
            const Divider(height: 20),
            _buildMetricRow('Refund Amount', AnalyticsFormatters.formatCurrency(report.refundAmount), Colors.red.shade600),
            const Divider(height: 20),
            _buildMetricRow('Cancelled Orders', AnalyticsFormatters.formatNumber(report.cancelledOrderCount), Colors.red.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

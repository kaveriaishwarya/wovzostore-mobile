import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/inventory_report_model.dart';
import '../bloc/analytics_status.dart';
import '../bloc/inventory_report_cubit.dart';
import '../bloc/inventory_report_state.dart';
import '../utils/analytics_formatters.dart';
import '../widgets/analytics_kpi_card.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InventoryReportCubit>().loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Inventory Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InventoryReportCubit>().reload(),
            tooltip: 'Reload report',
          ),
        ],
      ),
      body: BlocBuilder<InventoryReportCubit, InventoryReportState>(
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
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load inventory report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.errorMessage ?? 'An unexpected error occurred.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<InventoryReportCubit>().reload(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = state.report;
          final items = report?.items.data ?? [];
          final pagedData = report?.items;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<InventoryReportCubit>().reload();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Summary Cards
                  if (report != null) ...[
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
                              title: 'Total Valuation',
                              value: AnalyticsFormatters.formatCurrency(
                                  report.totalInventoryValue),
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: Colors.blue.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'Total Units',
                              value: AnalyticsFormatters.formatNumber(
                                  report.totalUnits),
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.teal.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'Low Stock',
                              value: AnalyticsFormatters.formatNumber(
                                  report.lowStockCount),
                              icon: Icons.warning_amber_rounded,
                              iconColor: Colors.amber.shade700,
                            ),
                            AnalyticsKpiCard(
                              title: 'Out of Stock',
                              value: AnalyticsFormatters.formatNumber(
                                  report.outOfStockCount),
                              icon: Icons.highlight_off_rounded,
                              iconColor: Colors.red.shade600,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Filter & Sorting Bar
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
                          // Low stock filter chip
                          Row(
                            children: [
                              FilterChip(
                                label: const Text('Low Stock Only'),
                                selected: state.lowStockOnly,
                                onSelected: (selected) {
                                  context
                                      .read<InventoryReportCubit>()
                                      .updateFilters(lowStockOnly: selected);
                                },
                                selectedColor: Colors.amber.shade100,
                                checkmarkColor: Colors.amber.shade900,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: state.lowStockOnly
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: state.lowStockOnly
                                      ? Colors.amber.shade900
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _buildSortingSection(context, state),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Count
                  if (pagedData != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pagedData.totalCount} Inventory SKUs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Page ${pagedData.pageNumber} of ${pagedData.totalPages > 0 ? pagedData.totalPages : 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Inventory Items List
                  if (items.isNotEmpty) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildInventoryCard(items[index]);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pagination Controls
                    if (pagedData != null && pagedData.totalPages > 1)
                      _buildPaginationBar(context, pagedData),
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
                            Icon(Icons.check_circle_outline,
                                size: 48, color: Colors.green.shade300),
                            const SizedBox(height: 12),
                            Text(
                              state.lowStockOnly
                                  ? 'No low stock inventory items found'
                                  : 'No inventory items recorded',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
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

  Widget _buildSortingSection(
      BuildContext context, InventoryReportState state) {
    final sortOptions = [
      {'label': 'Stock', 'value': 'stock'},
      {'label': 'Value', 'value': 'value'},
      {'label': 'Name', 'value': 'name'},
      {'label': 'Velocity', 'value': 'velocity'},
    ];

    final isDesc = state.sortDirection == 'desc';

    return Row(
      children: [
        Text(
          'Sort:',
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
              children: sortOptions.map((opt) {
                final isSelected = state.sortBy.toLowerCase() ==
                    (opt['value'] as String).toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(opt['label'] as String),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
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
                      context.read<InventoryReportCubit>().changeSorting(
                            opt['value'] as String,
                            state.sortDirection,
                          );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            isDesc ? Icons.arrow_downward : Icons.arrow_upward,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          tooltip: isDesc ? 'Descending' : 'Ascending',
          onPressed: () {
            context.read<InventoryReportCubit>().changeSorting(
                  state.sortBy,
                  isDesc ? 'asc' : 'desc',
                );
          },
        ),
      ],
    );
  }

  Widget _buildInventoryCard(InventoryItemReportModel item) {
    final statusBadge = _getStockStatusBadge(item);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                statusBadge,
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Stock Details Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStockInfo('Current', '${item.currentStock} units'),
                _buildStockInfo('Reserved', '${item.reservedStock} units'),
                _buildStockInfo('Available', '${item.availableStock} units'),
                _buildStockInfo('Threshold', '${item.lowStockThreshold} units'),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Financial & Velocity Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valuation: ${AnalyticsFormatters.formatCurrency(item.inventoryValue)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700,
                  ),
                ),
                Text(
                  'Sold: ${item.unitsSoldInPeriod} (${item.stockVelocity.toStringAsFixed(1)}x)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _getStockStatusBadge(InventoryItemReportModel item) {
    if (item.currentStock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 12, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text(
              'Out of Stock',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      );
    } else if (item.currentStock <= item.lowStockThreshold) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 12, color: Colors.amber.shade800),
            const SizedBox(width: 4),
            Text(
              'Low Stock',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 12, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Healthy',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPaginationBar(BuildContext context, dynamic pagedData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: pagedData.hasPreviousPage
              ? () {
                  context
                      .read<InventoryReportCubit>()
                      .changePage(pagedData.pageNumber - 1);
                }
              : null,
          icon: const Icon(Icons.chevron_left, size: 16),
          label: const Text('Previous'),
        ),
        Text(
          'Page ${pagedData.pageNumber} of ${pagedData.totalPages}',
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500),
        ),
        OutlinedButton.icon(
          onPressed: pagedData.hasNextPage
              ? () {
                  context
                      .read<InventoryReportCubit>()
                      .changePage(pagedData.pageNumber + 1);
                }
              : null,
          icon: const Icon(Icons.chevron_right, size: 16),
          label: const Text('Next'),
        ),
      ],
    );
  }
}

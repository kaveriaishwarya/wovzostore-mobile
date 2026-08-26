import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_performance_model.dart';
import '../../data/services/analytics_csv_export_service.dart';
import '../bloc/analytics_status.dart';
import '../bloc/product_performance_cubit.dart';
import '../bloc/product_performance_state.dart';
import '../utils/analytics_formatters.dart';
import '../widgets/date_range_filter.dart';

class ProductPerformanceScreen extends StatefulWidget {
  const ProductPerformanceScreen({super.key});

  @override
  State<ProductPerformanceScreen> createState() => _ProductPerformanceScreenState();
}

class _ProductPerformanceScreenState extends State<ProductPerformanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductPerformanceCubit>().loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Product Performance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          BlocBuilder<ProductPerformanceCubit, ProductPerformanceState>(
            builder: (context, state) {
              if (state.isExporting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  context
                      .read<ProductPerformanceCubit>()
                      .exportReport(AnalyticsCsvExportServiceImpl());
                },
                tooltip: 'Export CSV',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProductPerformanceCubit>().reload(),
            tooltip: 'Reload report',
          ),
        ],
      ),
      body: BlocBuilder<ProductPerformanceCubit, ProductPerformanceState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading && state.pagedData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == AnalyticsStatus.error && state.pagedData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load product performance',
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
                      onPressed: () => context.read<ProductPerformanceCubit>().reload(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final pagedData = state.pagedData;
          final products = pagedData?.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductPerformanceCubit>().reload();
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
                              context.read<ProductPerformanceCubit>().updateFilters(
                                    startDate: start,
                                    endDate: end,
                                  );
                            },
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
                          '${pagedData.totalCount} Products Sold',
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

                  // Product List
                  if (products.isNotEmpty) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildProductCard(products[index]);
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
                            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No product performance data for this period',
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

  Widget _buildSortingSection(BuildContext context, ProductPerformanceState state) {
    final sortOptions = [
      {'label': 'Revenue', 'value': 'revenue'},
      {'label': 'Units Sold', 'value': 'unitssold'},
      {'label': 'Name', 'value': 'name'},
      {'label': 'Price', 'value': 'price'},
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
                final isSelected = state.sortBy.toLowerCase() == (opt['value'] as String).toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(opt['label'] as String),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                    onSelected: (_) {
                      context.read<ProductPerformanceCubit>().changeSorting(
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
            context.read<ProductPerformanceCubit>().changeSorting(
                  state.sortBy,
                  isDesc ? 'asc' : 'desc',
                );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductPerformanceModel product) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.productName,
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
                Text(
                  AnalyticsFormatters.formatCurrency(product.revenue),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Variant: ${product.variantName ?? "—"}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Units Sold: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      AnalyticsFormatters.formatNumber(product.unitsSold),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.sell_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Avg Price: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      AnalyticsFormatters.formatCurrency(product.averageSellingPrice),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar(BuildContext context, dynamic pagedData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: pagedData.hasPreviousPage
              ? () {
                  context
                      .read<ProductPerformanceCubit>()
                      .changePage(pagedData.pageNumber - 1);
                }
              : null,
          icon: const Icon(Icons.chevron_left, size: 16),
          label: const Text('Previous'),
        ),
        Text(
          'Page ${pagedData.pageNumber} of ${pagedData.totalPages}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        OutlinedButton.icon(
          onPressed: pagedData.hasNextPage
              ? () {
                  context
                      .read<ProductPerformanceCubit>()
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

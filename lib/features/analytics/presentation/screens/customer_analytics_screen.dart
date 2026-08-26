import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/customer_analytics_model.dart';
import '../../data/services/analytics_csv_export_service.dart';
import '../bloc/analytics_status.dart';
import '../bloc/customer_analytics_cubit.dart';
import '../bloc/customer_analytics_state.dart';
import '../utils/analytics_formatters.dart';
import '../widgets/analytics_kpi_card.dart';
import '../widgets/date_range_filter.dart';

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  State<CustomerAnalyticsScreen> createState() =>
      _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerAnalyticsCubit>().loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Customer Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          BlocBuilder<CustomerAnalyticsCubit, CustomerAnalyticsState>(
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
                      .read<CustomerAnalyticsCubit>()
                      .exportReport(AnalyticsCsvExportServiceImpl());
                },
                tooltip: 'Export CSV',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CustomerAnalyticsCubit>().reload(),
            tooltip: 'Reload report',
          ),
        ],
      ),
      body: BlocBuilder<CustomerAnalyticsCubit, CustomerAnalyticsState>(
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
                      'Failed to load customer analytics',
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
                          context.read<CustomerAnalyticsCubit>().reload(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = state.report;
          final summary = report?.summary;
          final topCustomers = report?.topCustomers.data ?? [];
          final pagedData = report?.topCustomers;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CustomerAnalyticsCubit>().reload();
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
                      child: DateRangeFilter(
                        startDate: state.startDate,
                        endDate: state.endDate,
                        onDateRangeChanged: (start, end) {
                          context
                              .read<CustomerAnalyticsCubit>()
                              .updateDateRange(
                                startDate: start,
                                endDate: end,
                              );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary KPI Cards
                  if (summary != null) ...[
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
                          childAspectRatio: isTablet ? 1.4 : 1.15,
                          children: [
                            AnalyticsKpiCard(
                              title: 'Total Customers',
                              value: AnalyticsFormatters.formatNumber(
                                  summary.totalCustomers),
                              icon: Icons.people_outline,
                              iconColor: Colors.blue.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'New Customers',
                              value: AnalyticsFormatters.formatNumber(
                                  summary.newCustomers),
                              subtitle:
                                  'Rev: ${AnalyticsFormatters.formatCompactCurrency(summary.revenueFromNewCustomers)}',
                              icon: Icons.person_add_outlined,
                              iconColor: Colors.teal.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'Returning Customers',
                              value: AnalyticsFormatters.formatNumber(
                                  summary.returningCustomers),
                              subtitle:
                                  'Rev: ${AnalyticsFormatters.formatCompactCurrency(summary.revenueFromReturningCustomers)}',
                              icon: Icons.repeat,
                              iconColor: Colors.indigo.shade600,
                            ),
                            AnalyticsKpiCard(
                              title: 'Repeat Rate',
                              value:
                                  '${summary.repeatPurchaseRate.toStringAsFixed(1)}%',
                              icon: Icons.insights_outlined,
                              iconColor: Colors.purple.shade600,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Top Customers Section Header & Sorting
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Top Customers',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (pagedData != null)
                                Text(
                                  '${pagedData.totalCount} Customers',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSortingSection(context, state),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer List
                  if (topCustomers.isNotEmpty) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topCustomers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildCustomerCard(topCustomers[index]);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pagination
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
                            Icon(Icons.person_search_outlined,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No customer order data for this period',
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
      BuildContext context, CustomerAnalyticsState state) {
    final sortOptions = [
      {'label': 'Revenue', 'value': 'revenue'},
      {'label': 'Orders', 'value': 'ordercount'},
      {'label': 'Last Order', 'value': 'lastorderdate'},
      {'label': 'Name', 'value': 'name'},
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
                      context.read<CustomerAnalyticsCubit>().changeSorting(
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
            context.read<CustomerAnalyticsCubit>().changeSorting(
                  state.sortBy,
                  isDesc ? 'asc' : 'desc',
                );
          },
        ),
      ],
    );
  }

  Widget _buildCustomerCard(CustomerPerformanceModel customer) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customer.displayName.isEmpty
                        ? 'Customer'
                        : customer.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  AnalyticsFormatters.formatCurrency(customer.revenue),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Orders: ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      AnalyticsFormatters.formatNumber(customer.orderCount),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.event_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Last Order: ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      AnalyticsFormatters.formatDate(customer.lastOrderDate),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
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
                      .read<CustomerAnalyticsCubit>()
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
                      .read<CustomerAnalyticsCubit>()
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

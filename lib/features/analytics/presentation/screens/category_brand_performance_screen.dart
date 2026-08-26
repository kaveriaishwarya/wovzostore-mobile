import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/brand_performance_model.dart';
import '../../data/models/category_performance_model.dart';
import '../bloc/analytics_status.dart';
import '../bloc/category_brand_cubit.dart';
import '../bloc/category_brand_state.dart';
import '../utils/analytics_formatters.dart';
import '../widgets/date_range_filter.dart';

class CategoryBrandPerformanceScreen extends StatefulWidget {
  const CategoryBrandPerformanceScreen({super.key});

  @override
  State<CategoryBrandPerformanceScreen> createState() =>
      _CategoryBrandPerformanceScreenState();
}

class _CategoryBrandPerformanceScreenState
    extends State<CategoryBrandPerformanceScreen> {
  int _selectedTabIndex = 0; // 0: Categories, 1: Brands

  @override
  void initState() {
    super.initState();
    context.read<CategoryBrandCubit>().loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Categories & Brands',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CategoryBrandCubit>().reload(),
            tooltip: 'Reload report',
          ),
        ],
      ),
      body: BlocBuilder<CategoryBrandCubit, CategoryBrandState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading &&
              state.categories.isEmpty &&
              state.brands.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == AnalyticsStatus.error &&
              state.categories.isEmpty &&
              state.brands.isEmpty) {
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
                      'Failed to load category & brand performance',
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
                          context.read<CategoryBrandCubit>().reload(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CategoryBrandCubit>().reload();
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
                                  .read<CategoryBrandCubit>()
                                  .updateDateRange(
                                    startDate: start,
                                    endDate: end,
                                  );
                            },
                          ),
                          const SizedBox(height: 14),
                          // Segmented Switcher
                          _buildSegmentedTab(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Display
                  if (_selectedTabIndex == 0)
                    _buildCategoryList(state.categories)
                  else
                    _buildBrandList(state.brands),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSegmentedTab() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: 'Categories',
              index: 0,
              icon: Icons.category_outlined,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              title: 'Brands',
              index: 1,
              icon: Icons.storefront_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int index,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxStyle(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryPerformanceModel> categories) {
    if (categories.isEmpty) {
      return _buildEmptyCard('No category sales data for this period');
    }

    double maxRevenue = 0;
    for (final c in categories) {
      if (c.revenue > maxRevenue) maxRevenue = c.revenue;
    }
    if (maxRevenue == 0) maxRevenue = 1;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = categories[index];
        final progress = (item.revenue / maxRevenue).clamp(0.0, 1.0);

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
                        item.categoryName,
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
                      AnalyticsFormatters.formatCurrency(item.revenue),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Units Sold: ',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      AnalyticsFormatters.formatNumber(item.unitsSold),
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
          ),
        );
      },
    );
  }

  Widget _buildBrandList(List<BrandPerformanceModel> brands) {
    if (brands.isEmpty) {
      return _buildEmptyCard('No brand sales data for this period');
    }

    double maxRevenue = 0;
    for (final b in brands) {
      if (b.revenue > maxRevenue) maxRevenue = b.revenue;
    }
    if (maxRevenue == 0) maxRevenue = 1;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: brands.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = brands[index];
        final progress = (item.revenue / maxRevenue).clamp(0.0, 1.0);

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
                        item.brandName.isEmpty ? 'Unbranded' : item.brandName,
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
                      AnalyticsFormatters.formatCurrency(item.revenue),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.indigo.shade500),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Units Sold: ',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      AnalyticsFormatters.formatNumber(item.unitsSold),
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
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
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
            Icon(Icons.folder_open_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
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
    );
  }
}

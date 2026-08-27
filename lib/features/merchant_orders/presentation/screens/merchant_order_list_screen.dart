import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/merchant_order_list_cubit.dart';
import '../bloc/merchant_order_list_state.dart';
import '../widgets/order_status_badge.dart';

class MerchantOrderListScreen extends StatefulWidget {
  final MerchantOrderListCubit? cubit;
  final Function(String orderId)? onOrderTap;

  const MerchantOrderListScreen({
    super.key,
    this.cubit,
    this.onOrderTap,
  });

  @override
  State<MerchantOrderListScreen> createState() => _MerchantOrderListScreenState();
}

class _MerchantOrderListScreenState extends State<MerchantOrderListScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _selectedStatusFilter;

  final List<Map<String, dynamic>> _statusFilters = const [
    {'label': 'All Orders', 'status': null},
    {'label': 'Placed', 'status': 1},
    {'label': 'Confirmed', 'status': 2},
    {'label': 'Processing', 'status': 7},
    {'label': 'Packed', 'status': 3},
    {'label': 'Shipped', 'status': 4},
    {'label': 'Delivered', 'status': 6},
    {'label': 'Cancelled', 'status': 10},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MerchantOrderListCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = widget.cubit ?? sl<MerchantOrderListCubit>();

    return BlocProvider<MerchantOrderListCubit>.value(
      value: activeCubit..loadOrders(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Processing & Fulfillment'),
        ),
        body: BlocBuilder<MerchantOrderListCubit, MerchantOrderListState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search order number...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      context.read<MerchantOrderListCubit>().searchOrders(query);
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final item = _statusFilters[index];
                      final isSelected = _selectedStatusFilter == item['status'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(item['label'] as String),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedStatusFilter = item['status'] as int?);
                            context.read<MerchantOrderListCubit>().filterByStatus(item['status'] as int?);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MerchantOrderListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'Failed to load orders'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<MerchantOrderListCubit>().refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final orders = state.orders;

    if (orders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MerchantOrderListCubit>().refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: orders.length + (state.isLoadingMore ? 1 : 0),
        padding: const EdgeInsets.all(12.0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final order = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => widget.onOrderTap?.call(order.id),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.orderNumber,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        OrderStatusBadge(
                          status: order.status,
                          statusName: order.statusName,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ₹${order.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment: ${order.paymentStatusName} (${order.paymentMethodName})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

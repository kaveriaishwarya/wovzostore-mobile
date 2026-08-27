import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/merchant_customer_list_cubit.dart';
import '../bloc/merchant_customer_list_state.dart';
import '../widgets/customer_status_chip.dart';

class MerchantCustomerListScreen extends StatefulWidget {
  final MerchantCustomerListCubit? cubit;
  final void Function(String id)? onCustomerTap;

  const MerchantCustomerListScreen({
    super.key,
    this.cubit,
    this.onCustomerTap,
  });

  @override
  State<MerchantCustomerListScreen> createState() => _MerchantCustomerListScreenState();
}

class _MerchantCustomerListScreenState extends State<MerchantCustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final cubit = widget.cubit ?? context.read<MerchantCustomerListCubit>();
      if (!cubit.state.isLoading && cubit.state.hasMore) {
        cubit.loadCustomers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = widget.cubit ?? sl<MerchantCustomerListCubit>();

    return BlocProvider<MerchantCustomerListCubit>.value(
      value: activeCubit..loadCustomers(refresh: true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Directory'),
        ),
        body: BlocBuilder<MerchantCustomerListCubit, MerchantCustomerListState>(
          builder: (context, state) {
            return Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email or phone...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<MerchantCustomerListCubit>().search('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) => context.read<MerchantCustomerListCubit>().search(val),
                  ),
                ),
                // Status Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: state.statusFilter == null,
                        onSelected: (_) => context.read<MerchantCustomerListCubit>().filterByStatus(null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Active'),
                        selected: state.statusFilter == true,
                        onSelected: (_) => context.read<MerchantCustomerListCubit>().filterByStatus(true),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Inactive'),
                        selected: state.statusFilter == false,
                        onSelected: (_) => context.read<MerchantCustomerListCubit>().filterByStatus(false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Main List Content
                Expanded(
                  child: state.isLoading && state.customers.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.isError && state.customers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(state.errorMessage ?? 'Error loading customers'),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => context.read<MerchantCustomerListCubit>().loadCustomers(refresh: true),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : state.customers.isEmpty
                              ? const Center(child: Text('No customers found.'))
                              : RefreshIndicator(
                                  onRefresh: () => context.read<MerchantCustomerListCubit>().loadCustomers(refresh: true),
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: state.customers.length + (state.hasMore ? 1 : 0),
                                    padding: const EdgeInsets.all(12.0),
                                    itemBuilder: (context, index) {
                                      if (index >= state.customers.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }

                                      final customer = state.customers[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Phone: ${customer.phoneNumber}'),
                                              if (customer.email != null && customer.email!.isNotEmpty)
                                                Text('Email: ${customer.email}'),
                                              Text('Orders: ${customer.ordersCount} | Spent: ₹${customer.totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                          trailing: CustomerStatusChip(status: customer.status),
                                          onTap: () => widget.onCustomerTap?.call(customer.id),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

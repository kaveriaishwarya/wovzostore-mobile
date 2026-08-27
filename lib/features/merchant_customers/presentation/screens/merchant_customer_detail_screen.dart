import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../merchant_orders/presentation/widgets/order_status_badge.dart';
import '../bloc/merchant_customer_detail_cubit.dart';
import '../bloc/merchant_customer_detail_state.dart';
import '../widgets/customer_status_chip.dart';

class MerchantCustomerDetailScreen extends StatefulWidget {
  final String customerId;
  final MerchantCustomerDetailCubit? cubit;

  const MerchantCustomerDetailScreen({
    super.key,
    required this.customerId,
    this.cubit,
  });

  @override
  State<MerchantCustomerDetailScreen> createState() => _MerchantCustomerDetailScreenState();
}

class _MerchantCustomerDetailScreenState extends State<MerchantCustomerDetailScreen> {
  void _showEditDialog(BuildContext context, state) {
    final customer = state.customer;
    if (customer == null) return;

    final nameController = TextEditingController(text: customer.fullName);
    final emailController = TextEditingController(text: customer.email ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Customer Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MerchantCustomerDetailCubit>().updateCustomer(
                    customerId: widget.customerId,
                    fullName: nameController.text.trim(),
                    email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStatusConfirmation(BuildContext context, state) {
    final customer = state.customer;
    if (customer == null) return;
    final isCurrentlyActive = customer.status;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isCurrentlyActive ? 'Deactivate Customer?' : 'Activate Customer?'),
        content: Text(
          isCurrentlyActive
              ? 'This customer will be marked as inactive and restricted from placing orders.'
              : 'This customer will be restored to active status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyActive ? Colors.red : Colors.green,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MerchantCustomerDetailCubit>().toggleCustomerStatus(widget.customerId);
            },
            child: Text(isCurrentlyActive ? 'Deactivate' : 'Activate', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = widget.cubit ?? sl<MerchantCustomerDetailCubit>();

    return BlocProvider<MerchantCustomerDetailCubit>.value(
      value: activeCubit..loadCustomerDetails(widget.customerId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Details'),
        ),
        body: BlocConsumer<MerchantCustomerDetailCubit, MerchantCustomerDetailState>(
          listener: (context, state) {
            if (state.actionSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionSuccessMessage!)),
              );
            } else if (state.isError && state.customer != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isError && state.customer == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Error loading customer details'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<MerchantCustomerDetailCubit>().loadCustomerDetails(widget.customerId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final customer = state.customer;
            if (customer == null) {
              return const Center(child: Text('Customer not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Summary Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  customer.fullName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              CustomerStatusChip(status: customer.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Phone: ${customer.phoneNumber}'),
                          if (customer.email != null && customer.email!.isNotEmpty) Text('Email: ${customer.email}'),
                          if (customer.defaultAddress != null) Text('Address: ${customer.defaultAddress}'),
                          const Divider(),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                avatar: Icon(customer.isPhoneVerified ? Icons.verified : Icons.error_outline, size: 16),
                                label: Text(customer.isPhoneVerified ? 'Phone Verified' : 'Phone Unverified'),
                              ),
                              Chip(
                                avatar: Icon(customer.isEmailVerified ? Icons.verified : Icons.error_outline, size: 16),
                                label: Text(customer.isEmailVerified ? 'Email Verified' : 'Email Unverified'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showEditDialog(context, state),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit Profile'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: state.isUpdating ? null : () => _showStatusConfirmation(context, state),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: customer.status ? Colors.red : Colors.green,
                                ),
                                icon: Icon(customer.status ? Icons.block : Icons.check_circle, size: 18, color: Colors.white),
                                label: Text(
                                  customer.status ? 'Deactivate' : 'Activate',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Order History Header
                  Text('Order History (${state.orders.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  state.orders.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No order history available for this customer.')),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.orders.length,
                          itemBuilder: (context, index) {
                            final order = state.orders[index];
                            return Card(
                              child: ListTile(
                                title: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('₹${order.summary.grandTotal.toStringAsFixed(2)} | Items: ${order.items.length}'),
                                trailing: OrderStatusBadge(
                                  status: order.status,
                                  statusName: order.statusName,
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

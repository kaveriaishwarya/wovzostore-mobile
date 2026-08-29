import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/supplier_model.dart';
import '../bloc/merchant_supplier_cubit.dart';
import '../bloc/merchant_supplier_state.dart';

class MerchantSupplierListScreen extends StatefulWidget {
  final MerchantSupplierCubit? cubit;
  final ValueChanged<String>? onSupplierTap;

  const MerchantSupplierListScreen({
    super.key,
    this.cubit,
    this.onSupplierTap,
  });

  @override
  State<MerchantSupplierListScreen> createState() => _MerchantSupplierListScreenState();
}

class _MerchantSupplierListScreenState extends State<MerchantSupplierListScreen> {
  late final MerchantSupplierCubit _cubit;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? sl<MerchantSupplierCubit>();
    _cubit.loadSuppliers();
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
      _cubit.loadMoreSuppliers();
    }
  }

  void _openAddEditSupplierModal({SupplierModel? supplier}) {
    final isEditing = supplier != null;
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final contactController = TextEditingController(text: supplier?.contactPerson ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final addressController = TextEditingController(text: supplier?.address ?? '');
    final gstinController = TextEditingController(text: supplier?.gstin ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isEditing ? 'Edit Supplier' : 'Add Supplier'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Supplier Name *'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact Person'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                TextFormField(
                  controller: gstinController,
                  decoration: const InputDecoration(labelText: 'GSTIN'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                if (isEditing) {
                  final req = UpdateSupplierRequestModel(
                    name: nameController.text.trim(),
                    contactPerson: contactController.text.trim().isEmpty ? null : contactController.text.trim(),
                    email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                    phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                    address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                    gstin: gstinController.text.trim().isEmpty ? null : gstinController.text.trim(),
                  );
                  _cubit.updateSupplier(supplier.id, req);
                } else {
                  final req = CreateSupplierRequestModel(
                    name: nameController.text.trim(),
                    contactPerson: contactController.text.trim().isEmpty ? null : contactController.text.trim(),
                    email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                    phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                    address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                    gstin: gstinController.text.trim().isEmpty ? null : gstinController.text.trim(),
                  );
                  _cubit.createSupplier(req);
                }
                Navigator.pop(dialogCtx);
              }
            },
            child: Text(isEditing ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showActivateDeactivateConfirm(SupplierModel supplier) {
    final isActivating = !supplier.isActive;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isActivating ? 'Activate Supplier' : 'Deactivate Supplier'),
        content: Text(
          isActivating
              ? 'Are you sure you want to activate ${supplier.name}?'
              : 'Are you sure you want to deactivate ${supplier.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActivating ? Colors.green : Colors.red,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (isActivating) {
                _cubit.activateSupplier(supplier.id);
              } else {
                _cubit.deactivateSupplier(supplier.id);
              }
            },
            child: Text(isActivating ? 'Activate' : 'Deactivate', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Suppliers'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Supplier',
              onPressed: () => _openAddEditSupplierModal(),
            ),
          ],
        ),
        body: BlocConsumer<MerchantSupplierCubit, MerchantSupplierState>(
          listener: (context, state) {
            if (state is MerchantSupplierLoaded) {
              if (state.actionSuccessMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.actionSuccessMessage!), backgroundColor: Colors.green),
                );
              }
              if (state.actionError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.actionError!), backgroundColor: Colors.red),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is MerchantSupplierLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MerchantSupplierError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _cubit.loadSuppliers(refresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is MerchantSupplierLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search suppliers...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _cubit.loadSuppliers(search: null, isActive: state.isActiveFilter, refresh: true);
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (val) {
                            _cubit.loadSuppliers(search: val.trim(), isActive: state.isActiveFilter, refresh: true);
                          },
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: state.isActiveFilter == null,
                                onSelected: (_) {
                                  _cubit.loadSuppliers(search: state.search, isActive: null, refresh: true);
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Active'),
                                selected: state.isActiveFilter == true,
                                onSelected: (_) {
                                  _cubit.loadSuppliers(search: state.search, isActive: true, refresh: true);
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Inactive'),
                                selected: state.isActiveFilter == false,
                                onSelected: (_) {
                                  _cubit.loadSuppliers(search: state.search, isActive: false, refresh: true);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.suppliers.isEmpty
                        ? const Center(child: Text('No suppliers found.'))
                        : RefreshIndicator(
                            onRefresh: () => _cubit.loadSuppliers(
                              search: state.search,
                              isActive: state.isActiveFilter,
                              refresh: true,
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: state.suppliers.length + (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= state.suppliers.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final supplier = state.suppliers[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            supplier.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            supplier.isActive ? 'Active' : 'Inactive',
                                            style: const TextStyle(fontSize: 10, color: Colors.white),
                                          ),
                                          backgroundColor: supplier.isActive ? Colors.green : Colors.grey,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (supplier.contactPerson != null)
                                          Text('Contact: ${supplier.contactPerson}'),
                                        if (supplier.phone != null)
                                          Text('Phone: ${supplier.phone}'),
                                        if (supplier.email != null)
                                          Text('Email: ${supplier.email}'),
                                        if (supplier.gstin != null)
                                          Text('GSTIN: ${supplier.gstin}'),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _openAddEditSupplierModal(supplier: supplier);
                                        } else if (val == 'toggle') {
                                          _showActivateDeactivateConfirm(supplier);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(
                                          value: 'toggle',
                                          child: Text(supplier.isActive ? 'Deactivate' : 'Activate'),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      widget.onSupplierTap?.call(supplier.id);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

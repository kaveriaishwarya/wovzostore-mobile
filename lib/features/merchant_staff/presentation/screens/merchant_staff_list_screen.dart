import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/merchant_staff_list_cubit.dart';
import '../bloc/merchant_staff_list_state.dart';
import '../widgets/staff_role_badge.dart';
import 'merchant_staff_detail_screen.dart';

class MerchantStaffListScreen extends StatefulWidget {
  final void Function(String id)? onStaffTap;
  final VoidCallback? onAddStaffTap;

  const MerchantStaffListScreen({
    super.key,
    this.onStaffTap,
    this.onAddStaffTap,
  });

  @override
  State<MerchantStaffListScreen> createState() => _MerchantStaffListScreenState();
}

class _MerchantStaffListScreenState extends State<MerchantStaffListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  bool? _selectedActive;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String query) {
    context.read<MerchantStaffListCubit>().loadStaff(
          page: 1,
          search: query.isEmpty ? null : query,
          role: _selectedRole,
          isActive: _selectedActive,
        );
  }

  void _onRoleFilterChanged(BuildContext context, String? role) {
    setState(() => _selectedRole = role);
    context.read<MerchantStaffListCubit>().loadStaff(
          page: 1,
          search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          role: role,
          isActive: _selectedActive,
        );
  }

  void _onActiveFilterChanged(BuildContext context, bool? active) {
    setState(() => _selectedActive = active);
    context.read<MerchantStaffListCubit>().loadStaff(
          page: 1,
          search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          role: _selectedRole,
          isActive: active,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MerchantStaffListCubit>()..loadStaff(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Staff & Role Management'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<MerchantStaffListCubit>().refresh(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: widget.onAddStaffTap ?? () => _navigateToAddStaff(context),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Staff'),
            ),
            body: Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search staff by name, email or phone...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged(context, '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => _onSearchChanged(context, val),
                  ),
                ),

                // 2. Filter Chips Row (Role & Active Status)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Role Filter Chips
                      FilterChip(
                        label: const Text('All Roles'),
                        selected: _selectedRole == null,
                        onSelected: (_) => _onRoleFilterChanged(context, null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('SuperAdmin'),
                        selected: _selectedRole == 'SuperAdmin',
                        onSelected: (selected) =>
                            _onRoleFilterChanged(context, selected ? 'SuperAdmin' : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Admin'),
                        selected: _selectedRole == 'Admin',
                        onSelected: (selected) =>
                            _onRoleFilterChanged(context, selected ? 'Admin' : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('StoreManager'),
                        selected: _selectedRole == 'StoreManager',
                        onSelected: (selected) =>
                            _onRoleFilterChanged(context, selected ? 'StoreManager' : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Support'),
                        selected: _selectedRole == 'Support',
                        onSelected: (selected) =>
                            _onRoleFilterChanged(context, selected ? 'Support' : null),
                      ),
                      const SizedBox(width: 16),
                      const Text('|', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      // Status Filter Chips
                      FilterChip(
                        label: const Text('All Status'),
                        selected: _selectedActive == null,
                        onSelected: (_) => _onActiveFilterChanged(context, null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Active'),
                        selected: _selectedActive == true,
                        onSelected: (selected) =>
                            _onActiveFilterChanged(context, selected ? true : null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Inactive'),
                        selected: _selectedActive == false,
                        onSelected: (selected) =>
                            _onActiveFilterChanged(context, selected ? false : null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Staff List View
                Expanded(
                  child: BlocBuilder<MerchantStaffListCubit, MerchantStaffListState>(
                    builder: (context, state) {
                      if (state is MerchantStaffListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is MerchantStaffListError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(state.message, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.read<MerchantStaffListCubit>().refresh(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is MerchantStaffListLoaded) {
                        if (state.staff.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No staff members found',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try adjusting your search or filters',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () =>
                              context.read<MerchantStaffListCubit>().refresh(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: state.staff.length,
                            itemBuilder: (context, index) {
                              final staff = state.staff[index];
                              final displayName = (staff.fullName != null && staff.fullName!.isNotEmpty)
                                  ? staff.fullName!
                                  : staff.email;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: staff.isActive
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Colors.grey.shade300,
                                    child: Text(
                                      displayName[0].toUpperCase(),
                                      style: TextStyle(
                                        color: staff.isActive
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      StaffRoleBadge(role: staff.role, isCompact: true),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(staff.email),
                                      if (staff.phoneNumber != null &&
                                          staff.phoneNumber!.isNotEmpty)
                                        Text(staff.phoneNumber!,
                                            style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            staff.isActive
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            size: 14,
                                            color: staff.isActive ? Colors.green : Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            staff.isActive ? 'Active' : 'Inactive',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: staff.isActive ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    if (widget.onStaffTap != null) {
                                      widget.onStaffTap!(staff.id);
                                    } else {
                                      _navigateToStaffDetail(context, staff.id);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToStaffDetail(BuildContext context, String staffId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantStaffDetailScreen(staffId: staffId),
      ),
    );
  }

  void _navigateToAddStaff(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantStaffDetailScreen(staffId: 'new'),
      ),
    );
  }
}

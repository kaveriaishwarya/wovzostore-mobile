import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../data/models/create_staff_request_model.dart';
import '../../data/models/merchant_staff_model.dart';
import '../../data/models/update_staff_request_model.dart';
import '../bloc/merchant_staff_detail_cubit.dart';
import '../bloc/merchant_staff_detail_state.dart';
import '../widgets/staff_role_badge.dart';

class MerchantStaffDetailScreen extends StatefulWidget {
  final String staffId;

  const MerchantStaffDetailScreen({
    super.key,
    required this.staffId,
  });

  @override
  State<MerchantStaffDetailScreen> createState() => _MerchantStaffDetailScreenState();
}

class _MerchantStaffDetailScreenState extends State<MerchantStaffDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'StoreManager';
  bool _isSubmitting = false;

  bool get _isCreateMode => widget.staffId == 'new';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isCurrentUserSuperAdmin(BuildContext context) {
    try {
      final authState = context.read<AuthCubit>().state;
      final role = authState.user?.role.toLowerCase();
      if (role != null) {
        return role == 'superadmin';
      }
    } catch (_) {}
    return true; // Default to true if unconstrained context to permit admin operations
  }

  bool _isCurrentUserAdmin(BuildContext context) {
    try {
      final authState = context.read<AuthCubit>().state;
      final role = authState.user?.role.toLowerCase();
      if (role != null) {
        return role == 'admin';
      }
    } catch (_) {}
    return false;
  }

  List<String> _getAllowedRoleOptions(BuildContext context) {
    if (_isCurrentUserSuperAdmin(context)) {
      return ['SuperAdmin', 'Admin', 'StoreManager', 'Support'];
    }
    // Admins can only assign StoreManager or Support
    return ['StoreManager', 'Support'];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<MerchantStaffDetailCubit>();
        if (!_isCreateMode) {
          cubit.loadStaffDetail(widget.staffId);
        }
        return cubit;
      },
      child: BlocConsumer<MerchantStaffDetailCubit, MerchantStaffDetailState>(
        listener: (context, state) {
          if (state is MerchantStaffDetailActionSuccess) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            if (_isCreateMode) {
              Navigator.of(context).pop();
            }
          } else if (state is MerchantStaffDetailError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSuperAdmin = _isCurrentUserSuperAdmin(context);
          final isAdmin = _isCurrentUserAdmin(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(_isCreateMode ? 'Create New Staff' : 'Staff Profile'),
            ),
            body: _isCreateMode
                ? _buildCreateForm(context, isSuperAdmin, isAdmin)
                : _buildDetailBody(context, state, isSuperAdmin, isAdmin),
          );
        },
      ),
    );
  }

  Widget _buildCreateForm(BuildContext context, bool isSuperAdmin, bool isAdmin) {
    final allowedRoles = _getAllowedRoleOptions(context);
    if (!allowedRoles.contains(_selectedRole)) {
      _selectedRole = allowedRoles.first;
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Add Staff Member',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create an identity account for a store team member with assigned role permissions.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number (Optional)',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Assigned Role *',
              prefixIcon: Icon(Icons.admin_panel_settings),
              border: OutlineInputBorder(),
            ),
            items: allowedRoles.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),
          if (isAdmin) ...[
            const SizedBox(height: 6),
            const Text(
              'Note: Admin users are permitted to create StoreManager and Support staff only.',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Initial Password *',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => _submitCreateStaff(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Staff Member', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _submitCreateStaff(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final request = CreateStaffRequestModel(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      role: _selectedRole,
      password: _passwordController.text,
    );

    context.read<MerchantStaffDetailCubit>().createStaff(request);
  }

  Widget _buildDetailBody(
      BuildContext context, MerchantStaffDetailState state, bool isSuperAdmin, bool isAdmin) {
    if (state is MerchantStaffDetailLoading && !_isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MerchantStaffDetailError) {
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
                  context.read<MerchantStaffDetailCubit>().loadStaffDetail(widget.staffId),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    MerchantStaffModel? staff;
    if (state is MerchantStaffDetailLoaded) {
      staff = state.staff;
    } else if (state is MerchantStaffDetailActionSuccess) {
      staff = state.updatedStaff;
    }

    if (staff == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isTargetAdminOrSuperAdmin =
        staff.role == 'Admin' || staff.role == 'SuperAdmin';
    final isRestrictedForAdmin = isAdmin && isTargetAdminOrSuperAdmin;

    final displayName = (staff.fullName != null && staff.fullName!.isNotEmpty)
        ? staff.fullName!
        : staff.email;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Profile Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: staff.isActive
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey.shade300,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: staff.isActive
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(staff.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StaffRoleBadge(role: staff.role),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: staff.isActive ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        staff.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: staff.isActive ? Colors.green.shade900 : Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Restricted Warning Banner for Admins trying to view Admin/SuperAdmin
        if (isRestrictedForAdmin)
          Card(
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.shade400),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.amber.shade900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Admin Security Policy: Only SuperAdmins are permitted to modify Admin or SuperAdmin accounts.',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isRestrictedForAdmin) const SizedBox(height: 16),

        // Details Breakdown Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('User ID'),
                subtitle: Text(staff.id, style: const TextStyle(fontSize: 12)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email Address'),
                subtitle: Text(staff.email),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone Number'),
                subtitle: Text(staff.phoneNumber ?? 'Not provided'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Account Created'),
                subtitle: Text(staff.createdAt.toLocal().toString().split('.')[0]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Actions
        if (!isRestrictedForAdmin) ...[
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () => _showEditStaffDialog(context, staff!),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile & Role'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          if (staff.isActive)
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : () => _confirmDeactivateStaff(context, staff!),
              icon: const Icon(Icons.block, color: Colors.red),
              label: const Text('Deactivate Staff Account', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : () => _confirmActivateStaff(context, staff!),
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              label: const Text('Activate Staff Account', style: TextStyle(color: Colors.green)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ],
    ),
  );
}

  void _showEditStaffDialog(BuildContext context, MerchantStaffModel staff) {
    final editFormKey = GlobalKey<FormState>();
    final editNameController = TextEditingController(text: staff.fullName);
    final editPhoneController = TextEditingController(text: staff.phoneNumber);
    String editRole = staff.role;

    final allowedRoles = _getAllowedRoleOptions(context);
    if (!allowedRoles.contains(editRole)) {
      editRole = allowedRoles.first;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Edit Staff Profile'),
          content: Form(
            key: editFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: editNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: editPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: editRole,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Role *',
                      border: OutlineInputBorder(),
                    ),
                    items: allowedRoles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) editRole = val;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!editFormKey.currentState!.validate()) return;
                Navigator.of(dialogCtx).pop();
                setState(() => _isSubmitting = true);

                final request = UpdateStaffRequestModel(
                  fullName: editNameController.text.trim(),
                  phoneNumber: editPhoneController.text.trim().isEmpty
                      ? null
                      : editPhoneController.text.trim(),
                  role: editRole,
                );

                context.read<MerchantStaffDetailCubit>().updateStaff(staff.id, request);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _confirmActivateStaff(BuildContext context, MerchantStaffModel staff) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Activate Account'),
        content: Text('Are you sure you want to activate staff member "${staff.email}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              setState(() => _isSubmitting = true);
              context.read<MerchantStaffDetailCubit>().activateStaff(staff.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Activate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivateStaff(BuildContext context, MerchantStaffModel staff) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: Text(
          'Are you sure you want to deactivate staff member "${staff.email}"?\n\n'
          'This will immediately lock out their account and revoke active sessions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              setState(() => _isSubmitting = true);
              context.read<MerchantStaffDetailCubit>().deactivateStaff(staff.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

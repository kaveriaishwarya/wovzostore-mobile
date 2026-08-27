import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/store_settings_model.dart';
import '../cubit/merchant_settings_cubit.dart';
import '../cubit/merchant_settings_state.dart';

class MerchantSettingsScreen extends StatefulWidget {
  final MerchantSettingsCubit? cubit;

  const MerchantSettingsScreen({
    super.key,
    this.cubit,
  });

  @override
  State<MerchantSettingsScreen> createState() => _MerchantSettingsScreenState();
}

class _MerchantSettingsScreenState extends State<MerchantSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // General controllers
  late final TextEditingController _storeNameController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _supportEmailController;
  late final TextEditingController _supportPhoneController;
  late final TextEditingController _minOrderAmountForCodController;

  // Delivery controllers
  late final TextEditingController _flatDeliveryChargeController;
  late final TextEditingController _freeDeliveryThresholdController;
  late final TextEditingController _estimatedDeliveryDaysController;
  late final TextEditingController _servicablePinCodesController;

  // Return controllers
  late final TextEditingController _returnWindowDaysController;
  late final TextEditingController _replaceWindowDaysController;
  late final TextEditingController _policyTextController;

  bool _codEnabled = true;
  bool _returnAllowed = true;
  String _defaultCurrency = 'INR';
  DateTime? _createdAt;
  DateTime? _updatedAt;

  bool _isFormInitialized = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _logoUrlController = TextEditingController();
    _supportEmailController = TextEditingController();
    _supportPhoneController = TextEditingController();
    _minOrderAmountForCodController = TextEditingController();

    _flatDeliveryChargeController = TextEditingController();
    _freeDeliveryThresholdController = TextEditingController();
    _estimatedDeliveryDaysController = TextEditingController();
    _servicablePinCodesController = TextEditingController();

    _returnWindowDaysController = TextEditingController();
    _replaceWindowDaysController = TextEditingController();
    _policyTextController = TextEditingController();

    final activeCubit = widget.cubit ?? (sl.isRegistered<MerchantSettingsCubit>() ? sl<MerchantSettingsCubit>() : null);
    activeCubit?.loadSettings();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _logoUrlController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    _minOrderAmountForCodController.dispose();

    _flatDeliveryChargeController.dispose();
    _freeDeliveryThresholdController.dispose();
    _estimatedDeliveryDaysController.dispose();
    _servicablePinCodesController.dispose();

    _returnWindowDaysController.dispose();
    _replaceWindowDaysController.dispose();
    _policyTextController.dispose();
    super.dispose();
  }

  void _populateForm(StoreSettingsModel settings) {
    _storeNameController.text = settings.storeName;
    _logoUrlController.text = settings.logoUrl ?? '';
    _supportEmailController.text = settings.supportEmail ?? '';
    _supportPhoneController.text = settings.supportPhone ?? '';
    _codEnabled = settings.codEnabled;
    _minOrderAmountForCodController.text = settings.minOrderAmountForCod.toString();
    _defaultCurrency = settings.defaultCurrency;

    _flatDeliveryChargeController.text = settings.flatDeliveryCharge.toString();
    _freeDeliveryThresholdController.text = settings.freeDeliveryThreshold?.toString() ?? '';
    _estimatedDeliveryDaysController.text = settings.estimatedDeliveryDays.toString();
    _servicablePinCodesController.text = settings.servicablePinCodes ?? '';

    _returnAllowed = settings.returnAllowed;
    _returnWindowDaysController.text = settings.returnWindowDays.toString();
    _replaceWindowDaysController.text = settings.replaceWindowDays.toString();
    _policyTextController.text = settings.policyText ?? '';

    _createdAt = settings.createdAt;
    _updatedAt = settings.updatedAt;

    _isFormInitialized = true;
  }

  void _saveSettings(BuildContext context, MerchantSettingsCubit cubit) {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the validation errors in the form')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final model = StoreSettingsModel(
      storeName: _storeNameController.text.trim(),
      logoUrl: _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      supportEmail: _supportEmailController.text.trim().isEmpty ? null : _supportEmailController.text.trim(),
      supportPhone: _supportPhoneController.text.trim().isEmpty ? null : _supportPhoneController.text.trim(),
      codEnabled: _codEnabled,
      minOrderAmountForCod: double.tryParse(_minOrderAmountForCodController.text.trim()) ?? 0.0,
      defaultCurrency: _defaultCurrency,
      flatDeliveryCharge: double.tryParse(_flatDeliveryChargeController.text.trim()) ?? 0.0,
      freeDeliveryThreshold: _freeDeliveryThresholdController.text.trim().isEmpty
          ? null
          : double.tryParse(_freeDeliveryThresholdController.text.trim()),
      estimatedDeliveryDays: int.tryParse(_estimatedDeliveryDaysController.text.trim()) ?? 0,
      servicablePinCodes: _servicablePinCodesController.text.trim().isEmpty
          ? null
          : _servicablePinCodesController.text.trim(),
      returnAllowed: _returnAllowed,
      returnWindowDays: int.tryParse(_returnWindowDaysController.text.trim()) ?? 0,
      replaceWindowDays: int.tryParse(_replaceWindowDaysController.text.trim()) ?? 0,
      policyText: _policyTextController.text.trim().isEmpty ? null : _policyTextController.text.trim(),
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: _updatedAt,
    );

    cubit.updateSettings(model);
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = widget.cubit ?? sl<MerchantSettingsCubit>();
    final theme = Theme.of(context);

    return BlocProvider<MerchantSettingsCubit>.value(
      value: activeCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Store Settings'),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Settings',
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _isFormInitialized = false;
                        });
                        ctx.read<MerchantSettingsCubit>().loadSettings();
                      },
              ),
            ),
          ],
        ),
        body: BlocConsumer<MerchantSettingsCubit, MerchantSettingsState>(
          listener: (context, state) {
            if (state is MerchantSettingsUpdateSuccess) {
              setState(() {
                _isSubmitting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Store settings updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is MerchantSettingsError) {
              setState(() {
                _isSubmitting = false;
              });
              if (_isFormInitialized) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else if (state is MerchantSettingsLoaded) {
              setState(() {
                _isSubmitting = false;
                if (!_isFormInitialized) {
                  _populateForm(state.settings);
                }
              });
            }
          },
          builder: (context, state) {
            if (state is MerchantSettingsLoading && !_isFormInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MerchantSettingsError && !_isFormInitialized) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.read<MerchantSettingsCubit>().loadSettings(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: General Settings
                    _buildSectionCard(
                      context,
                      title: 'General Settings',
                      icon: Icons.storefront_outlined,
                      children: [
                        TextFormField(
                          key: const Key('store_name_input'),
                          controller: _storeNameController,
                          decoration: const InputDecoration(
                            labelText: 'Store Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Store name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('logo_url_input'),
                          controller: _logoUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Logo URL',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.image_outlined),
                            hintText: 'https://example.com/store-logo.png',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('support_email_input'),
                          controller: _supportEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Support Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Enter a valid email address';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('support_phone_input'),
                          controller: _supportPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Support Phone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          key: const Key('cod_enabled_switch'),
                          title: const Text('Cash on Delivery (COD)'),
                          subtitle: const Text('Allow customers to pay cash upon delivery'),
                          value: _codEnabled,
                          onChanged: (val) {
                            setState(() {
                              _codEnabled = val;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_codEnabled) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('min_cod_amount_input'),
                            controller: _minOrderAmountForCodController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Min Order Amount for COD (₹)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty) {
                                final parsed = double.tryParse(val.trim());
                                if (parsed == null || parsed < 0) {
                                  return 'Must be a valid non-negative number';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _defaultCurrency,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Default Currency',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money),
                            helperText: 'Fixed system currency',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Delivery Settings
                    _buildSectionCard(
                      context,
                      title: 'Delivery & Shipping Configuration',
                      icon: Icons.local_shipping_outlined,
                      children: [
                        TextFormField(
                          key: const Key('flat_delivery_charge_input'),
                          controller: _flatDeliveryChargeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Flat Delivery Charge (₹) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_rupee),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Flat delivery charge is required';
                            }
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed < 0) {
                              return 'Must be a valid non-negative number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('free_delivery_threshold_input'),
                          controller: _freeDeliveryThresholdController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Free Delivery Threshold (₹)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_offer_outlined),
                            hintText: 'e.g. 500 (leave empty for none)',
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final parsed = double.tryParse(val.trim());
                              if (parsed == null || parsed < 0) {
                                return 'Must be a valid non-negative number';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('estimated_delivery_days_input'),
                          controller: _estimatedDeliveryDaysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Estimated Delivery Time (Days) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Estimated delivery days is required';
                            }
                            final parsed = int.tryParse(val.trim());
                            if (parsed == null || parsed < 0) {
                              return 'Must be a valid non-negative integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('servicable_pin_codes_input'),
                          controller: _servicablePinCodesController,
                          decoration: const InputDecoration(
                            labelText: 'Serviceable PIN Codes',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pin_drop_outlined),
                            hintText: 'Comma separated e.g. 110001, 110002 (empty = all)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Return & Replacement Policy
                    _buildSectionCard(
                      context,
                      title: 'Return & Replacement Policy',
                      icon: Icons.assignment_return_outlined,
                      children: [
                        SwitchListTile(
                          key: const Key('return_allowed_switch'),
                          title: const Text('Allow Returns'),
                          subtitle: const Text('Enable customers to initiate return requests'),
                          value: _returnAllowed,
                          onChanged: (val) {
                            setState(() {
                              _returnAllowed = val;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: const Key('return_window_days_input'),
                          controller: _returnWindowDaysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Return Window (Days) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Return window days is required';
                            }
                            final parsed = int.tryParse(val.trim());
                            if (parsed == null || parsed < 0) {
                              return 'Must be a valid non-negative integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('replace_window_days_input'),
                          controller: _replaceWindowDaysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Replacement Window (Days) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.change_circle_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Replacement window days is required';
                            }
                            final parsed = int.tryParse(val.trim());
                            if (parsed == null || parsed < 0) {
                              return 'Must be a valid non-negative integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('policy_text_input'),
                          controller: _policyTextController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Policy Details / Notes',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description_outlined),
                            hintText: 'Terms and conditions for returns and replacements...',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    FilledButton.icon(
                      key: const Key('save_settings_button'),
                      onPressed: _isSubmitting
                          ? null
                          : () => _saveSettings(context, context.read<MerchantSettingsCubit>()),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSubmitting ? 'Saving Settings...' : 'Save Settings'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../data/models/store_settings_model.dart';
import '../cubit/merchant_settings_cubit.dart';
import '../cubit/merchant_settings_state.dart';

class MerchantSettingsScreen extends StatefulWidget {
  final MerchantSettingsCubit? cubit;
  final bool? isReadOnly;

  const MerchantSettingsScreen({
    super.key,
    this.cubit,
    this.isReadOnly,
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

  // GST & Business Identity controllers
  late final TextEditingController _gstinController;
  late final TextEditingController _legalNameController;
  late final TextEditingController _panNumberController;
  late final TextEditingController _stateCodeController;
  late final TextEditingController _stateNameController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _pinCodeController;
  late final TextEditingController _invoicePrefixController;

  // Bank details controllers
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankAccountNumberController;
  late final TextEditingController _bankIfscCodeController;

  bool _codEnabled = true;
  bool _returnAllowed = true;
  String _defaultCurrency = 'INR';
  DateTime? _createdAt;
  DateTime? _updatedAt;

  bool _isFormInitialized = false;
  bool _isSubmitting = false;

  static const List<Map<String, String>> _indianStates = [
    {'code': '01', 'name': 'Jammu and Kashmir'},
    {'code': '02', 'name': 'Himachal Pradesh'},
    {'code': '03', 'name': 'Punjab'},
    {'code': '04', 'name': 'Chandigarh'},
    {'code': '05', 'name': 'Uttarakhand'},
    {'code': '06', 'name': 'Haryana'},
    {'code': '07', 'name': 'Delhi'},
    {'code': '08', 'name': 'Rajasthan'},
    {'code': '09', 'name': 'Uttar Pradesh'},
    {'code': '10', 'name': 'Bihar'},
    {'code': '11', 'name': 'Sikkim'},
    {'code': '12', 'name': 'Arunachal Pradesh'},
    {'code': '13', 'name': 'Nagaland'},
    {'code': '14', 'name': 'Manipur'},
    {'code': '15', 'name': 'Mizoram'},
    {'code': '16', 'name': 'Tripura'},
    {'code': '17', 'name': 'Meghalaya'},
    {'code': '18', 'name': 'Assam'},
    {'code': '19', 'name': 'West Bengal'},
    {'code': '20', 'name': 'Jharkhand'},
    {'code': '21', 'name': 'Odisha'},
    {'code': '22', 'name': 'Chhattisgarh'},
    {'code': '23', 'name': 'Madhya Pradesh'},
    {'code': '24', 'name': 'Gujarat'},
    {'code': '26', 'name': 'Dadra & Nagar Haveli and Daman & Diu'},
    {'code': '27', 'name': 'Maharashtra'},
    {'code': '28', 'name': 'Andhra Pradesh (Old)'},
    {'code': '29', 'name': 'Karnataka'},
    {'code': '30', 'name': 'Goa'},
    {'code': '31', 'name': 'Lakshadweep'},
    {'code': '32', 'name': 'Kerala'},
    {'code': '33', 'name': 'Tamil Nadu'},
    {'code': '34', 'name': 'Puducherry'},
    {'code': '35', 'name': 'Andaman and Nicobar Islands'},
    {'code': '36', 'name': 'Telangana'},
    {'code': '37', 'name': 'Andhra Pradesh'},
    {'code': '38', 'name': 'Ladakh'},
  ];

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

    _gstinController = TextEditingController();
    _legalNameController = TextEditingController();
    _panNumberController = TextEditingController();
    _stateCodeController = TextEditingController();
    _stateNameController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _pinCodeController = TextEditingController();
    _invoicePrefixController = TextEditingController(text: 'INV-');

    _bankNameController = TextEditingController();
    _bankAccountNumberController = TextEditingController();
    _bankIfscCodeController = TextEditingController();

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

    _gstinController.dispose();
    _legalNameController.dispose();
    _panNumberController.dispose();
    _stateCodeController.dispose();
    _stateNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _invoicePrefixController.dispose();

    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankIfscCodeController.dispose();
    super.dispose();
  }

  bool _computeReadOnly(BuildContext context) {
    if (widget.isReadOnly == true) return true;
    try {
      if (sl.isRegistered<AuthCubit>()) {
        final authState = sl<AuthCubit>().state;
        if (authState.user != null && authState.user!.role == 'StoreManager') {
          return true;
        }
      }
    } catch (_) {}
    return false;
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

    _gstinController.text = settings.gstin ?? '';
    _legalNameController.text = settings.legalName ?? '';
    _panNumberController.text = settings.panNumber ?? '';
    _stateCodeController.text = settings.stateCode ?? '';
    _stateNameController.text = settings.stateName ?? '';
    _addressLine1Controller.text = settings.addressLine1 ?? '';
    _addressLine2Controller.text = settings.addressLine2 ?? '';
    _cityController.text = settings.city ?? '';
    _pinCodeController.text = settings.pinCode ?? '';
    _invoicePrefixController.text = settings.invoicePrefix.isEmpty ? 'INV-' : settings.invoicePrefix;

    _bankNameController.text = settings.bankName ?? '';
    _bankAccountNumberController.text = settings.bankAccountNumber ?? '';
    _bankIfscCodeController.text = settings.bankIfscCode ?? '';

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
      gstin: _gstinController.text.trim().isEmpty ? null : _gstinController.text.trim().toUpperCase(),
      legalName: _legalNameController.text.trim().isEmpty ? null : _legalNameController.text.trim(),
      panNumber: _panNumberController.text.trim().isEmpty ? null : _panNumberController.text.trim().toUpperCase(),
      stateCode: _stateCodeController.text.trim().isEmpty ? null : _stateCodeController.text.trim(),
      stateName: _stateNameController.text.trim().isEmpty ? null : _stateNameController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim().isEmpty ? null : _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isEmpty ? null : _addressLine2Controller.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      pinCode: _pinCodeController.text.trim().isEmpty ? null : _pinCodeController.text.trim(),
      bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
      bankAccountNumber: _bankAccountNumberController.text.trim().isEmpty ? null : _bankAccountNumberController.text.trim(),
      bankIfscCode: _bankIfscCodeController.text.trim().isEmpty ? null : _bankIfscCodeController.text.trim().toUpperCase(),
      invoicePrefix: _invoicePrefixController.text.trim().isEmpty ? 'INV-' : _invoicePrefixController.text.trim().toUpperCase(),
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: _updatedAt,
    );

    cubit.updateSettings(model);
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = widget.cubit ?? sl<MerchantSettingsCubit>();
    final theme = Theme.of(context);
    final isReadOnly = _computeReadOnly(context);

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
                    if (isReadOnly) ...[
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.amber.shade900),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'View-Only Access: Store Managers cannot modify store settings or GST details.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Section 1: General Settings
                    _buildSectionCard(
                      context,
                      title: 'General Settings',
                      icon: Icons.storefront_outlined,
                      children: [
                        TextFormField(
                          key: const Key('store_name_input'),
                          controller: _storeNameController,
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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
                          onChanged: isReadOnly
                              ? null
                              : (val) {
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
                            readOnly: isReadOnly,
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

                    // Section 2: GST & Business Identity
                    _buildSectionCard(
                      context,
                      title: 'GST & Business Identity Configuration',
                      icon: Icons.receipt_long_outlined,
                      children: [
                        TextFormField(
                          key: const Key('gstin_input'),
                          controller: _gstinController,
                          readOnly: isReadOnly,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'GSTIN (15-digit GST Number)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.verified_outlined),
                            hintText: '27AAAAA0000A1Z5',
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (val.trim().length != 15) {
                                return 'GSTIN must be exactly 15 characters';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('legal_name_input'),
                          controller: _legalNameController,
                          readOnly: isReadOnly,
                          decoration: const InputDecoration(
                            labelText: 'Legal Business Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.gavel_outlined),
                            hintText: 'As registered with GST authority',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: const Key('pan_number_input'),
                                controller: _panNumberController,
                                readOnly: isReadOnly,
                                textCapitalization: TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  labelText: 'PAN Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  hintText: 'AAAAA0000A',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                key: const Key('invoice_prefix_input'),
                                controller: _invoicePrefixController,
                                readOnly: isReadOnly,
                                textCapitalization: TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  labelText: 'Invoice Prefix',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.tag),
                                  hintText: 'INV-',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: const Key('state_code_dropdown'),
                          isExpanded: true,
                          initialValue: _stateCodeController.text.isNotEmpty ? _stateCodeController.text : null,
                          decoration: const InputDecoration(
                            labelText: 'Merchant State (GST Place of Supply)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                          items: _indianStates.map((st) {
                            return DropdownMenuItem(
                              value: st['code'],
                              child: Text(
                                '${st['code']} - ${st['name']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: isReadOnly
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() {
                                      _stateCodeController.text = val;
                                      final matched = _indianStates.firstWhere(
                                        (s) => s['code'] == val,
                                        orElse: () => {'name': ''},
                                      );
                                      _stateNameController.text = matched['name']!;
                                    });
                                  }
                                },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('address_line1_input'),
                          controller: _addressLine1Controller,
                          readOnly: isReadOnly,
                          decoration: const InputDecoration(
                            labelText: 'Registered Address Line 1',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('address_line2_input'),
                          controller: _addressLine2Controller,
                          readOnly: isReadOnly,
                          decoration: const InputDecoration(
                            labelText: 'Address Line 2 (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: const Key('city_input'),
                                controller: _cityController,
                                readOnly: isReadOnly,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_city_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                key: const Key('pin_code_input'),
                                controller: _pinCodeController,
                                readOnly: isReadOnly,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'PIN Code',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.pin_drop_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Bank Account Details
                    _buildSectionCard(
                      context,
                      title: 'Bank Account Details (Invoice Display)',
                      icon: Icons.account_balance_outlined,
                      children: [
                        TextFormField(
                          key: const Key('bank_name_input'),
                          controller: _bankNameController,
                          readOnly: isReadOnly,
                          decoration: const InputDecoration(
                            labelText: 'Bank Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance),
                            hintText: 'HDFC Bank / State Bank of India',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('bank_account_number_input'),
                          controller: _bankAccountNumberController,
                          readOnly: isReadOnly,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Bank Account Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.credit_card_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('bank_ifsc_code_input'),
                          controller: _bankIfscCodeController,
                          readOnly: isReadOnly,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'IFSC Code',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.code),
                            hintText: 'HDFC0001234',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 4: Delivery Settings
                    _buildSectionCard(
                      context,
                      title: 'Delivery & Shipping Configuration',
                      icon: Icons.local_shipping_outlined,
                      children: [
                        TextFormField(
                          key: const Key('flat_delivery_charge_input'),
                          controller: _flatDeliveryChargeController,
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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

                    // Section 5: Return & Replacement Policy
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
                          onChanged: isReadOnly
                              ? null
                              : (val) {
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
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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
                          readOnly: isReadOnly,
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
                      onPressed: (_isSubmitting || isReadOnly)
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../catalog/data/models/product_model.dart';
import '../bloc/merchant_product_form_cubit.dart';
import '../bloc/merchant_product_form_state.dart';
import '../../data/models/create_product_request_model.dart';
import '../../data/models/update_product_request_model.dart';

class MerchantProductFormScreen extends StatefulWidget {
  final ProductModel? existingProduct;
  final MerchantProductFormCubit? cubit;

  const MerchantProductFormScreen({
    super.key,
    this.existingProduct,
    this.cubit,
  });

  @override
  State<MerchantProductFormScreen> createState() => _MerchantProductFormScreenState();
}

class _MerchantProductFormScreenState extends State<MerchantProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _categoryIdController;
  late TextEditingController _basePriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  bool _isFeatured = false;

  bool get isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingProduct?.name ?? '');
    _slugController = TextEditingController(text: widget.existingProduct?.slug ?? '');
    _categoryIdController = TextEditingController(text: widget.existingProduct?.categoryId ?? '');
    _basePriceController = TextEditingController(text: widget.existingProduct?.basePrice.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.existingProduct?.description ?? '');
    _tagsController = TextEditingController(text: widget.existingProduct?.tags ?? '');
    _isFeatured = widget.existingProduct?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _categoryIdController.dispose();
    _basePriceController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final slug = _slugController.text.trim();
    final categoryId = _categoryIdController.text.trim();
    final basePrice = double.tryParse(_basePriceController.text.trim()) ?? 0.0;
    final description = _descriptionController.text.trim();
    final tags = _tagsController.text.trim();

    if (isEditing) {
      context.read<MerchantProductFormCubit>().updateProduct(
            widget.existingProduct!.id,
            UpdateProductRequestModel(
              id: widget.existingProduct!.id,
              name: name,
              slug: slug,
              categoryId: categoryId,
              basePrice: basePrice,
              description: description.isEmpty ? null : description,
              tags: tags.isEmpty ? null : tags,
              isFeatured: _isFeatured,
            ),
          );
    } else {
      context.read<MerchantProductFormCubit>().createProduct(
            CreateProductRequestModel(
              name: name,
              categoryId: categoryId,
              basePrice: basePrice,
              slug: slug.isEmpty ? null : slug,
              description: description.isEmpty ? null : description,
              tags: tags.isEmpty ? null : tags,
              isFeatured: _isFeatured,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = widget.cubit ?? sl<MerchantProductFormCubit>();

    return BlocProvider<MerchantProductFormCubit>.value(
      value: activeCubit,
      child: BlocConsumer<MerchantProductFormCubit, MerchantProductFormState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEditing ? 'Product updated successfully' : 'Product created successfully')),
            );
            Navigator.of(context).pop();
          } else if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Operation failed')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name *', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryIdController,
                      decoration: const InputDecoration(labelText: 'Category ID *', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _basePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Base Price (₹) *', border: OutlineInputBorder()),
                      validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid price' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _slugController,
                      decoration: const InputDecoration(labelText: 'URL Slug', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(labelText: 'Tags (comma separated)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Featured Product'),
                      value: _isFeatured,
                      onChanged: (val) => setState(() => _isFeatured = val),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting ? null : () => _submit(context),
                        child: state.isSubmitting
                            ? const CircularProgressIndicator()
                            : Text(isEditing ? 'Save Changes' : 'Create Product'),
                      ),
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

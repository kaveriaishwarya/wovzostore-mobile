import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../catalog/data/models/brand_model.dart';
import '../../../catalog/data/models/category_model.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../bloc/merchant_product_form_cubit.dart';
import '../bloc/merchant_product_form_state.dart';
import '../../data/models/create_product_request_model.dart';
import '../../data/models/update_product_request_model.dart';
import '../widgets/variant_editor_tile.dart';

class MerchantProductFormScreen extends StatefulWidget {
  final ProductModel? existingProduct;
  final MerchantProductFormCubit? cubit;
  final CatalogRepository? catalogRepository;

  const MerchantProductFormScreen({
    super.key,
    this.existingProduct,
    this.cubit,
    this.catalogRepository,
  });

  @override
  State<MerchantProductFormScreen> createState() => _MerchantProductFormScreenState();
}

class _MerchantProductFormScreenState extends State<MerchantProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _basePriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;

  String? _selectedCategoryId;
  String? _selectedBrandId;
  bool _isFeatured = false;

  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  bool _isLoadingDropdowns = true;

  bool get isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingProduct?.name ?? '');
    _slugController = TextEditingController(text: widget.existingProduct?.slug ?? '');
    _basePriceController = TextEditingController(text: widget.existingProduct?.basePrice.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.existingProduct?.description ?? '');
    _tagsController = TextEditingController(text: widget.existingProduct?.tags ?? '');
    _selectedCategoryId = widget.existingProduct?.categoryId;
    _selectedBrandId = widget.existingProduct?.brandId;
    _isFeatured = widget.existingProduct?.isFeatured ?? false;

    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    final repo = widget.catalogRepository ?? sl<CatalogRepository>();
    try {
      final categories = await repo.getCategories();
      final brands = await repo.getBrands();
      if (mounted) {
        setState(() {
          _categories = categories;
          _brands = brands;
          _isLoadingDropdowns = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingDropdowns = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _basePriceController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final slug = _slugController.text.trim();
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
              categoryId: _selectedCategoryId!,
              brandId: _selectedBrandId,
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
              categoryId: _selectedCategoryId!,
              brandId: _selectedBrandId,
              basePrice: basePrice,
              slug: slug.isEmpty ? null : slug,
              description: description.isEmpty ? null : description,
              tags: tags.isEmpty ? null : tags,
              isFeatured: _isFeatured,
            ),
          );
    }
  }

  void _showLifecycleDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
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
              actions: isEditing
                  ? [
                      PopupMenuButton<String>(
                        onSelected: (val) {
                          final id = widget.existingProduct!.id;
                          final cubit = context.read<MerchantProductFormCubit>();
                          if (val == 'publish') {
                            _showLifecycleDialog(context, 'Publish Product', 'Make this product active for customers?', () => cubit.publishProduct(id));
                          } else if (val == 'unpublish') {
                            _showLifecycleDialog(context, 'Unpublish Product', 'Hide this product from customer storefront?', () => cubit.unpublishProduct(id));
                          } else if (val == 'archive') {
                            _showLifecycleDialog(context, 'Archive Product', 'Archive this product?', () => cubit.archiveProduct(id));
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'publish', child: Text('Publish')),
                          const PopupMenuItem(value: 'unpublish', child: Text('Unpublish')),
                          const PopupMenuItem(value: 'archive', child: Text('Archive')),
                        ],
                      ),
                    ]
                  : null,
            ),
            body: _isLoadingDropdowns
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
                            items: _categories.map((c) {
                              return DropdownMenuItem(value: c.id, child: Text(c.name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCategoryId = val),
                            validator: (val) => val == null ? 'Please select a category' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedBrandId,
                            decoration: const InputDecoration(labelText: 'Brand (Optional)', border: OutlineInputBorder()),
                            items: _brands.map((b) {
                              return DropdownMenuItem(value: b.id, child: Text(b.name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedBrandId = val),
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
                          if (isEditing) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Variants', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                TextButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Variant'),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => VariantEditorDialog(
                                        productId: widget.existingProduct!.id,
                                        cubit: context.read<MerchantProductFormCubit>(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            ...widget.existingProduct!.variants.map((v) {
                              return VariantListTile(
                                variant: v,
                                onAdjustStock: () {},
                              );
                            }),
                          ],
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

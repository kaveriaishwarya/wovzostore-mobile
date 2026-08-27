class AddVariantRequestModel {
  final String sku;
  final String name;
  final double price;
  final double? compareAtPrice;
  final double? weight;
  final String? dimensions;
  final String? imageUrl;
  final String? attributes;

  const AddVariantRequestModel({
    required this.sku,
    required this.name,
    required this.price,
    this.compareAtPrice,
    this.weight,
    this.dimensions,
    this.imageUrl,
    this.attributes,
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'price': price,
      if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
      if (weight != null) 'weight': weight,
      if (dimensions != null) 'dimensions': dimensions,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (attributes != null) 'attributes': attributes,
    };
  }
}

class CreateProductRequestModel {
  final String name;
  final String categoryId;
  final double basePrice;
  final String? slug;
  final String? brandId;
  final String? description;
  final String? shortDescription;
  final String? tags;
  final bool isFeatured;
  final List<AddVariantRequestModel>? initialVariants;

  const CreateProductRequestModel({
    required this.name,
    required this.categoryId,
    required this.basePrice,
    this.slug,
    this.brandId,
    this.description,
    this.shortDescription,
    this.tags,
    this.isFeatured = false,
    this.initialVariants,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'basePrice': basePrice,
      if (slug != null && slug!.isNotEmpty) 'slug': slug,
      if (brandId != null && brandId!.isNotEmpty) 'brandId': brandId,
      if (description != null) 'description': description,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (tags != null) 'tags': tags,
      'isFeatured': isFeatured,
      if (initialVariants != null && initialVariants!.isNotEmpty)
        'initialVariants': initialVariants!.map((v) => v.toJson()).toList(),
    };
  }
}

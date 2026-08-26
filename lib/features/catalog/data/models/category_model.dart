class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final String? parentCategoryId;
  final int sortOrder;
  final bool isActive;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.parentCategoryId,
    required this.sortOrder,
    required this.isActive,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      parentCategoryId: json['parentCategoryId'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      children: json['children'] != null
          ? (json['children'] as List<dynamic>)
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'imageUrl': imageUrl,
      'parentCategoryId': parentCategoryId,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}

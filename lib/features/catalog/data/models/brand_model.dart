class BrandModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final bool isActive;

  const BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    required this.isActive,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'isActive': isActive,
    };
  }
}

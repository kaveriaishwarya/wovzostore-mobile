class StoreDto {
  final String id;
  final String name;
  final String slug;
  final String role;

  const StoreDto({
    required this.id,
    required this.name,
    required this.slug,
    required this.role,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) {
    return StoreDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Customer',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'role': role,
      };
}

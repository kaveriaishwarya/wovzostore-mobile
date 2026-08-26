class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final int linkType;
  final String? linkValue;
  final int sortOrder;
  final bool isActive;
  final String? validFrom;
  final String? validUntil;

  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkType,
    this.linkValue,
    required this.sortOrder,
    required this.isActive,
    this.validFrom,
    this.validUntil,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      linkType: (json['linkType'] as num?)?.toInt() ?? 0,
      linkValue: json['linkValue'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      validFrom: json['validFrom'] as String?,
      validUntil: json['validUntil'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'linkType': linkType,
      'linkValue': linkValue,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'validFrom': validFrom,
      'validUntil': validUntil,
    };
  }
}

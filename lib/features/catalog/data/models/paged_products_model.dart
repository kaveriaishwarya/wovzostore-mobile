import 'product_model.dart';

class PagedProductsModel {
  final List<ProductModel> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PagedProductsModel({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  bool get hasNextPage => (page * pageSize) < totalCount;

  factory PagedProductsModel.fromJson(Map<String, dynamic> json) {
    return PagedProductsModel(
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }
}

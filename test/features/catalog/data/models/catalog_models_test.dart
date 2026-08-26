import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/catalog/data/models/banner_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/brand_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/category_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/paged_products_model.dart';
import 'package:wovzo_mobile/features/catalog/data/models/product_model.dart';

void main() {
  group('Catalog Models Serialization & Null Safety Tests', () {
    test('BannerModel.fromJson parses JSON correctly', () {
      final json = {
        'id': 'b1',
        'title': 'Summer Sale',
        'imageUrl': 'https://example.com/banner.jpg',
        'linkType': 1,
        'linkValue': 'category_1',
        'sortOrder': 2,
        'isActive': true,
      };

      final banner = BannerModel.fromJson(json);
      expect(banner.id, 'b1');
      expect(banner.title, 'Summer Sale');
      expect(banner.linkType, 1);
      expect(banner.sortOrder, 2);
    });

    test('CategoryModel.fromJson parses flat and tree structures', () {
      final treeJson = {
        'id': 'c1',
        'name': 'Electronics',
        'slug': 'electronics',
        'sortOrder': 1,
        'isActive': true,
        'children': [
          {
            'id': 'c2',
            'name': 'Laptops',
            'slug': 'laptops',
            'sortOrder': 1,
            'isActive': true,
          }
        ]
      };

      final category = CategoryModel.fromJson(treeJson);
      expect(category.id, 'c1');
      expect(category.children.length, 1);
      expect(category.children.first.name, 'Laptops');
    });

    test('BrandModel.fromJson parses nullable brand fields correctly', () {
      final json = {
        'id': 'br1',
        'name': 'Wovzo Brand',
        'slug': 'wovzo-brand',
        'isActive': true,
      };

      final brand = BrandModel.fromJson(json);
      expect(brand.id, 'br1');
      expect(brand.logoUrl, null);
      expect(brand.websiteUrl, null);
    });

    test('ProductModel.fromJson parses nested variants and images', () {
      final json = {
        'id': 'p1',
        'name': 'Wireless Headphones',
        'slug': 'wireless-headphones',
        'categoryId': 'c1',
        'status': 2,
        'basePrice': 199.99,
        'isActive': true,
        'isFeatured': true,
        'images': [
          {
            'id': 'img1',
            'productId': 'p1',
            'imageUrl': 'https://example.com/h1.jpg',
            'sortOrder': 0,
            'isPrimary': true,
          }
        ],
        'variants': [
          {
            'id': 'v1',
            'productId': 'p1',
            'sku': 'SKU-001',
            'name': 'Black / Large',
            'price': 199.99,
            'isActive': true,
            'stockQuantity': 50,
          }
        ]
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, 'p1');
      expect(product.basePrice, 199.99);
      expect(product.images.length, 1);
      expect(product.primaryImage?.imageUrl, 'https://example.com/h1.jpg');
      expect(product.variants.length, 1);
      expect(product.variants.first.sku, 'SKU-001');
    });

    test('PagedProductsModel.fromJson parses paged items correctly', () {
      final json = {
        'items': [
          {
            'id': 'p1',
            'name': 'P1',
            'slug': 'p1',
            'categoryId': 'c1',
            'status': 1,
            'basePrice': 99.0,
            'isActive': true,
            'isFeatured': false,
          }
        ],
        'totalCount': 45,
        'page': 1,
        'pageSize': 20,
      };

      final paged = PagedProductsModel.fromJson(json);
      expect(paged.items.length, 1);
      expect(paged.totalCount, 45);
      expect(paged.hasNextPage, isTrue);
    });
  });
}

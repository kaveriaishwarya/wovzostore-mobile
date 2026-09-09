import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/features/store_context/data/models/store_dto.dart';

void main() {
  group('StoreDto Tests', () {
    test('/stores/me parsing creates correct StoreDto', () {
      final json = {
        'id': 'store_123',
        'name': 'My Store',
        'slug': 'my-store',
        'role': 'Merchant'
      };

      final store = StoreDto.fromJson(json);

      expect(store.id, 'store_123');
      expect(store.name, 'My Store');
      expect(store.slug, 'my-store');
      expect(store.role, 'Merchant');
    });
  });
}

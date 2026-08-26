import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/storage/secure_storage_service.dart';

class MemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveAccessToken(String token) async {
    _storage['wovzo_access_token'] = token;
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage['wovzo_access_token'];
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _storage['wovzo_refresh_token'] = token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage['wovzo_refresh_token'];
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _storage['wovzo_access_token'] = accessToken;
    _storage['wovzo_refresh_token'] = refreshToken;
  }

  @override
  Future<void> deleteTokens() async {
    _storage.remove('wovzo_access_token');
    _storage.remove('wovzo_refresh_token');
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }
}

void main() {
  group('SecureStorageService Tests', () {
    late SecureStorageService storage;

    setUp(() {
      storage = MemorySecureStorageService();
    });

    test('save and read access token', () async {
      await storage.saveAccessToken('test_access_token_123');
      final token = await storage.getAccessToken();
      expect(token, 'test_access_token_123');
    });

    test('save and read refresh token', () async {
      await storage.saveRefreshToken('test_refresh_token_456');
      final token = await storage.getRefreshToken();
      expect(token, 'test_refresh_token_456');
    });

    test('saveTokens persists both access and refresh tokens', () async {
      await storage.saveTokens(
        accessToken: 'access_abc',
        refreshToken: 'refresh_xyz',
      );
      expect(await storage.getAccessToken(), 'access_abc');
      expect(await storage.getRefreshToken(), 'refresh_xyz');
    });

    test('deleteTokens removes both tokens', () async {
      await storage.saveTokens(
        accessToken: 'access_abc',
        refreshToken: 'refresh_xyz',
      );
      await storage.deleteTokens();
      expect(await storage.getAccessToken(), null);
      expect(await storage.getRefreshToken(), null);
    });

    test('clearAll clears all stored data', () async {
      await storage.saveTokens(
        accessToken: 'access_abc',
        refreshToken: 'refresh_xyz',
      );
      await storage.clearAll();
      expect(await storage.getAccessToken(), null);
      expect(await storage.getRefreshToken(), null);
    });
  });
}

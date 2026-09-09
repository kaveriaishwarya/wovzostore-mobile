import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wovzo_mobile/core/network/auth_interceptor.dart';

import '../storage/secure_storage_service_test.dart';

void main() {
  group('AuthInterceptor Tests', () {
    late MemorySecureStorageService storage;
    late Dio refreshDio;

    setUp(() {
      storage = MemorySecureStorageService();
      refreshDio = Dio(BaseOptions(baseUrl: 'https://localhost:7291'));
    });

    test('onRequest attaches Bearer token if token exists in storage', () async {
      await storage.saveAccessToken('valid_jwt_token_123');

      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
      );

      final options = RequestOptions(path: '/api/v1/catalog/products');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer valid_jwt_token_123');
      expect(handler.nextCalled, isTrue);
    });

    test('onRequest does NOT attach Bearer token if no token exists', () async {
      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
      );

      final options = RequestOptions(path: '/api/v1/catalog/products');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.nextCalled, isTrue);
    });

    test('onRequest does NOT attach Bearer token for refresh token endpoint', () async {
      await storage.saveAccessToken('valid_jwt_token_123');

      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
      );

      final options = RequestOptions(path: '/api/v1/auth/token/refresh');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(handler.nextCalled, isTrue);
    });

    test('onRequest attaches X-Store-Id if activeStoreId exists and path is not tenant-independent', () async {
      await storage.saveActiveStoreId('store_456');

      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
      );

      final options = RequestOptions(path: '/api/v1/catalog/products');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['X-Store-Id'], 'store_456');
      expect(handler.nextCalled, isTrue);
    });

    test('onRequest does NOT attach X-Store-Id if activeStoreId does not exist', () async {
      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
      );

      final options = RequestOptions(path: '/api/v1/catalog/products');
      final handler = _MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('X-Store-Id'), isFalse);
      expect(handler.nextCalled, isTrue);
    });

    test('onRequest does NOT attach X-Store-Id for tenant-independent endpoints', () async {
      await storage.saveActiveStoreId('store_456');

      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
      );

      // /api/v1/stores is tenant-independent
      final options1 = RequestOptions(path: '/api/v1/stores/me');
      final handler1 = _MockRequestInterceptorHandler();
      await interceptor.onRequest(options1, handler1);
      expect(options1.headers.containsKey('X-Store-Id'), isFalse);
      expect(handler1.nextCalled, isTrue);

      // /api/v1/auth is tenant-independent
      final options2 = RequestOptions(path: '/api/v1/auth/me');
      final handler2 = _MockRequestInterceptorHandler();
      await interceptor.onRequest(options2, handler2);
      expect(options2.headers.containsKey('X-Store-Id'), isFalse);
      expect(handler2.nextCalled, isTrue);
    });

    test('onError on 401 for refresh endpoint passes through without recursion', () async {
      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
      );

      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/token/refresh'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/token/refresh'),
          statusCode: 401,
        ),
      );

      final handler = _MockErrorInterceptorHandler();
      await interceptor.onError(err, handler);

      expect(handler.nextCalled, isTrue);
    });

    test('onError on 401 with no stored refresh token clears credentials and notifies expired', () async {
      bool sessionExpiredNotified = false;

      final interceptor = AuthInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
        onSessionExpired: () {
          sessionExpiredNotified = true;
        },
      );

      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/cart'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/cart'),
          statusCode: 401,
        ),
      );

      final handler = _MockErrorInterceptorHandler();
      await interceptor.onError(err, handler);

      expect(sessionExpiredNotified, isTrue);
      expect(handler.nextCalled, isTrue);
    });
  });
}

class _MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}

class _MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;
  bool resolveCalled = false;

  @override
  void next(DioException err) {
    nextCalled = true;
  }

  @override
  void resolve(Response response) {
    resolveCalled = true;
  }
}
